//
//  StringFormatting.swift
//  ProductVision
//
//  Created by David Hodge on 2/2/17.
//  Copyright © 2017 Genesis Apps. All rights reserved.
//

import Foundation

extension String {
    func stringByAddingPercentEncodingForRFC3986() -> String? {
        let unreserved = "-._~/?"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        return addingPercentEncoding( withAllowedCharacters: allowed as CharacterSet)
    }
}
