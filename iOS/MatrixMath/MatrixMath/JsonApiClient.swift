//
//  JsonApiClient.swift
//  MatrixMath
//
//  Created by Ivan Magda on 31.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

//--------------------------------------
// MARK: - JsonApiClient: HttpApiClient
//--------------------------------------

class JsonApiClient: HttpApiClient {
    
    //----------------------------------
    // MARK: Data Tasks
    //----------------------------------
    
    func fetchData(request: NSURLRequest, completionHandler: ApiClientResult -> Void) {
        fetchData(request) { (data, httpResponse, error) in
            
            func sendError(error: NSError?, response: NSHTTPURLResponse) {
                self.debugLog(#function + "Received HTTP status code \(response.statusCode)")
                
                if let error = error {
                    completionHandler(.Error(error))
                }
                
                switch response.statusCode {
                case 404: completionHandler(.NotFound)
                case 400...499: completionHandler(.ClientError(response.statusCode))
                case 500...599: completionHandler(.ServerError(response.statusCode))
                default:
                    let statusCode = response.statusCode
                    print("Received HTTP status code \(statusCode), which was't be handled")
                    // Should not happen.
                    completionHandler(ApiClientResult.UnexpectedError(statusCode, error))
                }
            }
            
            /* GUARD: Was there an error? */
            guard error == nil else {
                sendError(error, response: httpResponse!)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = httpResponse?.statusCode
                where statusCode >= 200 && statusCode <= 299 else {
                self.debugLog("\(#function). Request returned a status code other than 2xx!")
                sendError(nil, response: httpResponse!)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                let userInfo = [NSLocalizedDescriptionKey: "No data was returned by the request"]
                let error =  NSError(domain: JsonApiClientError.EmptyResponseDomain,
                                     code: JsonApiClientErrorCode.EmptyResponse,
                                     userInfo: userInfo)
                sendError(error, response: httpResponse!)
                return
            }
            
            // Deserializing the JSON data.
            self.deserializeJSONDataWithCompletionHandler(data) { (jsonObject, error) in
                guard error == nil else {
                    sendError(error, response: httpResponse!)
                    return
                }
                
                // Try to give raw JSON a usable Foundation object form.
                guard let json = jsonObject as? JSONDictionary else {
                    let errorMessage = "Could not cast the JSON object as JSONDictionary: '\(jsonObject)'"
                    self.debugLog(errorMessage)
                    
                    let userInfo = [NSLocalizedDescriptionKey: errorMessage]
                    let error = NSError(domain: JsonApiClientError.JSONDeserializingDomain,
                                        code: JsonApiClientErrorCode.JSONDeserializing, userInfo: userInfo)
                    sendError(error, response: httpResponse!)
                    return
                }
                
                completionHandler(.Success(json))
            }
        }
    }
    
    //---------------------------------
    // MARK: Helpers
    //---------------------------------
    
    func deserializeJSONDataWithCompletionHandler(data: NSData, block: (AnyObject?, NSError?) -> Void) {
        var deserializedJSON: AnyObject?
        
        do {
            deserializedJSON = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            block(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        block(deserializedJSON, nil)
    }
    
}
