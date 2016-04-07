//
//  ComputeOperationViewController.swift
//  MatrixMath
//
//  Created by Ivan Magda on 07.04.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit

//----------------------------------------------------------
// MARK: Types
//----------------------------------------------------------

private enum Section: Int, CaseCountable {
    case MatrixSize = 0
    case FillMatrix
    case PerformOperation
    case OperationResult
    
    static let caseCount = Section.countCases()
}

//----------------------------------------------------------
// MARK: - ComputeOperationViewController: UIViewController
//----------------------------------------------------------

class ComputeOperationViewController: UIViewController {
    
    //------------------------------------------------
    // MARK: Properties
    //------------------------------------------------
    
    var operationToPerform: MatrixOperation!
    
    //------------------------------------------------
    // MARK: View Life Cycle
    //------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(operationToPerform != nil, "Operation to perform must be passed")
        
        title = operationToPerform.name
    }

}

//--------------------------------------------------------------------
// MARK: - ComputeOperationViewController: UICollectionViewDataSource
//--------------------------------------------------------------------

extension ComputeOperationViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return Section.countCases()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .MatrixSize:
            return 2
        case .FillMatrix:
            return 6
        default:
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        switch Section(rawValue: indexPath.section)! {
        case .MatrixSize:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MatrixSizeCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! MatrixSizeCollectionViewCell
            
            cell.titleLabel.text = "Title label \(indexPath.row)"
            cell.sizeLabel.text = "\(arc4random_uniform(UInt32(10)))"
            
            return cell
        case .FillMatrix:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MatrixItemCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! MatrixItemCollectionViewCell
            return cell
        default:
            return collectionView.dequeueReusableCellWithReuseIdentifier(MatrixSizeCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! MatrixSizeCollectionViewCell
        }
    }
    
}
