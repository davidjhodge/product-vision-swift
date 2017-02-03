//
//  Product.swift
//  ProductVision
//
//  Created by David Hodge on 2/1/17.
//  Copyright © 2017 Genesis Apps. All rights reserved.
//

import Foundation
import ObjectMapper

class Product: AnyObject, Mappable
{
    var imageUrl: URL?
    
    var productTitle: String?
    
    var productPrice: String?
    
    var outboundUrlString: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map)
    {
        imageUrl                   <- (map["imageUrl"], URLTransform())
        productTitle               <- map["productTitle"]
        productPrice               <- map["productPrice"]
        outboundUrlString          <- map["outboundUrl"]
    }
}
