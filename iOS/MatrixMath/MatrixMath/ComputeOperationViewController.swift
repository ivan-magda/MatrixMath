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
    // MARK: Outlets
    //------------------------------------------------
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //------------------------------------------------
    // MARK: Properties
    //------------------------------------------------
    
    var operationToPerform: MatrixOperation!
    
    private static let minimumMatrixItemWidth: CGFloat = 42.0
    private static let defaultCollectionViewCellHeight: CGFloat = 44.0
    
    private var columns = 3
    private var rows = 3
    
    //------------------------------------------------
    // MARK: View Life Cycle
    //------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(operationToPerform != nil, "Operation to perform must be passed")
        
        title = operationToPerform.name
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }

}

//-------------------------------------------------------
// MARK: - ComputeOperationViewController (UI Functions)
//-------------------------------------------------------

extension ComputeOperationViewController {
    
    private func sizeForCollectionViewItemInSection(section: Section, layout: UICollectionViewFlowLayout) -> CGSize {
        let screenWidth = screenSize().width
        
        switch section {
        case .MatrixSize:
            return CGSize(width: screenWidth,
                          height: ComputeOperationViewController.defaultCollectionViewCellHeight)
        default:
            return sizeForMatrixItemAtIndex(section.rawValue, layout: layout)
        }
    }
    
    private func sizeForMatrixItemAtIndex(index: Int, layout: UICollectionViewFlowLayout) -> CGSize {
        let screenWidth = screenSize().width
        
        let delegateFlowLayout = collectionView.delegate as! UICollectionViewDelegateFlowLayout
        let sectionInset = delegateFlowLayout.collectionView!(collectionView, layout: layout, insetForSectionAtIndex: index)
        let minimumInteritemSpacing = layout.minimumInteritemSpacing
        
        let remainingWidth = screenWidth - (sectionInset.left + sectionInset.right
            + CGFloat((rows - 1)) * minimumInteritemSpacing)
        
        var width = floor(remainingWidth / CGFloat(rows))
        
        if width < ComputeOperationViewController.minimumMatrixItemWidth {
            width = ComputeOperationViewController.minimumMatrixItemWidth
        }
        
        debugPrint("Matrix item width = \(width)")
        
        return CGSize(width: width,
                      height: ComputeOperationViewController.defaultCollectionViewCellHeight)
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
            return columns * rows
        default:
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        switch Section(rawValue: indexPath.section)! {
        case .MatrixSize:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MatrixSizeCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! MatrixSizeCollectionViewCell
            
            if indexPath.row == 0 {
                cell.titleLabel.text = NSLocalizedString("Number of columns",
                                                         comment: "Number of columns title")
                cell.sizeLabel.text = "\(columns)"
            } else {
                cell.titleLabel.text = NSLocalizedString("Number of rows",
                                                         comment: "Number of rows title")
                cell.sizeLabel.text = "\(rows)"
            }
            
            return cell
        case .FillMatrix:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MatrixItemCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! MatrixItemCollectionViewCell
            return cell
        default:
            return collectionView.dequeueReusableCellWithReuseIdentifier(MatrixSizeCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! MatrixSizeCollectionViewCell
        }
    }
    
}

//----------------------------------------------------------------------------
// MARK: - ComputeOperationViewController: UICollectionViewDelegateFlowLayout
//----------------------------------------------------------------------------

extension ComputeOperationViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let section = Section(rawValue: indexPath.section)!
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        
        return sizeForCollectionViewItemInSection(section, layout: layout)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if section != 0 {
            return UIEdgeInsets(top: 16.0, left: 15.0, bottom: 0.0, right: 15.0)
        }
        
        return UIEdgeInsetsZero
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 8.0
    }
    
}
