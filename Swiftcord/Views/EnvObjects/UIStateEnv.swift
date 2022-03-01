//
//  UIStateEnv.swift
//  Native Discord
//
//  Created by Vincent Kwok on 27/2/22.
//

import Foundation

enum LoadingState {
    case initial
    case gatewayConn
    case initialGuildLoad
    case selGuildLoad
    case channelLoad
    case messageLoad
}

class UIState: ObservableObject {
    @Published var loadingState: LoadingState = .initial
}
