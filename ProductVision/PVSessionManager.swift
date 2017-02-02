//
//  PVSessionManager.swift
//  ProductVision
//
//  Created by David Hodge on 2/1/17.
//  Copyright © 2017 Genesis Apps. All rights reserved.
//

import Foundation
import Alamofire

typealias PVCompletionBlock = ((_ success: Bool, _ error: String?, _ response:Any?) -> Void)

class PVSessionManager: NSObject
{
    static let sharedManager: PVSessionManager = PVSessionManager()

    // Intialized in the init method and is never deallocated. It is assumed to always exist
    var networkManager: SessionManager!
    
    override init ()
    {
        super.init()
        
        print("Initializing Session")
        
        //initialize alamofire network manager
        let configuration = URLSessionConfiguration.default
        configuration.httpMaximumConnectionsPerHost = 10
        configuration.timeoutIntervalForRequest = 30
        
        networkManager = SessionManager(configuration: configuration)
    }
    
    func analyzeImage(_ completionHandler: PVCompletionBlock?) {
        
        Alamofire.request("https://httpbin.org/get").responseJSON { response in
            print(response.request)  // original URL request
            print(response.response) // HTTP URL response
            print(response.data)     // server data
            print(response.result)   // result of response serialization
            
            if let JSON = response.result.value {
                print("JSON: \(JSON)")
            }
        }
        
        if let completion = completionHandler {
            completion(true, "", nil)
        }
    }
    
    
}
