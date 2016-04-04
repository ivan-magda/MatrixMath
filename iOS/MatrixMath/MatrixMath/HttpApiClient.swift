//
//  JsonApiClient.swift
//  MatrixMath
//
//  Created by Ivan Magda on 31.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

//-------------------------------------
// MARK: Typealiases
//-------------------------------------

typealias DataTaskCompletionHandler = (data: NSData?, response: NSHTTPURLResponse?, error: NSError?) -> Void

//-------------------------------------
// MARK: - HttpApiClient
//-------------------------------------

class HttpApiClient {

    //---------------------------------
    // MARK: - Properties -
    //---------------------------------
    
    let configuration: NSURLSessionConfiguration
    
    lazy var session: NSURLSession = {
        return NSURLSession(configuration: self.configuration)
    }()
    
    var currentTasks: Set<NSURLSessionDataTask> = []
    
    /// If value is `true` then debug messages will be logged.
    var loggingEnabled = false
    
    //---------------------------------
    // MARK: - Initializers -
    //---------------------------------
    
    init(configuration: NSURLSessionConfiguration) {
        self.configuration = configuration
    }
    
    //---------------------------------
    // MARK: - Network -
    //---------------------------------
    
    func cancelAllRequests() {
        for task in self.currentTasks {
            task.cancel()
        }
        self.currentTasks = []
    }
    
    //---------------------------------
    // MARK: Data Tasks
    //---------------------------------
    
    func fetchData(request: NSURLRequest, completion: DataTaskCompletionHandler) {
        let task = dataTaskWithRequest(request, completion: completion)
        task.resume()
    }
    
    func dataTaskWithRequest(request: NSURLRequest, completion: DataTaskCompletionHandler) -> NSURLSessionDataTask {
        var task: NSURLSessionDataTask?
        task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            self.currentTasks.remove(task!)
            let httpResponse = response as! NSHTTPURLResponse
            
            /* GUARD: Was there an error? */
            guard error == nil else {
                self.debugLog("Received an error from HTTP \(request.HTTPMethod!) to \(request.URL!)")
                self.debugLog("Error: \(error)")
                completion(data: nil, response: httpResponse, error: error)
                return
            }
            
            self.debugLog("Received HTTP \(httpResponse.statusCode) from \(request.HTTPMethod!) to \(request.URL!)")
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                self.debugLog("Received an empty response")
                let userInfo = [NSLocalizedDescriptionKey: "No data was returned by the request"]
                completion(data: nil, response: httpResponse, error: NSError(domain: HttpApiClientError.EmptyResponseDomain,
                    code: HttpApiClientErrorCode.EmptyResponse, userInfo: userInfo))
                return
            }
            
            completion(data: data, response: httpResponse, error: nil)
        })
        
        currentTasks.insert(task!)
        
        return task!
    }
    
    //---------------------------------
    // MARK: Debug Logging
    //---------------------------------
    
    func debugLog(msg: String) {
        guard loggingEnabled else {
            return
        }
        debugPrint(msg)
    }
    
    func debugResponseData(data: NSData) {
        guard loggingEnabled else {
            return
        }
        
        if let body = String(data: data, encoding: NSUTF8StringEncoding) {
            print(body)
        } else {
            print("<empty response>")
        }
    }
    
}