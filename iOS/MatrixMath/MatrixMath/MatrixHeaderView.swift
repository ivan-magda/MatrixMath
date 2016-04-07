//
//  MatrixHeaderView.swift
//  MatrixMath
//
//  Created by Ivan Magda on 08.04.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit

//----------------------------------------------------
// MARK: - MatrixHeaderView: UICollectionReusableView
//----------------------------------------------------

class MatrixHeaderView: UICollectionReusableView {
    
    //--------------------------------------
    // MARK: Outlets
    //--------------------------------------
    
    @IBOutlet weak var headerTitleLabel: UILabel!
    
    //--------------------------------------
    // MARK: Properties
    //--------------------------------------
    
    static let height: CGFloat = 22.0
    
    /// Identifier.
    static let reuseIdentifier = "MatrixHeaderView"

}
