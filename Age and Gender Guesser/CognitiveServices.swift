//
//  CognitiveServices.swift
//  Age and Gender Guesser
//
//  Created by Shane Jackson on 2017-04-11.
//  Copyright © 2017 Shane Jackson. All rights reserved.
//

import Foundation
import UIKit

/// Result closure type for callbacks. The first parameter is an array of suitable tags for the image.
typealias CognitiveServicesFacesResult = ([String]?, NSError?) -> (Void)

let CognitiveServicesComputerVisionAPIKey = "e256ef3fbce54ddea8789a758353cef6"

enum CognitiveServicesHTTPMethod {
    static let POST = "POST"
}

enum CognitiveServicesHTTPHeader {
    static let SubscriptionKey = "Ocp-Apim-Subscription-Key"
    static let ContentType = "Content-Type"
}

enum CognitiveServicesHTTPParameters {
    static let VisualFeatures = "visualFeatures"
    static let Details = "details"
}

enum CognitiveServicesHTTPContentType {
    static let JSON = "application/json"
    static let OctetStream = "application/octet-stream"
    static let FormData = "multipart/form-data"
}

enum CognitiveServicesVisualFeatures {
    static let Faces = "Faces"
}


enum CognitiveServicesKeys {
    static let Faces = "faces"
}

enum CognitiveServicesConfiguration {
    static let AnalyzeURL = "https://api.projectoxford.ai/vision/v1.0/analyze"
    static let JPEGCompressionQuality = 0.9 as CGFloat
}

class CognitiveServicesManager: NSObject {
    
    /**
     Retrieves a list of suitable tags for a given image from Microsoft's Cognitive Services API.
     */
    func retrievePlausibleTagsForImage(_ image: UIImage, completion: @escaping CognitiveServicesFacesResult) {
        
        var urlString = CognitiveServicesConfiguration.AnalyzeURL
        urlString += "?\(CognitiveServicesHTTPParameters.VisualFeatures)=\("\(CognitiveServicesVisualFeatures.Faces)")"
        
        let url = URL(string: urlString)
        let request = NSMutableURLRequest(url: url!)
        
        // The subscription key is always added as an HTTP header field.
        request.addValue(CognitiveServicesComputerVisionAPIKey, forHTTPHeaderField: CognitiveServicesHTTPHeader.SubscriptionKey)
        
        //  Specify that we're sending the image as binary data
        
        request.addValue(CognitiveServicesHTTPContentType.OctetStream, forHTTPHeaderField: CognitiveServicesHTTPHeader.ContentType)
        
        let requestData = UIImageJPEGRepresentation(image, CognitiveServicesConfiguration.JPEGCompressionQuality)
        request.httpBody = requestData
        request.httpMethod = CognitiveServicesHTTPMethod.POST
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if let data = data {
                do {
                    let collectionObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                    var result = [String]()
                    
                    if let dictionary = collectionObject as? Dictionary<String, AnyObject> {
                        
                        let tags = dictionary[CognitiveServicesKeys.Faces]
                        if let typedTags = tags as? Array<Dictionary<String, AnyObject>> {
                            for tag in typedTags {
                                let name = tag["gender"]
                                let age = tag["age"]?.stringValue
                                result.append(name! as! String)
                                result.append(age! )
                            }
                        }
                    }
                    
                    completion(result, nil)
                    return
                }
                catch _ {
                    completion(nil, error as NSError?)
                    return
                }
            } else {
                completion(nil, nil)
                return
            }
        }
        
        task.resume()
    }
}
