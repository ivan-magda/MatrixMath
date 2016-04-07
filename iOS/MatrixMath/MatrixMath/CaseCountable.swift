//
//  CaseCountable.swift
//  MatrixMath
//
//  Created by Ivan Magda on 07.04.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

//--------------------------------------
// MARK: - CaseCountable
//--------------------------------------

/// An enum which provides a count of its cases.
protocol CaseCountable {
    static func countCases() -> Int
    static var caseCount : Int { get }
}

//--------------------------------------
// MARK: - CaseCountable (countCases)
//--------------------------------------

// Provide a default implementation to count the cases for Int enums
// assuming starting at 0 and contiguous.
extension CaseCountable where Self : RawRepresentable, Self.RawValue == Int {
    
    /// Count the number of cases in the enum.
    static func countCases() -> Int {
        // starting at zero, verify whether the enum can be instantiated
        // from the Int and increment until it cannot.
        var count = 0
        while let _ = Self(rawValue: count) {
            count += 1
        }
        
        return count
    }
    
}
