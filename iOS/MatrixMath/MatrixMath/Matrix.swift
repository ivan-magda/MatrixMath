//
//  Matrix.swift
//  MatrixMath
//
//  Created by Ivan Magda on 02.04.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

/// Defining the matrix as array of arrays with specific type of the elements.
typealias MatrixDataType = Array<Array<Double>>

//------------------------------------
// MARK: - Matrix
//------------------------------------

struct Matrix {
    
    //------------------------------------
    // MARK: Properties
    //------------------------------------
    
    let data: MatrixDataType
    
    //------------------------------------
    // MARK: Initializers
    //------------------------------------
    
    init(data: MatrixDataType) {
        self.data = data
    }
    
}
