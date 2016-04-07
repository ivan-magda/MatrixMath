//
//  MatrixSizeCollectionViewCell.swift
//  MatrixMath
//
//  Created by Ivan Magda on 07.04.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit

//------------------------------------------------------------
// MARK: - MatrixSizeCollectionViewCell: UICollectionViewCell
//------------------------------------------------------------

class MatrixSizeCollectionViewCell: UICollectionViewCell {
    
    //--------------------------------------
    // MARK: Outlets
    //--------------------------------------
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    
    //--------------------------------------
    // MARK: Properties
    //--------------------------------------
    
    /// Cell reuse identifier.
    static let reuseIdentifier = "MatrixSizeCell"
    
}
