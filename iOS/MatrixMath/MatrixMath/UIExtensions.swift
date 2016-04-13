//
//  UIExtensions.swift
//  MatrixMath
//
//  Created by Ivan Magda on 13.04.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit

//--------------------------------
// MARK: - UIView
//--------------------------------

extension UIView {
    
    class func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> UIView? {
        return UINib(nibName: nibNamed, bundle: bundle)
            .instantiateWithOwner(nil, options: nil)[0] as? UIView
    }
    
}
