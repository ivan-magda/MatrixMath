//
//  Constants.swift
//  MatrixMath
//
//  Created by Ivan Magda on 31.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

let BaseErrorDomain = "com.ivanmagda.MatrixMath"

//-------------------------------------
// MARK: - HttpApiClient (Constants)
//-------------------------------------

struct HttpApiClientError {
    static let EmptyResponseDomain = "\(BaseErrorDomain).emptyresponse"
}

struct HttpApiClientErrorCode {
    static let EmptyResponse = 12
}

//-------------------------------------
// MARK: - JsonApiClient (Constants)
//-------------------------------------

struct JsonApiClientError {
    static let EmptyResponseDomain = "\(BaseErrorDomain).emptyresponse"
    static let JSONDeserializingDomain = "\(BaseErrorDomain).jsonerror.deserializing"
    static let NotSuccsessfullResponseDomain = "\(BaseErrorDomain).badresponsecode"
}

struct JsonApiClientErrorCode {
    static let EmptyResponse = 12
    static let JSONDeserializing = 50
    static let NotSuccsessfullResponseStatusCode = 51
}

//--------------------------------------------
// MARK: - MatrixMathApiClient: (Constants)
//--------------------------------------------

extension MatrixMathApiClient {
    
    // MARK: - Error
    static let ErrorDomain = "\(BaseErrorDomain).MatrixMathApiClient"
    static let ErrorCode = 100
}

//--------------------------------------------
// MARK: - HTTPMethodName
//--------------------------------------------
enum HTTPMethodName: String {
    case Get = "GET"
    case Post = "POST"
}
