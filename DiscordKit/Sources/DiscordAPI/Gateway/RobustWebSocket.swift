//
//  RobustWebSocket.swift
//  DiscordAPI
//
//  Created by Vincent on 4/13/22.
//

import Foundation
import Reachability
import OSLog
import Combine

/// A robust WebSocket that handles resuming, reconnection and heartbeats
/// with the Discord Gateway, inspired by robust-websocket

public class RobustWebSocket: NSObject, ObservableObject {
    public let onEvent = EventDispatch<(GatewayEvent, GatewayData?)>(),
               onAuthFailure = EventDispatch<Void>(),
               onConnStateChange = EventDispatch<(Bool, Bool)>(), // session open, reachable
               onSessionInvalid = EventDispatch<Void>() // When the session cannot be resumed
    
    private var session: URLSession!, socket: URLSessionWebSocketTask!,
                decompressor: DecompressionEngine!
	private let reachability = try! Reachability(), log = Logger(subsystem: Bundle.main.bundleIdentifier ?? DiscordAPI.subsystem, category: "RobustWebSocket")
    
    private let queue: OperationQueue
        
    private let timeout: TimeInterval, maxMsgSize: Int,
                reconnectInterval: (URLSessionWebSocketTask.CloseCode?, Int) -> TimeInterval?
    private var attempts = 0, reconnects = -1, awaitingHb: Int = 0,
                reconnectWhenOnlineAgain = false, explicitlyClosed = false,
                seq: Int? = nil, canResume = false, sessionID: String? = nil,
                pendingReconnect: Timer? = nil, connTimeout: Timer? = nil
    public var connected = false {
        didSet { if !connected { sessionOpen = false }}
    }
    public var reachable = false {
        didSet { onConnStateChange.notify(event: (connected, reachable)) }
    }
    public var sessionOpen = false {
        didSet { onConnStateChange.notify(event: (connected, reachable)) }
    }
    fileprivate var hbCancellable: AnyCancellable? = nil
    
    private func clearPendingReconnectIfNeeded() {
        if let reconnectTimer = pendingReconnect {
            reconnectTimer.invalidate()
            pendingReconnect = nil
        }
    }
    
    private func hasConnected() {
        if let timer = connTimeout {
            timer.invalidate()
            connTimeout = nil
        }
        reconnectWhenOnlineAgain = true
        attempts = 0
        connected = true
    }
        
