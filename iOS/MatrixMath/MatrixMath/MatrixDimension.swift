//
//  MatrixDimention.swift
//  MatrixMath
//
//  Created by Ivan Magda on 08.04.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

//----------------------------------------------------------
// MARK: - MatrixDimension
//----------------------------------------------------------

public struct MatrixDimension {
    
    //------------------------------------------------------
    // MARK: Properties
    //------------------------------------------------------
    
    var columns: Int
    var rows: Int
    
    //------------------------------------------------------
    // MARK: Behavior
    //------------------------------------------------------
    
    func count() -> Int {
        return columns * rows
    }
    
    func nonZero() -> Bool {
        return columns != 0 && rows != 0
    }
    
}
