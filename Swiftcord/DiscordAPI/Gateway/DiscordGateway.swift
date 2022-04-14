//
//  DiscordGateway.swift
//  Native Discord
//
//  Created by Vincent Kwok on 20/2/22.
//

import Foundation

class DiscordGateway: ObservableObject {
    // Events
    let onStateChange = EventDispatch<(Bool, Bool, GatewayCloseCode?)>()
    let onEvent = EventDispatch<(GatewayEvent, GatewayData)>()
    let onAuthFailure = EventDispatch<Void>()
    
    // Config
    // let missedACKTolerance: Int
    // let connTimeout: Double
    
    // WebSocket object
    // private(set) var socket: WebSocket!
    // private(set) var session: URLSession!
    // private(set) var socket: URLSessionWebSocketTask!
    private var socket: RobustWebSocket!
    
    // State
    @Published private(set) var isConnected = false
    @Published private(set) var isReconnecting = false // Attempt to resume broken conn
    @Published private(set) var doNotResume = false // Cannot resume
    @Published private(set) var missedACK = 0
    @Published private(set) var seq: Int? = nil // Sequence int of latest received payload
    @Published private(set) var viability = true
    @Published private(set) var connTimes = 0
    /*private(set) var authFailed = false {
        didSet {
            if authFailed { onAuthFailure.notify() }
            cache = CachedState() // Clear the cache
        }
    }*/
    @Published private(set) var sessionID: String? = nil
    @Published var cache: CachedState = CachedState()
    
    private var evtListenerID: EventDispatch.HandlerIdentifier? = nil
    
    // Logger
    let log = Logger(tag: "DiscordGateway")
    
    // Queues
    /*let queue: DispatchQueue
    let opQueue: OperationQueue
    
    func incMissedACK() { missedACK += 1 }
    
    func initWSConn() {
        authFailed = false
        
        /*var request = URLRequest(url: URL(string: apiConfig.gateway)!)
        request.timeoutInterval = connTimeout
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.callbackQueue = queue*/
        
        socket = session.webSocketTask(with: URL(string: apiConfig.gateway)!)
        socket.maximumMessageSize = 5243000 // (5MiB) Raise max incoming message  size to avoid errors
        
        log.i("Attempting connection to Gateway: \(apiConfig.gateway)")
        socket.resume()
        
        addReceiveListener()
        