    // MARK: - (Re)Connection
    private func reconnect(code: URLSessionWebSocketTask.CloseCode?) {
        guard !explicitlyClosed else {
            attempts = 0
            return
        }
        guard reachable else {
            reconnectWhenOnlineAgain = true
            return
        }
        guard connTimeout == nil else { return }
        
        let delay = reconnectInterval(code, attempts)
        if let delay = delay {
            log.info("Reconnecting after \(delay)s...")
            DispatchQueue.main.async { [weak self] in
                self?.pendingReconnect = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
                    guard self?.connected != true else {
                        self?.log.warning("Looks like we're already connected, no need to reconnect")
                        return
                    }
                    guard self?.connTimeout == nil else {
                        self?.log.warning("Not reconnecting: already attempting a connection")
                        return
                    }
                    self?.log.debug("Attempting reconnection now")
                    self?.connect()
                }
            }
        }
    }
    
    private func attachSockReceiveListener() {
        socket.receive { [weak self] result in
            // print(result)
            switch result {
            case .success(let message):
                switch (message) {
                case .data(let data):
                    if let decompressed = self?.decompressor.push_data(data) {
                        self?.handleMessage(message: decompressed)
                    } else { self?.log.debug("Data has not ended yet") }
                    break
                case .string(let str): self?.handleMessage(message: str)
                @unknown default: self?.log.warning("Unknown sock message case!")
                }
                // self?.onMessage.notify(event: message)
                self?.attachSockReceiveListener()
            case .failure(let error):
                // If an error is encountered here, the connection is probably broken
                self?.log.error("Error when receiving: \(error.localizedDescription, privacy: .public)")
                self?.forceClose()
            }
        }
    }
    private func connect() {
        pendingReconnect = nil
        awaitingHb = 0
        
        var gatewayReq = URLRequest(url: URL(string: GatewayConfig.default.gateway)!)
        // The difference in capitalisation is intentional
		gatewayReq.setValue(DiscordAPI.userAgent, forHTTPHeaderField: "User-Agent")
        socket = session.webSocketTask(with: gatewayReq)
        socket.maximumMessageSize = maxMsgSize
        
        DispatchQueue.main.async { [weak self] in
            self?.connTimeout = Timer.scheduledTimer(withTimeInterval: self!.timeout, repeats: false) { [weak self] _ in
                self?.connTimeout = nil
                // reachability.stopNotifier()
                self?.log.warning("Connection timed out after \(self!.timeout)s")
                self?.forceClose()
            }
        }
        
        attempts += 1
        // Create new instance of decompressor
        // It's best to do it here, before resuming the task since sometimes, messages arrive before the compressor is initialised in the socket open handler.
        decompressor = DecompressionEngine()
        socket.resume()
        
        setupReachability()
        attachSockReceiveListener()
    }
    
    // MARK: - Handlers
    private func handleMessage(message: String) {
        /*
         For debugging JSON decoding errors, how wonderful!
        do {
            try JSONDecoder().decode(GatewayIncoming.self, from: message.data(using: .utf8)!)
            // process data
        } catch let DecodingError.dataCorrupted(context) {
            print(context)
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("error: ", error)
        }*/

		let decoded: GatewayIncoming
		do {
			decoded = try JSONDecoder().decode(GatewayIncoming.self, from: message.data(using: .utf8) ?? Data())
		} catch {
			print(error)
			return
		}
        
        if let sequence = decoded.s { seq = sequence }
        
        switch decoded.op {
        case .heartbeat:
            log.debug("Sending expedited heartbeat as requested")
            send(op: .heartbeat, data: GatewayHeartbeat())
        case .heartbeatAck: awaitingHb -= 1
        case .hello:
            hasConnected()
            // Start heartbeating and send identify
            guard let d = decoded.d as? GatewayHello else { return }
            log.debug("Hello payload is: \(String(describing: d), privacy: .public)")
            startHeartbeating(interval: Double(d.heartbeat_interval) / 1000.0)
        
            // Check if we're attempting to and can resume
            if canResume, let sessionID = sessionID, let seq = seq {
                log.info("Attempting resume")
                guard let resume = getResume(seq: seq, sessionID: sessionID)
                else { return }
                send(op: .resume, data: resume)
                return
            }
            log.debug("Identifying with gateway...")
            // Send identify
            seq = nil // Clear sequence #
            // isReconnecting = false // Resuming failed/not attempted
            guard let identify = getIdentify() else {
                log.debug("Token not in keychain")
                Logger().debug("Hello there, \("safljslaf", privacy: .private(mask: .hash))")
                // authFailed = true
                // socket.disconnect(closeCode: 1000)
                close(code: .normalClosure)
                onAuthFailure.notify()
                return
            }
            send(op: .identify, data: identify)
        case .invalidSession:
            // Check if the session can be resumed
            let shouldResume = (decoded.primitiveData as? Bool) ?? false
            if !shouldResume {
                log.warning("Session is invalid, reconnecting without resuming")
                onSessionInvalid.notify()
                canResume = false
            }
            /// Close the connection immediately and reconnect after 1-5s, as per Discord docs
            /// Unfortunately Discord seems to reject the new identify no matter how long I
            /// wait before sending it, so sometimes there will be 2 identify attempts before
            /// the Gateway session is reestablished
            close(code: .normalClosure)
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 1...5)) { [weak self] in
                self?.log.debug("Attempting to reconnect now")
                self?.open()
            }
            // attemptReconnect(resume: shouldResume)
        case .dispatchEvent:
            guard let type = decoded.t else {
                log.warning("Event has nil type")
                return
            }
            switch type {
            case .ready:
                guard let d = decoded.d as? ReadyEvt else { return }
                sessionID = d.session_id
                canResume = true
                fallthrough
            case .resumed: sessionOpen = true
            default: break
            }
            onEvent.notify(event: (type, decoded.d))
        case .reconnect:
            log.warning("Gateway-requested reconnect: disconnecting and reconnecting immediately")
            forceClose()
        }
    }
    
    
    // MARK: - Initializers
    init(timeout: TimeInterval, maxMessageSize: Int, reconnectIntClosure: @escaping (URLSessionWebSocketTask.CloseCode?, Int) -> TimeInterval?) {
        self.timeout = timeout
        queue = OperationQueue()
        queue.qualityOfService = .utility
        reconnectInterval = reconnectIntClosure
        maxMsgSize = maxMessageSize
        super.init()
        session = URLSession(configuration: .default, delegate: self, delegateQueue: queue)
        connect()
    }
    
    override convenience init() {
        self.init(timeout: TimeInterval(4), maxMessageSize: 1024*1024*10) { code, times in
            guard code != .policyViolation, code != .internalServerError, times < 10
            else { return nil }
            
            return pow(1.4, Double(times)) * 5 - 5
        }
    }
}


