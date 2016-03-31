//
//  MatrixMathApiClient.swift
//  MatrixMath
//
//  Created by Ivan Magda on 31.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

typealias ArrayOfArrays = Array<Array<Double>>
typealias MatrixOperationResultBlock = (json: JSONDictionary?, error: NSError?) -> Void

//--------------------------------------------
// MARK: - MatrixMathApiClient: JsonApiClient
//--------------------------------------------

class MatrixMathApiClient: JsonApiClient {
    
    //-----------------------------------
    // MARK: Properties
    //-----------------------------------
    
    static var sharedInstance: MatrixMathApiClient = {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        let client = MatrixMathApiClient(configuration: configuration)
        client.loggingEnabled = true
        
        return client
    }()
    
    //-----------------------------------
    // MARK: API Methods
    //-----------------------------------
    
    func addition(left: ArrayOfArrays, right: ArrayOfArrays, completionHandler: MatrixOperationResultBlock) {
        let body = "{\"\(JSONBodyKey.Left)\": \(left), \"\(JSONBodyKey.Right)\": \(right)}"
        let request = postRequestWithParameters(nil, path: Method.Addition, body: body)
        fetchData(request) { (result: ApiClientResult) in
            self.processOnApiClientResult(result, withCompletionHandler: completionHandler)
        }
    }
    
    //-----------------------------------
    // MARK: Helpers
    //-----------------------------------
    
    private func postRequestWithParameters(params: [String: AnyObject]?, path: String?, body: String) -> NSURLRequest {
        let request = NSMutableURLRequest(URL: destiantionURLFromParameters(params, pathExtension: path))
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        request.HTTPMethod = HTTTPMethodName.Post
        
        return request as NSURLRequest
    }
    
    /**
     Creates a URL from parameters.
     
     - parameter parameters: Parameters to be applied to the destiantion URL.
     
     - parameter pathExtension: Path extension to be applied to the destiantion URL.
     
     - returns: Builded destiantion URL.
     */
    private func destiantionURLFromParameters(parameters: [String: AnyObject]?, pathExtension: String? = nil) -> NSURL {
        let components = NSURLComponents()
        components.scheme = Constant.ApiScheme
        components.host = Constant.ApiHost
        components.path = Constant.ApiPath + (pathExtension ?? "")
        
        if let parameters = parameters {
            components.queryItems = [NSURLQueryItem]()
            for (key, value) in parameters {
                let queryItem = NSURLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        
        return components.URL!
    }
    
    private func processOnApiClientResult(result: ApiClientResult, withCompletionHandler completionHandler: MatrixOperationResultBlock) {
        func sendError(error: String) {
            let userInfo = [NSLocalizedDescriptionKey: error]
            let error = NSError(domain: MatrixMathApiClient.ErrorDomain,
                                code: MatrixMathApiClient.ErrorCode,
                                userInfo: userInfo)
            completionHandler(json: nil, error: error)
        }
        
        switch result {
        case .Success(let json):
            completionHandler(json: json, error: nil)
        case .Error(let error):
            sendError(error.localizedDescription)
        case .NotFound:
            sendError("Failed to be able to communicate with a given server.")
        case .ServerError(let code):
            sendError("Server error with code: \(code).")
        case .ClientError(let code):
            sendError("Client's error with code: \(code). Please try again later.")
        case .UnexpectedError(let code, let error):
            sendError("There is unexpected error: \(error?.localizedDescription), code: \(code).")
        }
    }
    
}
