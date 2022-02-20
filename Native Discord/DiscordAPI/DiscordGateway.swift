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
        var request = URLRequest(url: URL(string: "http://localhost:8080")!)
        request.timeoutInterval = connectionTimeout
        socket = WebSocket(request: request)
        socket.delegate = self
    }
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch (event) {
        case .connected(let headers):
            print("Connected, headers: \(headers)")
            isConnected = true
            break
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            print("Received text: \(string)")
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
        case .error(let error):
            isConnected = false
            print("Connection error: \(String(describing: error))")
        }
    }
}
