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
    
    var googleCloudAPIKey: String?
    
    override init ()
    {
        super.init()
        
        print("Initializing Session")
        
        //initialize alamofire network manager
        let configuration = URLSessionConfiguration.default
        configuration.httpMaximumConnectionsPerHost = 10
        configuration.timeoutIntervalForRequest = 30
        
        networkManager = SessionManager(configuration: configuration)
        
        // Initialize Keys stored on client
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
            let keys = NSDictionary(contentsOfFile: path)
            
            if let storedKey = keys?.object(forKey: "googleCloudAPIKey") as? String
            {
                googleCloudAPIKey = storedKey
            }
        }
    }
    
    // MARK: Google Cloud Vision
    
    // Analyze Image with Google Cloud Vision API
    func analyzeImage(image: UIImage, completionHandler: PVCompletionBlock?) {
        
        let base64String = base64EncodeImage(image)
        
        let url = URL(string: "https://vision.googleapis.com/v1/images:annotate?key=" + googleCloudAPIKey!)!
        
        var request = URLRequest(url: url)
        
        // Create HTTP Body payload
        let jsonBody: [String:Any] = [
            "requests": [
                "image": [
                    "content": base64String
                ],
                "features": [
                    [
                        "type": "LOGO_DETECTION",
                        "maxResults": 10
                    ]
                ]
            ]
        ]
        
        let bodyData = try? JSONSerialization.data(withJSONObject: jsonBody)
        
        request.httpBody = bodyData
        
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                
                // Extract top logo out of results
                if let responses = responseJSON["responses"] as? Array<Dictionary<String,AnyObject>>
                {
                    let firstResponse = responses[0]
                    
                    if let logoAnnotations = firstResponse["logoAnnotations"]  as? Array<Dictionary<String,AnyObject>>
                    {
                        // RESPONSES EXIST
                        
                        // Get the logo name of the top match
                        let topLabel = logoAnnotations[0]
                        
                        if let logoName = topLabel["description"] as? String
                        {
                            if let completion = completionHandler
                            {
                                print(logoName)
                                completion(true, "", logoName)
                            }
                        }
                    }
                    else {
                        // No Logos were Detected
                        if let completion = completionHandler
                        {
                            completion(true, "We couldn't detect any items in that image.", nil)
                        }
                    }
                }
                
                if let completion = completionHandler
                {
                    completion(true, "", responseJSON)
                }
                
                return
            }
        }
        
        task.resume()
    }
    
    // Base64 Helper
    func base64EncodeImage(_ image: UIImage) -> String {
        var imagedata = UIImagePNGRepresentation(image)
        
        // Resize the image if it exceeds the 2MB API limit
        if let byteLength = imagedata?.count
        {
            if (byteLength > 2097152) {
                let oldSize: CGSize = image.size
                let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
                imagedata = resizeImage(newSize, image: image)
            }
        }

        return imagedata!.base64EncodedString(options: .endLineWithCarriageReturn)
    }
    
    // Resize Image helper
    func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage!)
        UIGraphicsEndImageContext()
        return resizedImage!
    }
    
    // MARK: Amazon Search
    
}
