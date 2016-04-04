//
//  MatrixMathApiClient.swift
//  MatrixMath
//
//  Created by Ivan Magda on 31.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

//--------------------------------------------
// MARK: Typealiases
//--------------------------------------------

typealias MatrixMathMatrixResultBlock = (matrix: Matrix?, error: NSError?) -> Void
typealias MatrixMathSystemSolutionResultBlock = (vector: Array<Double>?, error: NSError?) -> Void
typealias MatrixMathValueResultBlock = (result: Double?, error: NSError?) -> Void

private typealias ProcessOnApiClientResultBlock = (json: JSONDictionary?, error: NSError?) -> Void

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
    // MARK: - API Methods -
    // MARK: Binary Operations
    //-----------------------------------
    
    func addition(left lft: Matrix, right rgh: Matrix, completionHandler: MatrixMathMatrixResultBlock) {
        executeMatrixBinaryOperationForMethod(Method.Addition, left: lft, right: rgh, completionHandler: completionHandler)
    }
    
    func subtract(left lft: Matrix, right rgh: Matrix, completionHandler: MatrixMathMatrixResultBlock) {
        executeMatrixBinaryOperationForMethod(Method.Subtract, left: lft, right: rgh, completionHandler: completionHandler)
    }
    
    func multiply(left lft: Matrix, right rgh: Matrix, completionHandler: MatrixMathMatrixResultBlock) {
        executeMatrixBinaryOperationForMethod(Method.Multiply, left: lft, right: rgh, completionHandler: completionHandler)
    }

    //-----------------------------------
    // MARK: Unary Operations
    //-----------------------------------
    
    func transpose(matrix matrix: Matrix, completionHandler: MatrixMathMatrixResultBlock) {
        executeMatrixUnaryOperationForMethod(Method.Transpose, matrix: matrix) { (json, error) in
            self.retrieveMatrixFromJSON(json, error: error, completionHandler: completionHandler)
        }
    }
    
    func invert(matrix matrix: Matrix, completionHandler: MatrixMathMatrixResultBlock) {
        executeMatrixUnaryOperationForMethod(Method.Invert, matrix: matrix) { (json, error) in
            self.retrieveMatrixFromJSON(json, error: error, completionHandler: completionHandler)
        }
    }
    
    func determinant(matrix matrix: Matrix, completionHandler: MatrixMathValueResultBlock) {
        executeMatrixUnaryOperationForMethod(Method.Determinant, matrix: matrix) { (json, error) in
            guard error == nil && json != nil else {
                completionHandler(result: nil, error: error)
                return
            }
            
            guard let determinant = json![JSONResponseKey.Result] as? Double else {
                completionHandler(result: nil, error: error)
                return
            }
            
            completionHandler(result: determinant, error: nil)
        }
    }
    
    //---------------------------------------------------
    // MARK: Solves a system of linear equations: Ax = b
    //---------------------------------------------------
    
    func solve(coefficientsMatrix matrix: Matrix, valuesVector vector: Array<Double>, completionHandler: MatrixMathSystemSolutionResultBlock) {
        executeMatrixSolveOperationForMethod(Method.SolveSystem, coefficientsMatrix: matrix, valuesVector: vector, completionHandler: completionHandler)
    }
    
    func solveWithErrorCorrection(coefficientsMatrix matrix: Matrix, valuesVector
        vector: Array<Double>, completionHandler: MatrixMathSystemSolutionResultBlock) {
        executeMatrixSolveOperationForMethod(Method.SolveSystemWithErrorCorrection, coefficientsMatrix: matrix, valuesVector: vector, completionHandler: completionHandler)
    }
    
    //-----------------------------------
    // MARK: - Helpers -
    // MARK: Execute Requests
    //-----------------------------------
    
    private func executeMatrixUnaryOperationForMethod(method: String, matrix: Matrix, completionHandler: ProcessOnApiClientResultBlock) {
        let body = bodyForUnaryOperation(matrix)
        let request = postRequestWithParameters(nil, path: method, body: body)
        
        fetchData(request) { (result: ApiClientResult) in
            self.processOnApiClientResult(result, withCompletionHandler: completionHandler)
        }
    }
    
    private func executeMatrixBinaryOperationForMethod(method: String, left lft: Matrix, right rgh: Matrix, completionHandler: MatrixMathMatrixResultBlock) {
        let body = bodyForBinaryOperation(left: lft, right: rgh)
        let request = postRequestWithParameters(nil, path: method, body: body)
        
        fetchData(request) { (result: ApiClientResult) in
            self.processOnApiClientResult(result, withCompletionHandler: { (json, error) in
                self.retrieveMatrixFromJSON(json, error: error, completionHandler: completionHandler)
            })
        }
    }
    
    private func executeMatrixSolveOperationForMethod(method: String, coefficientsMatrix matrix: Matrix, valuesVector vector: Array<Double>, completionHandler: MatrixMathSystemSolutionResultBlock) {
        let body = "{\"\(JSONBodyKey.Matrix)\": \(matrix.data), \"\(JSONBodyKey.VectorOfValues)\": \(vector)}"
        let request = postRequestWithParameters(nil, path: method, body: body)
        
        fetchData(request) { (result: ApiClientResult) in
            self.processOnApiClientResult(result, withCompletionHandler: { (json, error) in
                guard error == nil && json != nil else {
                    completionHandler(vector: nil, error: error)
                    return
                }
                
                guard let vector = json![JSONResponseKey.Result] as? Array<Double> else {
                    completionHandler(vector: nil, error: error)
                    return
                }
                
                completionHandler(vector: vector, error: nil)
            })
        }
    }
    
    //-----------------------------------
    // MARK: Build Requests
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
    
    //-----------------------------------
    // MARK: Handle Response
    //-----------------------------------
    
    private func processOnApiClientResult(result: ApiClientResult, withCompletionHandler completionHandler: ProcessOnApiClientResultBlock) {
        func sendError(error: String) {
            let userInfo = [NSLocalizedDescriptionKey: error]
            let error = NSError(domain: MatrixMathApiClient.ErrorDomain,
                                code: MatrixMathApiClient.ErrorCode,
                                userInfo: userInfo)
            completionHandler(json: nil, error: error)
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
    
    private func retrieveMatrixFromJSON(json: JSONDictionary?, error: NSError?, completionHandler: MatrixMathMatrixResultBlock) {
        guard error == nil && json != nil else {
            completionHandler(matrix: nil, error: error)
            return
        }
        
        completionHandler(matrix: Matrix.decode(json!), error: nil)
    }
    
}
