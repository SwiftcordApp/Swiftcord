//
//  Logger.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 1/3/22.
//

import Foundation

#if DEBUG
enum LogLevel { // In increasing levels of importance
    case silly // Very verbose debug messages
    case debug // Stuff for when you're sorting out an issue
    case info  // Typical log messages
    case warn  // Not an error, but something that shouldn't happen
    case error // Non-fatal errors
    case crit  // Unrecoverable errors
}

class Logger {
    let tag: String
    
    init(tag: String) {
        self.tag = tag
    }
    
    private func log(level: LogLevel, _ items: [Any]) {
        let s = items.map { String(describing: $0) }.joined(separator: " ")
        print("<\(String(describing: level).first?.uppercased() ?? "D")> [\(tag)] \(s)")
    }
    
    public func s(_ items: Any...) { log(level: .silly, items) }
    public func d(_ items: Any...) { log(level: .debug, items) }
    public func i(_ items: Any...) { log(level: .info, items) }
    public func w(_ items: Any...) { log(level: .warn, items) }
    public func e(_ items: Any...) { log(level: .error, items) }
    public func c(_ items: Any...) { log(level: .crit, items) }
}
#endif