// MARK: - WebSocketTask delegate functions
extension RobustWebSocket: URLSessionWebSocketDelegate {
	public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        log.info("Socket connection opened")
    }
    
	public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        reconnect(code: closeCode)
        connected = false
        // didCloseConnection?()
        // didReceive(event: .disconnected("", UInt16(closeCode.rawValue)))
        reconnectWhenOnlineAgain = false
        log.info("Socket connection closed")
    }
}


// MARK: - Reachability
public extension RobustWebSocket {
    private func setupReachability() {
        reachability.whenReachable = { [weak self] _ in
            self?.reachable = true
            self?.log.info("Connection reachable")
            //if let reconnect = self?.reconnectWhenOnlineAgain, reconnect {
            // Temporarily ignore reconnectWhenOnlineAgain since that was causing issues
            self?.clearPendingReconnectIfNeeded()
            self?.attempts = 0
            self?.reconnect(code: nil)
            //}
        }
        reachability.whenUnreachable = { [weak self] _ in
            self?.reachable = false
            self?.log.info("Connection unreachable")
            self?.forceClose()
        }
        do { try reachability.startNotifier() }
        catch { log.error("Starting reachability notifier failed!") }
    }
}


// MARK: - Heartbeating
public extension RobustWebSocket {
    @objc private func sendHeartbeat() {
        guard connected else { return }
        
        log.debug("Sending heartbeat, awaiting \(self.awaitingHb) ACKs")
        if awaitingHb > 1 {
            log.error("Too many pending heartbeats, closing socket")
            forceClose()
        }
        send(op: .heartbeat, data: GatewayHeartbeat())
        awaitingHb += 1
    }
    
    private func startHeartbeating(interval: TimeInterval) {
        log.debug("Sending heartbeats every \(interval)s")
        awaitingHb = 0
        
        guard hbCancellable == nil else { return }
        
        // First heartbeat after interval * jitter where jitter is a value from 0-1
        // ~ Discord API docs
        DispatchQueue.main.asyncAfter(
            deadline: .now() + interval * Double.random(in: 0...1),
            qos: .utility,
            flags: .enforceQoS
        ) {
            // Only ever start 1 publishing timer
            self.sendHeartbeat()
            
            self.hbCancellable = Timer.publish(every: interval, tolerance: 2, on: .main, in: .common)
                .autoconnect()
                .sink() { _ in self.sendHeartbeat() }
        }
    }
}


// MARK: - Extension with public exposed methods
public extension RobustWebSocket {
    func forceClose(
        code: URLSessionWebSocketTask.CloseCode = .abnormalClosure,
        shouldReconnect: Bool = true
    ) {
        log.warning("Forcibly closing connection")
        self.socket.cancel(with: code, reason: nil)
        connected = false
        if shouldReconnect { self.reconnect(code: nil) }
    }
    func close(code: URLSessionWebSocketTask.CloseCode) {
        clearPendingReconnectIfNeeded()
        reconnectWhenOnlineAgain = false
        explicitlyClosed = true
        connected = false
        sessionID = nil
        reachability.stopNotifier()
        
        socket.cancel(with: code, reason: nil)
    }
    
    func open() {
        guard socket.state != .running else { return }
        clearPendingReconnectIfNeeded()
        reconnectWhenOnlineAgain = false
        explicitlyClosed = false
        
        connect()
    }
    
    func send<T: OutgoingGatewayData>(
        op: GatewayOutgoingOpcodes,
        data: T,
        completionHandler: ((Error?) -> Void)? = nil
    ) {
        guard connected else { return }

        let sendPayload = GatewayOutgoing(op: op, d: data, s: seq)
        guard let encoded = try? JSONEncoder().encode(sendPayload)
        else { return }
        
        log.debug("Outgoing Payload: <\(String(describing: op), privacy: .public)> \(String(describing: data), privacy: .sensitive(mask: .hash)) [seq: \(String(describing: self.seq), privacy: .public)]")
        // socket.write(string: String(data: encoded, encoding: .utf8)!)
        socket.send(.data(encoded), completionHandler: completionHandler ?? { [weak self] err in
            if let err = err { self?.log.error("Socket send error: \(err.localizedDescription, privacy: .public)") }
        })
    }
}
