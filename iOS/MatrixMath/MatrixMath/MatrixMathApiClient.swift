//
//  MatrixMathApiClient.swift
//  MatrixMath
//
//  Created by Ivan Magda on 31.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

typealias MatrixMathAPIClientMatrixResultBlock = (matrix: Matrix?, error: NSError?) -> Void
typealias MatrixMathAPIClientSolutionResultBlock = (vector: Array<Double>?, error: NSError?) -> Void

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
    
    func addition(left lft: Matrix, right rgh: Matrix, completionHandler: MatrixMathAPIClientMatrixResultBlock) {
        let body = bodyForBinaryOperation(left: lft, right: rgh)
        let request = postRequestWithParameters(nil, path: Method.Addition, body: body)
        fetchData(request) { (result: ApiClientResult) in
            self.processOnApiClientResult(result, withCompletionHandler: completionHandler)
        }
    }
    
    func subtract(left lft: Matrix, right rgh: Matrix, completionHandler: MatrixMathAPIClientMatrixResultBlock) {
        let body = bodyForBinaryOperation(left: lft, right: rgh)
        let request = postRequestWithParameters(nil, path: Method.Subtract, body: body)
        fetchData(request) { (result: ApiClientResult) in
            self.processOnApiClientResult(result, withCompletionHandler: completionHandler)
        }
    }
    
    func multiply(left lft: Matrix, right rgh: Matrix, completionHandler: MatrixMathAPIClientMatrixResultBlock) {
        let body = bodyForBinaryOperation(left: lft, right: rgh)
        let request = postRequestWithParameters(nil, path: Method.Multiply, body: body)
        fetchData(request) { (result: ApiClientResult) in
            self.processOnApiClientResult(result, withCompletionHandler: completionHandler)
        }
    }
    
    func transpose(matrix matrix: Matrix, completionHandler: MatrixMathAPIClientMatrixResultBlock) {
        let body = bodyForUnaryOperation(matrix)
        let request = postRequestWithParameters(nil, path: Method.Transpose, body: body)
        fetchData(request) { (result: ApiClientResult) in
            self.processOnApiClientResult(result, withCompletionHandler: completionHandler)
        }
    }
    
    // TODO: Implement
    func determinant(matrix matrix: Matrix, completionHandler: (Int?, NSError?) -> Void) {
        let body = bodyForUnaryOperation(matrix)
        let request = postRequestWithParameters(nil, path: Method.Determinant, body: body)
        fetchData(request) { (result: ApiClientResult) in
            //self.processOnApiClientResult(result, withCompletionHandler: completionHandler)
        }
    }
    
    func invert(matrix matrix: Matrix, completionHandler: MatrixMathAPIClientMatrixResultBlock) {
        let body = bodyForUnaryOperation(matrix)
        let request = postRequestWithParameters(nil, path: Method.Invert, body: body)
        fetchData(request) { (result: ApiClientResult) in
            self.processOnApiClientResult(result, withCompletionHandler: completionHandler)
        }
    }
    
    // TODO: Implement
    func solve(coefficientsMatrix matrix: Matrix, valuesVector vector: Array<Double>, completionHandler: MatrixMathAPIClientSolutionResultBlock) {
        let body = "{\"\(JSONBodyKey.Matrix)\": \(matrix.data), \"\(JSONBodyKey.VectorOfValues)\": \(vector)}"
        let request = postRequestWithParameters(nil, path: Method.SolveSystem, body: body)
        fetchData(request) { (result: ApiClientResult) in
            //self.processOnApiClientResult(result, withCompletionHandler: completionHandler)
        }
    }
    
    // TODO: Implement
    func solveWithErrorCorrection(coefficientsMatrix matrix: Matrix, valuesVector vector: Array<Double>, completionHandler: MatrixMathAPIClientSolutionResultBlock) {
        let body = "{\"\(JSONBodyKey.Matrix)\": \(matrix.data), \"\(JSONBodyKey.VectorOfValues)\": \(vector)}"
        let request = postRequestWithParameters(nil, path: Method.SolveSystemWithErrorCorrection, body: body)
        fetchData(request) { (result: ApiClientResult) in
            //self.processOnApiClientResult(result, withCompletionHandler: completionHandler)
        }
    }
    
    //-----------------------------------
    // MARK: Helpers
    //-----------------------------------
    
    private func bodyForUnaryOperation(matrix: Matrix) -> String {
        return "{\"\(JSONBodyKey.Matrix)\": \(matrix.data)}"
    }
    
    private func bodyForBinaryOperation(left lft: Matrix, right rgh: Matrix) -> String {
        return "{\"\(JSONBodyKey.Left)\": \(lft.data), \"\(JSONBodyKey.Right)\": \(rgh.data)}"
    }
    
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
    
    private func processOnApiClientResult(result: ApiClientResult, withCompletionHandler completionHandler: MatrixMathAPIClientMatrixResultBlock) {
        func sendError(error: String) {
            let userInfo = [NSLocalizedDescriptionKey: error]
            let error = NSError(domain: MatrixMathApiClient.ErrorDomain,
                                code: MatrixMathApiClient.ErrorCode,
                                userInfo: userInfo)
            completionHandler(matrix: nil, error: error)
        }
        
        switch result {
        case .Success(let json):
            /* GUARD: Did we get a successful 200 status code? */
            guard let statusCode = json[JSONResponseKey.StatusCode] as? Int
                where statusCode == 200 else {
                    let message = json[JSONResponseKey.StatusMessage] as! String
                    self.debugLog("Server return an error with message: \(message)")
                    sendError(message)
                return
            }
            
            self.debugLog("Successfully received a result from the server with status code 200.")
            
            /* GUARD: Decodes a matrix object from JSONDictionary */
            guard let matrix = Matrix.decode(json) else {
                sendError("Could not create Matrix from JSON data")
                return
            }
            
            completionHandler(matrix: matrix, error: nil)
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
