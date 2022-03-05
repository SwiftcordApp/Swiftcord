//
//  Heartbeat.swift
//  Native Discord
//
//  Created by Vincent Kwok on 22/2/22.
//

import Foundation

extension DiscordGateway {
    func initHeartbeat(interval: Int) {
        let initialConnTimes = connTimes
        func sendHeartbeat() {
            sendToGateway(op: .heartbeat, d: GatewayHeartbeat())
            log.d("Sent heartbeat, missed ACKs: \(missedACK)")
            incMissedACK()
            
            // Connection is dead ☠️
            if (missedACK > missedACKTolerance) {
                socket.forceDisconnect()
                attemptReconnect()
            }
        }
        
        // First heartbeat delayed by jitter interval as per Discord docs
        let firstAfter = (Double(interval) * Double.random(in: 0...1)) / 1000
        log.i("Sending first heartbeat after \(firstAfter)s")
        DispatchQueue.main.asyncAfter(deadline: .now() + firstAfter) {
            sendHeartbeat()
            
            Timer.scheduledTimer(withTimeInterval: Double(interval) / Double(1000), repeats: true) { t in
                // Do not continue sending heartbeats to a dead connection
                // Also check that connection hasn't died between heartbeats
                guard self.isConnected && self.connTimes == initialConnTimes else {
                    t.invalidate()
                    return
                }
                sendHeartbeat()
            }
        }
    }
}
