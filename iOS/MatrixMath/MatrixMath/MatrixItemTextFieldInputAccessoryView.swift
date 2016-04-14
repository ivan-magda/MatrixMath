//
//  MatrixItemTextFieldInputAccessoryView.swift
//  MatrixMath
//
//  Created by Ivan Magda on 13.04.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit

//-------------------------------------------------------
// MARK: - MatrixItemTextFieldInputAccessoryView: UIView
//-------------------------------------------------------

class MatrixItemTextFieldInputAccessoryView: UIView {

    //---------------------------------------------------
    // MARK: Outlets
    //---------------------------------------------------
    
    @IBOutlet weak var doneButton: UIButton!
    
    //---------------------------------------------------
    // MARK: Properties
    //---------------------------------------------------
    
    weak var parentTextField: UITextField!
    
    //---------------------------------------------------
    // MARK: Class Functions
    //---------------------------------------------------
    
    class func loadView() -> MatrixItemTextFieldInputAccessoryView {
        return UIView.loadFromNibNamed("MatrixItemTextFieldInputAccessoryView",
                                       bundle: nil) as! MatrixItemTextFieldInputAccessoryView
    }
    
}
