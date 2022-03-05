//
//  DiscordGateway.swift
//  Native Discord
//
//  Created by Vincent Kwok on 20/2/22.
//

import Foundation
import Starscream

class DiscordGateway: WebSocketDelegate, ObservableObject {
    // Events
    let onStateChange = EventDispatch<(Bool, Bool, GatewayCloseCode?)>()
    let onEvent = EventDispatch<(GatewayEvent, GatewayData)>()
    let onAuthFailure = EventDispatch<Void>()
    
    // Config
    let missedACKTolerance: Int
    let connTimeout: Double
    
    // WebSocket object
    private(set) var socket: WebSocket!
    
    // State
    private(set) var isConnected = false
    private(set) var isReconnecting = false // Attempt to resume broken conn
    private(set) var doNotResume = false // Cannot resume
    private(set) var missedACK = 0
    private(set) var seq: Int? = nil // Sequence int of latest received payload
    private(set) var viability = true
    private(set) var connTimes = 0
    private(set) var authFailed = false
    private var sessionID: String? = nil
    @Published var cache: CachedState = CachedState()
    
    // Logger
    let log = Logger(tag: "DiscordGateway")
    
    func incMissedACK() { missedACK += 1 }
    
    func initWSConn() {
        authFailed = false
        
        var request = URLRequest(url: URL(string: apiConfig.gateway)!)
        request.timeoutInterval = connTimeout
        socket = WebSocket(request: request)
        socket.delegate = self
        
        log.i("Attempting connection to Gateway: \(apiConfig.gateway)")
        socket.connect()
        
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
    
    // Attempt reconnection with resume after 1-5s as per spec
    func attemptReconnect(resume: Bool = true, overrideViability: Bool = false) {
        log.d("Resume called")
        if authFailed {
            log.e("Not reconnecting - auth failed")
            return
        }
        // Kill connection if connection is still active
        if isConnected { self.socket.forceDisconnect() }
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
        }
    }
    
    init(connectionTimeout: Double = 5, maxMissedACK: Int = 3) {
        missedACKTolerance = maxMissedACK
        connTimeout = connectionTimeout
        initWSConn()
    }
    
    // MARK: Low level receive handler
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch (event) {
        case .connected(_):
            log.i("Gateway Connected")
            isReconnecting = false
            isConnected = true
            connTimes += 1
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
            onStateChange.notify(event: (isConnected, isReconnecting, code))
        case .text(let string): handleIncoming(received: string)
        case .error(let error):
            isConnected = false
            attemptReconnect()
            onStateChange.notify(event: (isConnected, isReconnecting, nil))
            log.e("Connection error: \(String(describing: error))")
        case .cancelled:
            isConnected = false
            onStateChange.notify(event: (isConnected, isReconnecting, nil))
        case .binary(_): break // Won't receive binary
        case .ping(_): break   // Don't care
        case .pong(_): break   // Don't care
        case .viabilityChanged(let viability):
            // If viability is false, reconnection will most likely fail
            log.d("Viability changed: \(viability)")
            if viability && !self.viability {
                // We should reconnect since connection is now viable
                attemptReconnect(resume: true, overrideViability: true)
            }
            self.viability = viability
        case .reconnectSuggested(_):
            log.d("Reconnect suggested!")
        }
    }
    
    func handleIncoming(received: String) {
        guard let decoded = try? JSONDecoder().decode(GatewayIncoming.self, from: received.data(using: .utf8)!)
        else { return }
        
        if (decoded.s != nil) { seq = decoded.s } // Update sequence
        
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
                seq = nil // Clear sequence #
                isReconnecting = false // Resuming failed/not attempted
                guard let identify = getIdentify() else {
                    log.d("Token not in keychain")
                    onAuthFailure.notify()
                    authFailed = true
                    socket.disconnect(closeCode: 1000)
                    return
                }
                sendToGateway(op: .identify, d: identify)
            }
        case .heartbeatAck: missedACK = 0
        case .dispatchEvent:
            guard let type = decoded.t else { return }
            guard let data = decoded.d else { return }
            switch (type) {
            case .ready:
                guard let d = data as? ReadyEvt else { return }
                doNotResume = false
                sessionID = d.session_id
                cache.guilds = d.guilds
                cache.user = d.user
                log.i("Gateway ready")
            default: log.i("Dispatched event <\(type)>: \(data)")
            }
            onEvent.notify(event: (type, data))
        case .invalidSession:
            // Check if the session can be resumed
            let shouldResume = (decoded.primitiveData as? Bool) ?? false
            if !shouldResume && doNotResume {
                onAuthFailure.notify()
                authFailed = true
            }
            else { attemptReconnect(resume: shouldResume) }
        default: log.w("Unimplemented opcode: \(decoded.op)")
        }
    }
}
