//
//  Heartbeat.swift
//  Native Discord
//
//  Created by Vincent Kwok on 22/2/22.
//

import Foundation

extension DiscordGateway {
    func initHeartbeat(interval: Int) {
        func sendHeartbeat(after: Int) {
            // Do not continue sending heartbeats to a dead connection
            guard isConnected else { return }
            
            sendToGateway(op: .heartbeat, d: GatewayHeartbeat())
            print("Sent heartbeat, missed ACKs: \(missedACK)")
            incMissedACK()
            
            // Connection is dead ☠️
            if (missedACK > missedACKTolerance) {
                socket.forceDisconnect()
                attemptReconnect()
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
}
