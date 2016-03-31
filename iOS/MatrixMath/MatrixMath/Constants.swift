//
//  Constants.swift
//  MatrixMath
//
//  Created by Ivan Magda on 31.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

//-------------------------------------
// MARK: - HttpApiClient (Constants)
//-------------------------------------

extension HttpApiClient {
    
    struct Error {
        static let BaseDomain = "com.ivanmagda.MatrixMath"
        static let EmptyResponseDomain = "\(BaseDomain).emptyresponse"
        static let JSONDeserializingDomain = "\(BaseDomain).jsonerror.deserializing"
        static let NotSuccsessfullResponseDomain = "\(BaseDomain).badresponsecode"
    }
    
    struct ErrorCode {
        static let EmptyResponse = 12
        static let JSONDeserializing = 13
        static let NotSuccsessfullResponseStatusCode = 14
    }
    
}
