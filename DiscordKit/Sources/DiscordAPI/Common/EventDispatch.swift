/// EventDispatch.swift
/// Adapted from: https://github.com/gongzhang/swift-event-dispatch
///
/// Unfortunately the code isn't exactly fully compatible with Swift 5
/// Changes were made to improve style and to remove all warnings/errors
/// Adds optimisations to reduce

import Foundation

public class EventDispatch<Event>: EventDispatchProtocol {
    public typealias HandlerIdentifier = Int
    
    private typealias Handler = (Event) -> ()
    private var handlerIds = [HandlerIdentifier]()
    private var handlers = [Handler]()
    private var lastId: HandlerIdentifier = 0
    
    private let evtQueue: DispatchQueue
    
    public init() {
        evtQueue = DispatchQueue(label: UUID().uuidString, qos: .userInteractive, attributes: .concurrent, target: .main)
    }
    
    public func addHandler(handler: @escaping (Event) -> ()) -> HandlerIdentifier {
        lastId += 1
        handlerIds.append(lastId)
        handlers.append(handler)
        return lastId
    }
    
    public func handleOnce(handler: @escaping (Event) -> ()) {
        var id: HandlerIdentifier!
        id = addHandler { [weak self] event in
            handler(event)
            _ = self?.removeHandler(handler: id)
        }
    }
    
    public func removeHandler(handler: HandlerIdentifier) -> Bool {
        if let index = handlerIds.firstIndex(of: handler) {
            handlerIds.remove(at: index)
            let _ = handlers.remove(at: index)
            return true
        } else {
            return false
        }
    }
    
    public func notify(event: Event) {
        let copiedHandlers = handlers
        for handler in copiedHandlers {
            evtQueue.async { handler(event) }
        }
    }
}

public protocol EventDispatchProtocol {
    associatedtype EventType
    func notify(event: EventType)
}

public extension EventDispatchProtocol where EventType: Equatable {
    func notifyIfChanged(old: EventType, new: EventType) {
        if old != new {
            notify(event: new)
        }
    }
}

public extension EventDispatchProtocol where EventType == Void {
    func notify() {
        notify(event: ())
    }
}
