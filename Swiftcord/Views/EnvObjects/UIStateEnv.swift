//
//  UIStateEnv.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 27/2/22.
//

import Foundation

enum LoadingState {
    case initial
    case gatewayConn
    case messageLoad
}

class UIState: ObservableObject {
    @Published var loadingState: LoadingState = .initial
    @Published var attemptLogin = false
    @Published var selfMute = false
	@Published var selfDeaf = false
}
