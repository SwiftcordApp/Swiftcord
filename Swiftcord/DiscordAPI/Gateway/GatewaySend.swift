//
//  SendToGateway.swift
//  Native Discord
//
//  Created by Vincent Kwok on 22/2/22.
//

import Foundation

/*extension DiscordGateway {
    func sendToGateway<T: OutgoingGatewayData>(op: GatewayOutgoingOpcodes, d: T?) {
        guard isConnected else { return }

        let sendPayload = GatewayOutgoing(op: op, d: d, s: seq)
        guard let encoded = try? JSONEncoder().encode(sendPayload)
        else { return }
        
        log.d("Outgoing Payload: <\(op)>", sendPayload.d != nil ? String(describing: sendPayload.d!) : "[No data]", "Seq:", String(describing: sendPayload.s))
        // socket.write(string: String(data: encoded, encoding: .utf8)!)
        socket.send(.data(encoded)) { err in
            self.log.i("Socket send completed")
            if let err = err {
                self.log.e("Socket send error:", err.localizedDescription)
            }
        }
    }
}*/