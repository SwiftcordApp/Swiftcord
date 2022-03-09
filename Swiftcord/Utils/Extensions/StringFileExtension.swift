//
//  StringFileExtension.swift
//  Native Discord
//
//  Created by Vincent Kwok on 24/2/22.
//

import Foundation

extension String {
    var fileExtension: String {
        get { return NSString(string: self).pathExtension }
        set {}
    }
}
