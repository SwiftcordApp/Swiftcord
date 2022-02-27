//
//  UIStateEnv.swift
//  Native Discord
//
//  Created by Vincent Kwok on 27/2/22.
//

import Foundation

enum LoadingState: Int {
    case initial = 0
    case gatewayConn = 1
    case initialGuildLoad = 2
    case selGuildLoad = 3
    case channelLoad = 4
    case messageLoad = 5
}

class UIState: ObservableObject {
    @Published var loadingState: LoadingState = .initial
}
