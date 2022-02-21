//
//  DiscordGateway.swift
//  Native Discord
//
//  Created by Vincent Kwok on 20/2/22.
//

import Foundation
import Starscream

class DiscordGateway: WebSocketDelegate {
    private let missedACKTolerance: Int
    
    private var socket: WebSocket!
    
    private(set) var isConnected = false
    private(set) var isResuming = false // Attempt to resume broken conn
    private(set) var sessionInvalid = false // Invalid session
    private var seq: Int? = nil // Sequence int of latest received payload
    private var missedACK = 0
    
    init(connectionTimeout: Double = 5, maxMissedACK: Int = 3) {
        missedACKTolerance = maxMissedACK
        
        var request = URLRequest(url: URL(string: apiConfig.gateway)!)
        request.timeoutInterval = connectionTimeout
        socket = WebSocket(request: request)
        socket.delegate = self
        
        print("Attempting connection to Gateway: \(apiConfig.gateway)")
        socket.connect()
    }
    
    func initHeartbeat(interval: Int) {
        func sendHeartbeat(after: Int) {
            // Do not continue sending heartbeats to a dead connection
            guard isConnected else { return }
            
            sendToGateway(op: .heartbeat, d: GatewayHeartbeat())
            print("Sent heartbeat, missed ACKs: \(missedACK)")
            missedACK += 1
            
            // Connection is dead ☠️
            if (missedACK > missedACKTolerance) {
                socket.forceDisconnect()
                isResuming = true
                // socket.connect()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(after)) {
                sendHeartbeat(after: after)
            }
        }
        
        // First heartbeat delayed by jitter interval as per Discord docs
        DispatchQueue.main.asyncAfter(
            deadline: .now() +
            .milliseconds(Int(Double(interval) * Double.random(in: 0...1)))
        ) {
            sendHeartbeat(after: interval)
        }
    }
    
    func sendToGateway<T: GatewayData>(op: GatewayOutgoingOpcodes, d: T?) {
        guard isConnected else { return }

        let sendPayload = GatewayOutgoing(op: op, d: d, s: seq)
        guard let encoded = try? JSONEncoder().encode(sendPayload)
        else { return }
        
        print(sendPayload)
        socket.write(string: String(data: encoded, encoding: .utf8)!)
    }
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch (event) {
        case .connected(_):
            print("Gateway Connected")
            isConnected = true
            break
        case .disconnected(let reason, let code):
            isConnected = false
            print("Gateway Disconnected: \(reason) with code: \(code)")
            break
        case .text(let string):
            handleIncoming(received: string)
            break
        case .error(let error):
            isConnected = false
            print("Connection error: \(String(describing: error))")
            break
        case .cancelled:
            isConnected = false
            break
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
            break
        case .hello:
            // Start heartbeating and send identify
            guard let d = decoded.d as? GatewayHello else { return }
            initHeartbeat(interval: d.heartbeat_interval)
            
            guard let identify = getIdentify() else {
                print("TOKEN NOT IN KEYCHAIN!!!")
                return
            }
            sendToGateway(op: .identify, d: identify)
            break;
        case .heartbeatAck:
            missedACK = 0
            break;
        case .dispatchEvent:
            guard let type = decoded.t else { return }
            guard let data = decoded.d else { return }
            dispatchGatewayEvent(type: type, data: data)
            break
        case .invalidSession:
            // Check if the session can be resumed
            guard let shouldResume = decoded.primitiveData as? Bool else { return }
            if shouldResume { isResuming = true }
            else { sessionInvalid = true }
            break
        default:
            print("Unimplemented opcode: \(decoded.op)")
        }
    }
}
