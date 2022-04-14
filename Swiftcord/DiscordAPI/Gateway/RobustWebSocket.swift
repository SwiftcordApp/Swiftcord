//
//  RobustWebSocket.swift
//  Swiftcord
//
//  Created by Vincent on 4/13/22.
//

import Foundation
import Reachability

/// A robust WebSocket that handles resuming, reconnection and heartbeats
/// with the Discord Gateway, inspired by robust-websocket

class RobustWebSocket: NSObject {
    public let onEvent = EventDispatch<(GatewayEvent, GatewayData)>()
    
    private var session: URLSession!, socket: URLSessionWebSocketTask!
    private let reachability = try! Reachability(), log = Logger(tag: "RobustWebSocket")
    
    private let queue: OperationQueue
        
    private let timeout: TimeInterval, maxMsgSize: Int,
                reconnectInterval: (URLSessionWebSocketTask.CloseCode?, Int) -> TimeInterval?
    private var attempts = 0, reconnects = -1, connected = false, awaitingHb: Int = 0,
                reachable = false, reconnectWhenOnlineAgain = false, explicitlyClosed = false,
                seq: Int? = nil, canResume = false, sessionID: String? = nil,
                pendingReconnect: Timer? = nil, connTimeout: Timer? = nil, hbTimer: Timer? = nil
    
    private func clearPendingReconnectIfNeeded() {
        if let reconnectTimer = pendingReconnect {
            reconnectTimer.invalidate()
            pendingReconnect = nil
        }
    }
        
    // MARK: - (Re)Connection
    private func reconnect(code: URLSessionWebSocketTask.CloseCode?) {
        guard !explicitlyClosed else {
            log.w("Not reconnecting: connection was explicitly closed")
            attempts = 0
            return
        }
        guard reachable else {
            log.w("Not reconnecting: connection is unreachable")
            reconnectWhenOnlineAgain = true
            return
        }
        guard connTimeout == nil else {
            log.w("Not reconnecting: already attempting a connection")
            return
        }
        
        let delay = reconnectInterval(code, attempts)
        if let delay = delay {
            log.i("Reconnecting after \(delay)s...")
            DispatchQueue.main.async { [weak self] in
                self?.pendingReconnect = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
                    guard self?.connected != true else {
                        self?.log.w("Looks like we're already connected, no need to reconnect")
                        return
                    }
                    guard self?.connTimeout == nil else {
                        self?.log.w("Not reconnecting: already attempting a connection")
                        return
                    }
                    self?.log.d("Attempting reconnection now")
                    self?.connect()
                }
            }
        }
    }
    
    private func attachSockReceiveListener() {
        socket.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch (message) {
                case .data(_): break
                case .string(let str): self?.handleMessage(message: str)
                @unknown default: self?.log.w("Unknown sock message case!")
                }
                // self?.onMessage.notify(event: message)
                self?.attachSockReceiveListener()
            case .failure(let error):
                // If an error is encountered here, the connection is probably broken
                self?.log.e("Error when receiving: \(error)")
                self?.forceClose()
                return
            }
        }
    }
    private func connect() {
        pendingReconnect = nil
        awaitingHb = 0
        stopHeartbeating()
        
        socket = session.webSocketTask(with: URL(string: apiConfig.gateway)!)
        socket.maximumMessageSize = maxMsgSize
        
        DispatchQueue.main.async { [weak self] in
            self?.connTimeout = Timer.scheduledTimer(withTimeInterval: self!.timeout, repeats: false) { [weak self] _ in
                self?.connTimeout = nil
                // reachability.stopNotifier()
                self?.log.w("Connection timed out after \(self!.timeout)s")
                self?.forceClose()
            }
        }
        
        attempts += 1
        socket.resume()
        
        setupReachability()
        attachSockReceiveListener()
    }
    
    // MARK: - Handlers
    private func handleMessage(message: String) {
        guard let decoded = try? JSONDecoder().decode(GatewayIncoming.self, from: message.data(using: .utf8)!)
        else { return }
        
        if let sequence = decoded.s { seq = sequence }
        
        switch(decoded.op) {
        case .heartbeat:
            log.d("Sending expedited heartbeat as requested")
            send(op: .heartbeat, data: GatewayHeartbeat())
        case .heartbeatAck: awaitingHb -= 1
        case .hello:
            // Start heartbeating and send identify
            guard let d = decoded.d as? GatewayHello else { return }
            log.d("Hello payload is:", String(describing: d))
            startHeartbeating(interval: Double(d.heartbeat_interval) / 1000.0)
        
            // Check if we're attempting to and can resume
            if canResume, let sessionID = sessionID, let seq = seq {
                log.i("Attempting resume")
                guard let resume = getResume(seq: seq, sessionID: sessionID)
                else { return }
                send(op: .resume, data: resume)
                return
            }
            log.d("Sending identify")
            // Send identify
            seq = nil // Clear sequence #
            // isReconnecting = false // Resuming failed/not attempted
            guard let identify = getIdentify() else {
                log.d("Token not in keychain")
                // authFailed = true
                // socket.disconnect(closeCode: 1000)
                return
            }
            send(op: .identify, data: identify)
        case .invalidSession:
            // Check if the session can be resumed
            let shouldResume = (decoded.primitiveData as? Bool) ?? false
            if !shouldResume { canResume = false }
            log.w("Session is invalid, reconnecting without resuming")
            forceClose(code: .normalClosure)
            // attemptReconnect(resume: shouldResume)
        case .dispatchEvent:
            guard let type = decoded.t else { return }
            guard let data = decoded.d else { return }
            switch type {
            case .ready:
                guard let d = data as? ReadyEvt else { return }
                sessionID = d.session_id
                canResume = true
            default: break
            }
            onEvent.notify(event: (type, data))
        case .reconnect:
            log.w("Gateway-requested reconnect: disconnecting and reconnecting immediately")
            
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
            if code == .policyViolation || code == .internalServerError { return nil }
            return [2, 5, 10][times]
        }
    }
}


