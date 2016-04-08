//
//  MatrixDimention.swift
//  MatrixMath
//
//  Created by Ivan Magda on 08.04.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

//----------------------------------------------------------
// MARK: MatrixDimention
//----------------------------------------------------------

public struct MatrixDimention {
    
    var columns: Int
    var rows: Int
    
    func count() -> Int {
        return columns * rows
    }
    
    func nonZero() -> Bool {
        return columns != 0 && rows != 0
    }
    
}
