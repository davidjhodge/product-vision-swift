//
//  PVSessionManager.swift
//  ProductVision
//
//  Created by David Hodge on 2/1/17.
//  Copyright © 2017 Genesis Apps. All rights reserved.
//

import Foundation
import SWXMLHash
import ObjectMapper

typealias PVCompletionBlock = ((_ success: Bool, _ error: String?, _ response:Any?) -> Void)

class PVSessionManager: NSObject
{
    static let sharedManager: PVSessionManager = PVSessionManager()

    var googleCloudAPIKey: String?
    
    var awsAccessKeyId: String?
    
    var awsPKey: String?
    
    override init ()
    {
        super.init()
        
        print("Initializing Session")
        
        // Initialize Keys stored on client
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
            let keys = NSDictionary(contentsOfFile: path)
            
            if let googleKey = keys?.object(forKey: "googleCloudAPIKey") as? String
            {
                googleCloudAPIKey = googleKey
            }
            
            if let amazonKey = keys?.object(forKey: "AWSAccessKeyId") as? String
            {
                awsAccessKeyId = amazonKey
            }
            
            if let amazonPKey = keys?.object(forKey: "awsPKey") as? String
            {
                awsPKey = amazonPKey
            }
        }
    }
    
    // MARK: Public Methods
    
    func findSimilarProducts(image: UIImage, completionBlock: PVCompletionBlock?)
    {
        analyzeImage(image: image, completionHandler: {(success, error, response) -> Void in
            
            if success
            {
                if let logoName = response as? String
                {
                    self.searchAmazon(searchQuery: logoName, completionHandler: { (success, error, response) -> Void in
                        
                        if let completion = completionBlock
                        {
                            completion(success,error,response)
                        }
                    })
                }
            }
            else
            {
                // On error, passthrough completion block
                if let completion = completionBlock
                {
                    completion(success, error, response)
                }
            }
        })
    }
    
    // MARK: Google Cloud Vision
    
    // Analyze Image with Google Cloud Vision API
    private func analyzeImage(image: UIImage, completionHandler: PVCompletionBlock?) {
        
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
                                
                                return
                            }
                        }
                    }
                    else {
                        // No Logos were Detected
                        if let completion = completionHandler
                        {
                            completion(true, "We couldn't detect any items in that image.", nil)
                        }
                        
                        return
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
    func searchAmazon(searchQuery: String, completionHandler: PVCompletionBlock?)
    {        
        if let searchQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let responseGroup = "Images,ItemAttributes,Offers".stringByAddingPercentEncodingForRFC3986(),
            let dateString = Date().iso8601.stringByAddingPercentEncodingForRFC3986()
        {
            var params = [String]()
            
            params.append("AWSAccessKeyId=" + awsAccessKeyId!)
            params.append("AssociateTag=" + "PutYourAssociateTagHere")
            params.append("Keywords=" + searchQuery)
            params.append("Operation=" + "ItemSearch")
            params.append("ResponseGroup=" + responseGroup)
            params.append("SearchIndex=" + "All")
            params.append("Service=" + "AWSECommerceService")
            params.append("Timestamp=" + dateString)
            params.append("Version=" + "2011-08-01")

            params.sort()
            var paramString = params.joined(separator: "&")
            
            // Add signature with hmac256 encryption
            if let signature = awsSignature(paramString: paramString)
            {
                paramString += ("&Signature=" + signature)
            }
            
            // Build Request
            let url = URL(string: "http://ecs.amazonaws.com/onca/xml" + "?" + paramString)!

            var request = URLRequest(url: url)
  
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                
                if let dataString = String(data: data, encoding: .utf8)
                {
                    let xml = SWXMLHash.parse(dataString)
                    
                    var productDicts = Array<Dictionary<String,Any>>()
                    
                    xml["ItemSearchResponse"]["Items"]["Item"].all.map { item in
                     
                        var product = Dictionary<String,Any>()
                        
                        if let productTitle = item["ItemAttributes"]["Title"].element?.text
                        {
                            product["productTitle"] = productTitle
                        }
                        
                        if let productPrice = item["ItemAttributes"]["ListPrice"]["FormattedPrice"].element?.text
                        {
                            product["productPrice"] = productPrice                        }
                        
                        if let imageUrl = item["LargeImage"]["URL"].element?.text
                        {
                            product["imageUrl"] = imageUrl
                        }
                        
                        if let outboundUrl = item["DetailPageURL"].element?.text
                        {
                            product["outboundUrl"] = outboundUrl
                        }
                        
                        productDicts.append(product)
                    }
                    
                    // Serialize Products
                    let products = Mapper<Product>().mapArray(JSONArray: productDicts)
                    
                    if let completion = completionHandler
                    {
                        completion(true, "", products)
                    }
                    
                    return
                }
                
                if let completion = completionHandler
                {
                    completion(false, "Amazon search query did not return successfully.", nil)
                }
                
                return
            }
            
            task.resume()
            
        }
    }
    
    func awsSignature(paramString: String) -> String? {
        
        let stringToSign = "GET" + "\n" + "ecs.amazonaws.com" + "\n" + "/onca/xml" + "\n" + paramString
        
        let signature: String = stringToSign.hmac(algorithm: HMACAlgorithm.SHA256, key: awsPKey!).stringByAddingPercentEncodingForRFC3986()!

        return signature
    }
}
