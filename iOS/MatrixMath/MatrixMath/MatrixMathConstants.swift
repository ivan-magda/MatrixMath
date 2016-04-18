//
//  MatrixMathConstants.swift
//  MatrixMath
//
//  Created by Ivan Magda on 31.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

//-----------------------------------------
// MARK: - MatrixMathApiClient (Constants)
//-----------------------------------------

extension MatrixMathApiClient {
    
    // MARK: Constants
    struct Constant {
        
        // MARK: URLs
        static let ApiScheme = "http"
        static let ApiHost = "dota2begin.tk"
        static let ApiPath = "/server/api"
    }
    
    // MARK: Methods
    struct Method {
        static let Addition = "/add"
        static let Subtract = "/sub"
        static let Multiply = "/multiply"
        static let Transpose = "/transpose"
        static let Determinant = "/determinant"
        static let Invert = "/invert"
        static let SolveSystem = "/solve"
        static let SolveSystemWithErrorCorrection = "/solveec"
        
        // TODO: not implemented methods on the server yet.
        static let Rank = "/rank"
        static let FindInverse = "/findinverse"
    }
    
    // MARK: JSON Body Keys
    struct JSONBodyKey {
        static let Left = "left"
        static let Right = "right"
        static let Matrix = "matrix"
        static let VectorOfValues = "vector"
        static let MatrixOfCoefficients = "matrix"
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKey {
        static let StatusMessage = "status_message"
        static let StatusCode = "status_code"
        static let Result = "result"
    }
    
}
