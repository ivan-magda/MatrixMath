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
    let dimention: MatrixDimention
    
    //------------------------------------
    // MARK: Initializers
    //------------------------------------
    
    init(data: MatrixDataType) {
        self.data = data
        
        let columns = data.count
        let rows = data[0].count
        self.dimention = MatrixDimention(columns: columns, rows: rows)
    }
    
    init?(data: Array<Double>, dimention: MatrixDimention) {
        guard data.count == dimention.count()
            && data.count > 0
            && dimention.nonZero() else {
            return nil
        }
        
        var array = MatrixDataType()
        for columnIdx in 0..<dimention.columns {
            var elemIdx = columnIdx * dimention.rows
            var elements = [Double]()
            for _ in 0..<dimention.rows {
                elements.append(data[elemIdx])
                elemIdx += 1
            }
            array.append(elements)
        }
        
        self.data = array
        self.dimention = dimention
    }
    
}
