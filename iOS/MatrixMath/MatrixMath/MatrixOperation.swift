//
//  MatrixMethod.swift
//  MatrixMath
//
//  Created by Ivan Magda on 06.04.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

//--------------------------------------
// MARK: - MatrixOperation
//--------------------------------------

class MatrixOperation {
    
    //--------------------------------------
    // MARK: Properties
    //--------------------------------------
    
    let name: String
    let detailDescription: String
    let type: MatrixOperationType
    
    //--------------------------------------
    // MARK: Initialize
    //--------------------------------------
    
    init(name: String, description: String = "", type: MatrixOperationType) {
        self.name = name
        self.detailDescription = description
        self.type = type
    }
    
    //--------------------------------------
    // MARK: Methods
    //--------------------------------------
    
    static func getAllMethods() -> [MatrixOperation] {
        var methods = [MatrixOperation]()
        
        methods.append(MatrixOperation(
            name: NSLocalizedString("Matrix addition", comment: "Matrix addition method name"),
            type: .Addition))
        methods.append(MatrixOperation(
            name: NSLocalizedString("Subtraction of matrices", comment: "Matrix substruct name"),
            type: .Subtract))
        methods.append(MatrixOperation(
            name: NSLocalizedString("Matrix multiplication", comment: "Matrix multiplication name"),
            type: .Multiply))
        methods.append(MatrixOperation(
            name: NSLocalizedString("Transpose matrix", comment: "Transpose matrix name"),
            type: .Transpose))
        methods.append(MatrixOperation(
            name: NSLocalizedString("Invert matrix", comment: "Invert matrix name"),
            type: .Invert))
        methods.append(MatrixOperation(
            name: NSLocalizedString("Matrix determinant", comment: "Matrix determinant name"),
            type: .Determinant))
        methods.append(MatrixOperation(
            name: NSLocalizedString("Solve a system of linear equations", comment: "Solve a system of linear equations name"),
            type: .Solve))
        methods.append(MatrixOperation(
            name: NSLocalizedString("Solve a system of linear equations", comment: "Solve a system of linear equations with error algorith name"),
            description: NSLocalizedString("Using an iterative error correction algorithm", comment: "Solve a system of linear equations with error algorith detail name"),
            type: .SolveWithErrorCorrection))
        
        return methods
    }
    
}