//
//  GCDBlackBox.swift
//  MatrixMath
//
//  Created by Ivan Magda on 31.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

/// Executes the passed in block in the Main thread.
func performOnMain(block: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        block()
    }
}