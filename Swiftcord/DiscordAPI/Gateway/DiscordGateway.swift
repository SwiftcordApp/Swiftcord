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
    private var sessionID: String? = nil
    private var cache: CachedState?
    
    func incMissedACK() {
        missedACK += 1
    }
    
    func initWSConn() {
        var request = URLRequest(url: URL(string: apiConfig.gateway)!)
        request.timeoutInterval = connTimeout
        socket = WebSocket(request: request)
        socket.delegate = self
        
        print("Attempting connection to Gateway: \(apiConfig.gateway)")
        socket.connect()
        
        // If connection isn't connected after timeout, try again
        let curConnCnt = connTimes
        DispatchQueue.main.asyncAfter(deadline: .now() + connTimeout) {
            if !self.isConnected && self.connTimes == curConnCnt {
                print("Connection timed out, trying to reconnect")
                self.isReconnecting = false
                self.attemptReconnect()
            }
        }
    }
    
    // Attempt reconnection with resume after 1-5s as per spec
    func attemptReconnect(resume: Bool = true, overrideViability: Bool = false) {
        print("Resume called")
        // Kill connection if connection is still active
        if isConnected { self.socket.forceDisconnect() }
        guard viability || overrideViability, !isReconnecting else { return }
        isReconnecting = true
        if !resume { doNotResume = true }
        let reconnectAfter = 1000 + Int(Double(4000) * Double.random(in: 0...1))
        print("Reconnecting in \(reconnectAfter)ms")
        DispatchQueue.main.asyncAfter(
            deadline: .now() +
            .milliseconds(reconnectAfter)
        ) {
            print("Attempting reconnection now")
            print("Can resume: \(!self.doNotResume)")
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
            print("Gateway Connected")
            isReconnecting = false
            isConnected = true
            connTimes += 1
            onStateChange.notify(event: (isConnected, isReconnecting, nil))
        case .disconnected(_, let c):
            isConnected = false
            guard let code = GatewayCloseCode(rawValue: Int(c)) else {
                print("Unknown close code: \(c)")
                return
            }
            // Check if code isn't an unrecoverable code, then attempt resume
            if code != .authenthicationFail { attemptReconnect() }
            print("Gateway Disconnected: \(code)")
            onStateChange.notify(event: (isConnected, isReconnecting, code))
        case .text(let string): handleIncoming(received: string)
        case .error(let error):
            isConnected = false
            attemptReconnect()
            onStateChange.notify(event: (isConnected, isReconnecting, nil))
            print("Connection error: \(String(describing: error))")
        case .cancelled:
            isConnected = false
            onStateChange.notify(event: (isConnected, isReconnecting, nil))
        case .binary(_): break // Won't receive binary
        case .ping(_): break   // Don't care
        case .pong(_): break   // Don't care
        case .viabilityChanged(let viability):
            // If viability is false, reconnection will most likely fail
            print("Viability changed: \(viability)")
            if viability && !self.viability {
                // We should reconnect since connection is now viable
                attemptReconnect(resume: true, overrideViability: true)
            }
            self.viability = viability
        case .reconnectSuggested(_):
            print("Reconnect suggested!")
        }
    }
    
    func handleIncoming(received: String) {
        guard let decoded = try? JSONDecoder().decode(GatewayIncoming.self, from: received.data(using: .utf8)!)
        else { return }
        
        print(decoded)
        
        if (decoded.s != nil) { seq = decoded.s } // Update sequence
        
        switch (decoded.op) {
        case .heartbeat:
            // Immediately send heartbeat as requested
            print("Send heartbeat by server request")
            sendToGateway(op: .heartbeat, d: GatewayHeartbeat())
        case .hello:
            // Start heartbeating and send identify
            guard let d = decoded.d as? GatewayHello else { return }
            initHeartbeat(interval: d.heartbeat_interval)
        
            // Check if we're attempting to and can resume
            if isReconnecting && !doNotResume && sessionID != nil && seq != nil {
                print("Attempting resume")
                guard let resume = getResume(seq: seq!, sessionID: sessionID!)
                else { return }
                sendToGateway(op: .resume, d: resume)
            }
            else {
                print("Sending identify:", isConnected, !doNotResume, sessionID ?? "No sessionID", seq ?? -1)
                // Send identify
                seq = nil // Clear sequence #
                isReconnecting = false // Resuming failed/not attempted
                guard let identify = getIdentify() else {
                    print("TOKEN NOT IN KEYCHAIN!!!")
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
                cache?.guilds = d.guilds
                print("Gateway ready")
            default: break
            }
            onEvent.notify(event: (type, data))
        case .invalidSession:
            // Check if the session can be resumed
            let shouldResume = (decoded.primitiveData as? Bool) ?? false
            attemptReconnect(resume: shouldResume)
        default: print("Unimplemented opcode: \(decoded.op)")
        }
    }
}
