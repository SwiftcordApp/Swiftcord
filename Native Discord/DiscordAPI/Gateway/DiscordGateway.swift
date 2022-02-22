//
//  DiscordGateway.swift
//  Native Discord
//
//  Created by Vincent Kwok on 20/2/22.
//

import Foundation
import Starscream

class DiscordGateway: WebSocketDelegate {
    // Events
    let onStateChange = EventDispatch<(Bool, Bool, GatewayCloseCode?)>()
    let onEvent = EventDispatch<(GatewayEvent, GatewayData)>()
    
    // Config
    let missedACKTolerance: Int
    
    // WebSocket object
    private(set) var socket: WebSocket!
    
    // State
    private(set) var isConnected = false
    private(set) var isResuming = false // Attempt to resume broken conn
    private(set) var missedACK = 0
    private(set) var seq: Int? = nil // Sequence int of latest received payload
    private var sessionID: String? = nil
    
    func incMissedACK() {
        missedACK += 1
    }
    
    // Attempt reconnection with resume after 1-5s as per spec
    func attemptReconnect(resume: Bool = true) {
        isResuming = resume
        DispatchQueue.main.asyncAfter(
            deadline: .now() +
            .milliseconds(1000 + Int(Double(4000) * Double.random(in: 0...1)))
        ) {
            self.socket.connect()
        }
    }
    
    init(connectionTimeout: Double = 5, maxMissedACK: Int = 3) {
        missedACKTolerance = maxMissedACK
        
        var request = URLRequest(url: URL(string: apiConfig.gateway)!)
        request.timeoutInterval = connectionTimeout
        socket = WebSocket(request: request)
        socket.delegate = self
        
        print("Attempting connection to Gateway: \(apiConfig.gateway)")
        socket.connect()
    }
    
    // MARK: Low level receive handler
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch (event) {
        case .connected(_):
            print("Gateway Connected")
            isConnected = true
            onStateChange.notify(event: (isConnected, isResuming, nil))
        case .disconnected(_, let c):
            isConnected = false
            guard let code = GatewayCloseCode(rawValue: Int(c)) else {
                print("Unknown close code: \(c)")
                return
            }
            // Check if code isn't an unrecoverable code, then attempt resume
            if code != .authenthicationFail { attemptReconnect() }
            print("Gateway Disconnected: \(code)")
            onStateChange.notify(event: (isConnected, isResuming, code))
        case .text(let string): handleIncoming(received: string)
        case .error(let error):
            isConnected = false
            attemptReconnect()
            onStateChange.notify(event: (isConnected, isResuming, nil))
            print("Connection error: \(String(describing: error))")
        case .cancelled:
            isConnected = false
            onStateChange.notify(event: (isConnected, isResuming, nil))
        case .binary(_): break // Won't receive binary
        case .ping(_): break   // Don't care
        case .pong(_): break   // Don't care
        case .viabilityChanged(_): break   // Ignore
        case .reconnectSuggested(_): break // Thanks but I choose to ignore your suggestion
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
            if isResuming && sessionID != nil && seq != nil {
                print("Attempting resume")
                guard let resume = getResume(seq: seq!, sessionID: sessionID!)
                else { return }
                sendToGateway(op: .resume, d: resume)
            }
            else {
                // Send identify
                seq = nil // Clear sequence #
                isResuming = false // Resuming failed/not attempted
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
                sessionID = d.session_id
                print("Gateway ready")
            default: break
            }
            onEvent.notify(event: (type, data))
        case .invalidSession:
            // Check if the session can be resumed
            guard let shouldResume = decoded.primitiveData as? Bool else { return }
            attemptReconnect(resume: shouldResume)
        default: print("Unimplemented opcode: \(decoded.op)")
        }
    }
}
