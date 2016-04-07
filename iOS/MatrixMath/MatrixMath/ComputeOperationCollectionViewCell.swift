//
//  ComputeOperationCollectionViewCell.swift
//  MatrixMath
//
//  Created by Ivan Magda on 08.04.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit

//------------------------------------------------------------------
// MARK: - ComputeOperationCollectionViewCell: UICollectionViewCell
//------------------------------------------------------------------

class ComputeOperationCollectionViewCell: UICollectionViewCell {
 
    //--------------------------------------
    // MARK: Outlets
    //--------------------------------------
    
    @IBOutlet weak var computeButton: BorderedButton!
    
    //--------------------------------------
    // MARK: Properties
    //--------------------------------------
    
    /// Cell reuse identifier.
    static let reuseIdentifier = "ComputeOperationCell"
    
}
