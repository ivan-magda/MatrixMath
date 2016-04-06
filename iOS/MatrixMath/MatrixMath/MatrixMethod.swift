//
//  MatrixMethod.swift
//  MatrixMath
//
//  Created by Ivan Magda on 06.04.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

//--------------------------------------
// MARK: - MatrixMethod
//--------------------------------------

struct MatrixMethod {
    
    //--------------------------------------
    // MARK: Properties
    //--------------------------------------
    
    let name: String
    let detailDescription: String
    let type: MatrixMethodType
    
    //--------------------------------------
    // MARK: Initialize
    //--------------------------------------
    
    init(name: String, description: String = "", type: MatrixMethodType) {
        self.name = name
        self.detailDescription = description
        self.type = type
    }
    
    //--------------------------------------
    // MARK: Methods
    //--------------------------------------
    
    static func getAllMethods() -> [MatrixMethod] {
        var methods = [MatrixMethod]()
        
        methods.append(MatrixMethod(
            name: NSLocalizedString("Matrix addition", comment: "Matrix addition method name"),
            type: .Addition))
        methods.append(MatrixMethod(
            name: NSLocalizedString("Subtraction of matrices", comment: "Matrix substruct name"),
            type: .Subtract))
        methods.append(MatrixMethod(
            name: NSLocalizedString("Matrix multiplication", comment: "Matrix multiplication name"),
            type: .Multiply))
        methods.append(MatrixMethod(
            name: NSLocalizedString("Transpose matrix", comment: "Transpose matrix name"),
            type: .Transpose))
        methods.append(MatrixMethod(
            name: NSLocalizedString("Invert matrix", comment: "Invert matrix name"),
            type: .Invert))
        methods.append(MatrixMethod(
            name: NSLocalizedString("Matrix determinant", comment: "Matrix determinant name"),
            type: .Determinant))
        methods.append(MatrixMethod(
            name: NSLocalizedString("Solve a system of linear equations", comment: "Solve a system of linear equations name"),
            type: .Solve))
        methods.append(MatrixMethod(
            name: NSLocalizedString("Solve a system of linear equations", comment: "Solve a system of linear equations with error algorith name"),
            description: NSLocalizedString("Using an iterative error correction algorithm", comment: "Solve a system of linear equations with error algorith detail name"),
            type: .SolveWithErrorCorrection))
        
        return methods
    }
    
}