// MARK: - WebSocketTask delegate functions
extension RobustWebSocket: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        // didOpenConnection?()
        if let timer = connTimeout {
            timer.invalidate()
            connTimeout = nil
        }
        reconnectWhenOnlineAgain = true
        attempts = 0
        connected = true
        log.i("Socket connection opened")
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        reconnect(code: closeCode)
        connected = false
        stopHeartbeating()
        // didCloseConnection?()
        // didReceive(event: .disconnected("", UInt16(closeCode.rawValue)))
        reconnectWhenOnlineAgain = false
        log.i("Socket connection closed")
    }
}


// MARK: - Reachability
extension RobustWebSocket {
    private func setupReachability() {
        reachability.whenReachable = { [weak self] _ in
            self?.reachable = true
            self?.log.i("Connection reachable")
            //if let reconnect = self?.reconnectWhenOnlineAgain, reconnect {
            // Temporarily ignore reconnectWhenOnlineAgain since that was causing issues
            self?.clearPendingReconnectIfNeeded()
            self?.reconnect(code: nil)
            //}
        }
        reachability.whenUnreachable = { [weak self] _ in
            self?.reachable = false
            self?.log.i("Connection unreachable")
            self?.forceClose()
        }
        do { try reachability.startNotifier() }
        catch { log.e("Starting reachability notifier failed!") }
    }
}


// MARK: - Heartbeating
extension RobustWebSocket {
    @objc private func sendHeartbeat() {
        log.d("Sending heartbeat, awaiting \(awaitingHb) ACKs")
        if awaitingHb > 1 {
            log.e("Too many pending heartbeats, closing socket")
            forceClose()
        }
        send(op: .heartbeat, data: GatewayHeartbeat())
        awaitingHb += 1
    }
    
    private func startHeartbeating(interval: TimeInterval) {
        if hbTimer != nil { stopHeartbeating() }
        log.d("Sending heartbeats every \(interval)s")
        awaitingHb = 0
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + interval * Double.random(in: 0...1),
            qos: .utility,
            flags: .enforceQoS
        ) {
            self.sendHeartbeat()
            self.hbTimer = Timer(timeInterval: interval, target: self, selector: #selector(self.sendHeartbeat), userInfo: nil, repeats: true)
            RunLoop.current.add(self.hbTimer!, forMode: .common)
        }
    }
    private func stopHeartbeating() {
        if let heartbeatTimer = hbTimer {
            log.d("Stopping heartbeat timer")
            heartbeatTimer.invalidate()
            hbTimer = nil
        }
    }
}


// MARK: - Extension with public exposed methods
extension RobustWebSocket {
    public func forceClose(code: URLSessionWebSocketTask.CloseCode = .abnormalClosure) {
        log.w("Forcibly closing connection")
        stopHeartbeating()
        self.socket.cancel(with: code, reason: nil)
        connected = false
        self.reconnect(code: nil)
    }
    public func close(code: URLSessionWebSocketTask.CloseCode) {
        clearPendingReconnectIfNeeded()
        reconnectWhenOnlineAgain = false
        explicitlyClosed = true
        connected = false
        sessionID = nil
        reachability.stopNotifier()
        
        socket.cancel(with: code, reason: nil)
        stopHeartbeating()
    }
    
    public func open() {
        guard socket.state != .running else { return }
        clearPendingReconnectIfNeeded()
        reconnectWhenOnlineAgain = false
        explicitlyClosed = false
        
        connect()
    }
    
    public func send<T: OutgoingGatewayData>(
        op: GatewayOutgoingOpcodes,
        data: T,
        completionHandler: ((Error?) -> Void)? = nil
    ) {
        guard connected else { return }

        let sendPayload = GatewayOutgoing(op: op, d: data, s: seq)
        guard let encoded = try? JSONEncoder().encode(sendPayload)
        else { return }
        
        log.d("Outgoing Payload: <\(op)>", sendPayload.d != nil ? String(describing: sendPayload.d!) : "[No data]", "Seq:", String(describing: sendPayload.s))
        // socket.write(string: String(data: encoded, encoding: .utf8)!)
        socket.send(.data(encoded), completionHandler: completionHandler ?? { [weak self] err in
            if let err = err { self?.log.e("Socket send error:", err.localizedDescription) }
        })
    }
}
