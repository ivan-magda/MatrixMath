//
//  UIUtility.swift
//  MatrixMath
//
//  Created by Ivan Magda on 07.04.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit

//------------------------------------------------
// MARK: Screen Sizes
//------------------------------------------------

public func screenBounds() -> CGRect {
    return UIScreen.mainScreen().bounds
}

public func screenSize() -> CGSize {
    return UIScreen.mainScreen().bounds.size
}

//------------------------------------------------
// MARK: Network Indicator
//------------------------------------------------

public func showNetworkActivityIndicator() {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
}

public func hideNetworkActivityIndicator() {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
}

