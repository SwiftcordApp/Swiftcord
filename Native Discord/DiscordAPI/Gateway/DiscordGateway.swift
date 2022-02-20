//
//  DiscordGateway.swift
//  Native Discord
//
//  Created by Vincent Kwok on 20/2/22.
//

import Foundation
import Starscream

class DiscordGateway: WebSocketDelegate {
    private var socket: WebSocket
    private(set) var isConnected = false
    private var seq: Int? = nil
    
    init(connectionTimeout: Double = 5) {
        var request = URLRequest(url: URL(string: apiConfig.gateway)!)
        request.timeoutInterval = connectionTimeout
        socket = WebSocket(request: request)
        socket.delegate = self
        
        print("Attempting connection to Gateway: \(apiConfig.gateway)")
        socket.connect()
    }
    
    func initHeartbeat(interval: Int) {
        func sendHeartbeat() {
            socket.write(data: "")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(interval)) {
                sendHeartbeat()
            }
        }
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() +
            .milliseconds(Int(Double(interval) * Double.random(in: 0...1)))
        ) { // First heartbeat delayed by jitter interval as per Discord docs
            sendHeartbeat()
        }
    }
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch (event) {
        case .connected(_):
            print("Connected")
            isConnected = true
            break
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            handleIncoming(received: string)
        case .error(let error):
            isConnected = false
            print("Connection error: \(String(describing: error))")
        case .cancelled:
        isConnected = false
        break
        case .binary(_): break // Won't receive binary
        case .ping(_): break
        case .pong(_): break
        case .viabilityChanged(_): break
        case .reconnectSuggested(_): break
        }
    }
    
    func handleIncoming(received: String) {
        // Should handle exceptions in the future
        guard let decoded = try? JSONDecoder().decode(GatewayIncoming.self, from: received.data(using: .utf8)!)
        else {
            return
        }
        
        print(decoded)
        switch (decoded.op) {
        case .hello:
            print("Gateway hello, init heartbeat")
            initHeartbeat(interval: decoded.d.heartbeat_interval)
            break;
        default:
            print("Unimplimented opcode: \(decoded.op)")
        }
    }
}