        // If connection isn't connected after timeout, try again
        let curConnCnt = connTimes
        DispatchQueue.main.asyncAfter(deadline: .now() + connTimeout) {
            if !self.isConnected && self.connTimes == curConnCnt {
                self.log.w("Connection timed out, trying to reconnect")
                self.isReconnecting = false
                self.attemptReconnect()
            }
        }
    }
    
    func addReceiveListener() {
        socket.receive { [weak self] (result) in
            switch result {
            case .success(let response):
                switch response {
                case .data(let data): self?.didReceive(event: .binary(data))
                case .string(let message): self?.didReceive(event: .text(message))
                    
                @unknown default: break
                }
            case .failure(let error):  self?.didReceive(event: .error(error))
            }
            self?.addReceiveListener()
        }
    }
    
    // Attempt reconnection with resume after 1-5s as per spec
    func attemptReconnect(resume: Bool = true, overrideViability: Bool = false) {
        log.d("Resume called")
        if authFailed {
            log.e("Not reconnecting - auth failed")
            return
        }
        // Kill connection if connection is still active
        /*if isConnected { self.socket.forceDisconnect() }
        guard viability || overrideViability, !isReconnecting else { return }
        isReconnecting = true
        if !resume { doNotResume = true }
        let reconnectAfter = 1000 + Int(Double(4000) * Double.random(in: 0...1))
        log.i("Reconnecting in \(reconnectAfter)ms")
        DispatchQueue.main.asyncAfter(
            deadline: .now() +
            .milliseconds(reconnectAfter)
        ) {
            self.log.d("Attempting reconnection now")
            self.log.d("Can resume: \(!self.doNotResume)")
            self.initWSConn() // Recreate WS object because sometimes it gets stuck in a "not gonna reconnect" state
        }*/
        
        
    }
    
    // Log out the user - delete token from keychain and disconnect connection
    func logOut() {
        log.d("Logging out...")
        let _ = Keychain.remove(key: "token")
        // socket.disconnect(closeCode: 1000)
        socket.cancel(with: .normalClosure, reason: nil)
        authFailed = true
    }
    
    init(connectionTimeout: Double = 5, maxMissedACK: Int = 3) {
        missedACKTolerance = maxMissedACK
        connTimeout = connectionTimeout
        queue = DispatchQueue(label: "com.swiftcord.gatewayQueue", qos: .background, attributes: .concurrent, autoreleaseFrequency: .workItem, target: .global(qos: .background))
        opQueue = OperationQueue()
        opQueue.qualityOfService = .utility
        opQueue.underlyingQueue = queue
        super.init()
        session = URLSession(configuration: .default, delegate: self, delegateQueue: opQueue)
        
        initWSConn()
    }
    
    
    // MARK: Low level receive handler
    func didReceive(event: WebSocketEvent) {
        switch (event) {
        case .connected(_):
            log.i("Gateway Connected")
            DispatchQueue.main.async { [weak self] in
                self?.isReconnecting = false
                self?.isConnected = true
                self?.connTimes += 1
            }
            onStateChange.notify(event: (isConnected, isReconnecting, nil))
        case .disconnected(_, let c):
            isConnected = false
            guard let code = GatewayCloseCode(rawValue: Int(c)) else {
                log.e("Unknown close code: \(c)")
                return
            }
            // Check if code isn't an unrecoverable code, then attempt resume
            if code != .authenthicationFail { attemptReconnect() }
            log.w("Gateway Disconnected: \(code)")
            switch code {
            case .authenthicationFail: authFailed = true
            default: log.w("Unhandled gateway close code:", code)
            }
            onStateChange.notify(event: (isConnected, isReconnecting, code))
        case .text(let string): self.handleIncoming(received: string)
        case .error(let error):
            DispatchQueue.main.async { self.isConnected = false }
            attemptReconnect()
            onStateChange.notify(event: (isConnected, isReconnecting, nil))
            log.e("Connection error: \(String(describing: error))")
        case .cancelled:
            isConnected = false
            onStateChange.notify(event: (isConnected, isReconnecting, nil))
            log.d("Connection cancelled")
        case .binary(_): break // Won't receive binary
        default: break
        }
    }
    
    func handleIncoming(received: String) {
        guard let decoded = try? JSONDecoder().decode(GatewayIncoming.self, from: received.data(using: .utf8)!)
        else { return }
        
        DispatchQueue.main.async {
            if (decoded.s != nil) { self.seq = decoded.s } // Update sequence
        }
        
        switch (decoded.op) {
        case .heartbeat:
            // Immediately send heartbeat as requested
            log.d("Send heartbeat by server request")
            sendToGateway(op: .heartbeat, d: GatewayHeartbeat())
        case .hello:
            // Start heartbeating and send identify
            guard let d = decoded.d as? GatewayHello else { return }
            initHeartbeat(interval: d.heartbeat_interval)
        
            // Check if we're attempting to and can resume
            if isReconnecting && !doNotResume && sessionID != nil && seq != nil {
                log.i("Attempting resume")
                guard let resume = getResume(seq: seq!, sessionID: sessionID!)
                else { return }
                sendToGateway(op: .resume, d: resume)
            }
            else {
                log.d("Sending identify:", isConnected, !doNotResume, sessionID ?? "No sessionID", seq ?? -1)
                // Send identify
                DispatchQueue.main.async {
                    self.seq = nil // Clear sequence #
                    self.isReconnecting = false // Resuming failed/not attempted
                }
                guard let identify = getIdentify() else {
                    log.d("Token not in keychain")
                    authFailed = true
                    // socket.disconnect(closeCode: 1000)
                    return
                }
                sendToGateway(op: .identify, d: identify)
            }
        case .heartbeatAck: DispatchQueue.main.async { self.missedACK = 0 }
        case .dispatchEvent:
            guard let type = decoded.t else { return }
            guard let data = decoded.d else { return }
            switch (type) {
            case .ready:
                guard let d = data as? ReadyEvt else { return }
                DispatchQueue.main.async {
                    self.doNotResume = false
                    self.sessionID = d.session_id
                    self.cache.guilds = d.guilds
                    self.cache.user = d.user
                }
                log.i("Gateway ready")
                //onEvent.notify(event: (type, data))
            default: log.i("Dispatched event <\(type)>")
            }
            onEvent.notify(event: (type, data))
        case .invalidSession:
            // Check if the session can be resumed
            let shouldResume = (decoded.primitiveData as? Bool) ?? false
            attemptReconnect(resume: shouldResume)
        default: log.w("Unimplemented opcode: \(decoded.op)")
        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        // didOpenConnection?()
        didReceive(event: .connected([:]))
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        // didCloseConnection?()
        log.w("Session Gateway disconnected")
        didReceive(event: .disconnected("", UInt16(closeCode.rawValue)))
    }*/
    
    public func logout() {
        log.d("Logging out on request")
        let _ = Keychain.remove(key: "token")
        // socket.disconnect(closeCode: 1000)
        socket.close(code: .normalClosure)
        // authFailed = true
    }
    
    public func connect() {
        socket.open()
    }
    
    private func handleEvt(type: GatewayEvent, data: GatewayData) {
        switch (type) {
        case .ready:
            guard let d = data as? ReadyEvt else { return }
            //self.doNotResume = false
            //self.sessionID = d.session_id
            self.cache.guilds = d.guilds
            self.cache.user = d.user
            log.i("Gateway ready")
            //onEvent.notify(event: (type, data))
        default: break
        }
        onEvent.notify(event: (type, data))
        log.i("Dispatched event <\(type)>")
    }
    
    init(connectionTimeout: Double = 5, maxMissedACK: Int = 3) {
        socket = RobustWebSocket()
        evtListenerID = socket.onEvent.addHandler { [weak self] (t, d) in
            self?.handleEvt(type: t, data: d)
        }
    }
}
