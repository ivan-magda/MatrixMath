//
//  MatrixHeaderView.swift
//  MatrixMath
//
//  Created by Ivan Magda on 08.04.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit

//--------------------------------
// MARK: - BorderedButton: Button
//--------------------------------

class BorderedButton: UIButton {
    
    //----------------------------
    // MARK: Properties
    //----------------------------
    
    let borderedButtonCornerRadius: CGFloat = 4.0
    
    //----------------------------
    // MARK: Initialization
    //----------------------------
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        themeBorderedButton()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        themeBorderedButton()
    }
    
    //----------------------------
    // MARK: Customization
    //----------------------------
    
    private func themeBorderedButton() {
        layer.masksToBounds = true
        layer.cornerRadius = borderedButtonCornerRadius
    }
    
}