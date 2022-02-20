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
    
    init(connectionTimeout: Double = 5) {
        var request = URLRequest(url: URL(string: apiConfig.gateway)!)
        request.timeoutInterval = connectionTimeout
        socket = WebSocket(request: request)
        socket.delegate = self
        
        print("Attempting connection to Gateway: \(apiConfig.gateway)")
        socket.connect()
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
        print(try! JSONDecoder().decode(GatewayIncoming.self, from: received.data(using: .utf8)!) )
    }
}
