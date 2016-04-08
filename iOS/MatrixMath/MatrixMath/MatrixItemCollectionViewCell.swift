//
//  MatrixItemCollectionViewCell.swift
//  MatrixMath
//
//  Created by Ivan Magda on 07.04.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit

//------------------------------------------------------------
// MARK: - MatrixItemCollectionViewCell: UICollectionViewCell
//------------------------------------------------------------

class MatrixItemCollectionViewCell: UICollectionViewCell {

    //--------------------------------------
    // MARK: Outlets
    //--------------------------------------
    
    @IBOutlet weak var itemTextField: UITextField!
    
    /// Cell reuse identifier.
    static let reuseIdentifier = "MatrixItemCell"
    
}
