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
    let dimension: MatrixDimension
    
    //------------------------------------
    // MARK: Initializers
    //------------------------------------
    
    init(data: MatrixDataType) {
        self.data = data
        
        let columns = data.count
        let rows = data[0].count
        self.dimension = MatrixDimension(columns: columns, rows: rows)
    }
    
    init?(data: Array<Double>, dimension: MatrixDimension) {
        guard data.count == dimension.count()
            && data.count > 0
            && dimension.nonZero() else {
            return nil
        }
        
        var array = MatrixDataType()
        for columnIdx in 0..<dimension.columns {
            var elemIdx = columnIdx * dimension.rows
            var elements = [Double]()
            for _ in 0..<dimension.rows {
                elements.append(data[elemIdx])
                elemIdx += 1
            }
            array.append(elements)
        }
        
        self.data = array
        self.dimension = dimension
    }
    
    //------------------------------------
    // MARK: Behavior
    //------------------------------------
    
    func getLinearArray() -> [Double] {
        var result = [Double]()
        for anArray in data {
            for element in anArray {
                result.append(element)
            }
        }
        
        return result
    }
    
}
