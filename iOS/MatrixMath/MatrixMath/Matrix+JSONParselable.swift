//
//  Matrix+JSONParselable.swift
//  MatrixMath
//
//  Created by Ivan Magda on 02.04.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

extension Matrix: JSONParselable {
    
    static func decode(json: JSONDictionary) -> Matrix? {
        guard let data: MatrixDataType = JSON.arrayOfArrays(json, key: MatrixMathApiClient.JSONResponseKey.Result) else {
            return nil
        }
        
        return Matrix(data: data)
    }
    
}