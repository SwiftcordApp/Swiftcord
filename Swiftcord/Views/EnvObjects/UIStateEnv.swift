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

class UIState: ObservableObject, Equatable {
    @Published var loadingState: LoadingState = .initial
    @Published var attemptLogin = false
    @Published var selfMute = false
	@Published var selfDeaf = false

	static func == (lhs: UIState, rhs: UIState) -> Bool {
		return lhs.loadingState == rhs.loadingState &&
		lhs.attemptLogin == rhs.attemptLogin &&
		lhs.selfMute == rhs.selfMute &&
		lhs.selfDeaf == rhs.selfDeaf
	}
}
