//
//  Eventable.swift
//  Native Discord
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

/// Create a nifty Event Emitter in Swift
/// Adapted from https://github.com/Azoy/Sword/blob/master/Sources/Sword/Gateway/Eventable.swift

// TODO: Make event enum type generic
/*public protocol Eventable: AnyObject {
    /// Event Listeners
    var listeners: [GatewayEvent: [(Any) -> ()]] { get set }

    /**
     - parameter event: Event to listen for
     */
    func on(_ event: GatewayEvent, do function: @escaping (Any) -> ()) -> Int

    /**
     - parameter event: Event to emit
     - parameter data: Array of stuff to emit listener with
     */
    func emit(_ event: GatewayEvent, with data: Any)
}

extension Eventable {
    /**
    Listens for eventName
    - parameter event: Event to listen for
    */
    @discardableResult
    public func on(_ event: GatewayEvent, do function: @escaping (Any) -> ())
    -> Int {
        guard self.listeners[event] != nil else {
          self.listeners[event] = [function]
          return 0
        }

        self.listeners[event]!.append(function)

        return self.listeners[event]!.count - 1
    }

    /**
    Emits all listeners for eventName
    - parameter event: Event to emit
    - parameter data: Stuff to emit listener with
    */
    public func emit(_ event: GatewayEvent, with data: Any = ()) {
        guard let listeners = self.listeners[event] else { return }
        for listener in listeners {
            listener(data)
        }
    }
}
*/
