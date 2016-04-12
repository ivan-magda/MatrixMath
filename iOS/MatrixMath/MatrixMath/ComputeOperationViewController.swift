//
//  ComputeOperationViewController.swift
//  MatrixMath
//
//  Created by Ivan Magda on 07.04.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

//----------------------------------------------------------
// MARK: Types -
// MARK: Section: Int, CaseCountable
//----------------------------------------------------------

private enum Section: Int, CaseCountable {
    
    case MatrixSize = 0
    case FillMatrixA
    case FillMatrixB
    case ComputeOperation
    case OperationResult
    
    static let caseCount = Section.countCases()
    
    static func fromIndex(section: Int) -> Section {
        return Section(rawValue: section)!
    }
    
}

//----------------------------------------------------------
// MARK: DefaultSectionInset
//----------------------------------------------------------

private struct DefaultSectionInset {
    static let top: CGFloat = 8.0
    static let left: CGFloat = 15.0
    static let bottom: CGFloat = 8.0
    static let right: CGFloat = 8.0
}

//-----------------------------------------------------------
// MARK: - ComputeOperationViewController: UIViewController -
//-----------------------------------------------------------

class ComputeOperationViewController: UIViewController {
    
    //------------------------------------------------
    // MARK: Outlets
    //------------------------------------------------
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //------------------------------------------------
    // MARK: - Properties
    //------------------------------------------------
    
    var operationToPerform: MatrixOperation!
    
    private var matrixDimention: MatrixDimention!
    
    private var lhsMatrixArray: [Double]!
    private var rhsMatrixArray: [Double]!
    
    private lazy var numberFormatter: NSNumberFormatter = {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .DecimalStyle
        
        return numberFormatter
    }()
    
    //------------------------------------------------
    // MARK: UI
    //------------------------------------------------
    
    private static let minimumMatrixItemWidth: CGFloat = 35.0
    private static let defaultCollectionViewCellHeight: CGFloat = 44.0
    private static let computeButtonHeight: CGFloat = 44.0
    
    //------------------------------------------------
    // MARK: - View Life Cycle
    //------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(operationToPerform != nil, "Operation to perform must be passed")
        
        configureUI()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
        print("Content size: \(collectionView.contentSize)")
    }
    
    //------------------------------------------------
    // MARK: - Actions
    //------------------------------------------------
    
    func computeOperation() {
    }
    
    //------------------------------------------------
    // MARK: - Helpers
    //------------------------------------------------
    
    private func initMatrices() {
        func baseMatrix() -> [Double] {
            return [Double](count: matrixDimention.count(), repeatedValue: 0.0)
        }
        
        lhsMatrixArray = baseMatrix()
        rhsMatrixArray = baseMatrix()
    }
    
    private func updateMatrixItemArrayItemFromText(text: String?, andIndexPath indexPath: NSIndexPath) {
        func setValue(number: Double) {
            switch Section.fromIndex(indexPath.section) {
            case .FillMatrixA:
                lhsMatrixArray[indexPath.row] = number
            case .FillMatrixB:
                rhsMatrixArray[indexPath.row] = number
            default:
                print("Undefined index path section")
                break
            }
        }
        
        guard isMatrixItemInputCorrect(text) == true else {
            setValue(0.0)
            return
        }
        
        setValue(numberFromText(text))
    }
    
    private func isMatrixItemInputCorrect(text: String?) -> Bool {
        return (text != nil && numberFormatter.numberFromString(text!) != nil)
    }
    
    private func numberFromText(text: String?) -> Double {
        guard isMatrixItemInputCorrect(text) == true else {
            return 0.0
        }
        
        return numberFormatter.numberFromString(text!)!.doubleValue
    }
    
}

//--------------------------------------------------------
// MARK: - ComputeOperationViewController (UI Functions) -
//--------------------------------------------------------

extension ComputeOperationViewController {
    
    private func configureUI() {
        title = operationToPerform.name
        
        matrixDimention = MatrixDimention(columns: 3, rows: 3)
        initMatrices()
    }
    
    private func presentAlertWithTitle(title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    private func sizeForCollectionViewItemInSection(section: Section) -> CGSize {
        let screenWidth = screenSize().width
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        switch section {
        case .FillMatrixA, .FillMatrixB:
            return sizeForMatrixItemAtIndex(section.rawValue, layout: layout)
        case .ComputeOperation:
            return CGSize(width: screenWidth, height: ComputeOperationViewController.computeButtonHeight)
        default:
            return CGSize(width: screenWidth,
                          height: ComputeOperationViewController.defaultCollectionViewCellHeight)
        }
    }
    
    private func sizeForMatrixItemAtIndex(index: Int, layout: UICollectionViewFlowLayout) -> CGSize {
        let screenWidth = screenSize().width
        
        let delegateFlowLayout = collectionView.delegate as! UICollectionViewDelegateFlowLayout
        let sectionInset = delegateFlowLayout.collectionView!(collectionView, layout: layout, insetForSectionAtIndex: index)
        let minimumInteritemSpacing = layout.minimumInteritemSpacing
        
        let remainingWidth = screenWidth - (sectionInset.left + sectionInset.right
            + CGFloat((matrixDimention.rows - 1)) * minimumInteritemSpacing)
        
        var width = floor(remainingWidth / CGFloat(matrixDimention.rows))
        
        if width < ComputeOperationViewController.minimumMatrixItemWidth {
            width = ComputeOperationViewController.minimumMatrixItemWidth
        }
        
        return CGSize(width: width,
                      height: ComputeOperationViewController.defaultCollectionViewCellHeight)
    }
    
}

//---------------------------------------------------------------------
// MARK: - ComputeOperationViewController: UICollectionViewDataSource -
//---------------------------------------------------------------------

extension ComputeOperationViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return Section.countCases()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section.fromIndex(section) {
        case .MatrixSize:
            return 2
        case .FillMatrixA, .FillMatrixB:
            return matrixDimention.count()
        case .ComputeOperation:
            return 1
        default:
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        switch Section.fromIndex(indexPath.section) {
        case .MatrixSize:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MatrixSizeCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! MatrixSizeCollectionViewCell
            
            if indexPath.row == 0 {
                cell.titleLabel.text = NSLocalizedString("Number of columns",
                                                         comment: "Number of columns title")
                cell.sizeLabel.text = "\(matrixDimention.columns)"
            } else {
                cell.titleLabel.text = NSLocalizedString("Number of rows",
                                                         comment: "Number of rows title")
                cell.sizeLabel.text = "\(matrixDimention.rows)"
            }
            
            return cell
        case .FillMatrixA, .FillMatrixB:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MatrixItemCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! MatrixItemCollectionViewCell
            cell.itemTextField.delegate = self
            return cell
        case .ComputeOperation:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ComputeOperationCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! ComputeOperationCollectionViewCell
            cell.computeButton.addTarget(self, action: #selector(computeOperation), forControlEvents: .TouchUpInside)
            
            return cell
        default:
            return collectionView.dequeueReusableCellWithReuseIdentifier(MatrixSizeCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! MatrixSizeCollectionViewCell
        }
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: MatrixHeaderView.reuseIdentifier, forIndexPath: indexPath) as! MatrixHeaderView
        
        let fill = NSLocalizedString("Fill matrix", comment: "Fill matrix header title")
        
        switch Section.fromIndex(indexPath.section) {
        case .FillMatrixA:
            headerView.headerTitleLabel.text = "\(fill) A"
        case .FillMatrixB:
            headerView.headerTitleLabel.text = "\(fill) B"
        default:
            break
        }
        
        return headerView
    }
    
}

//-----------------------------------------------------------------------------
// MARK: - ComputeOperationViewController: UICollectionViewDelegateFlowLayout -
//-----------------------------------------------------------------------------

extension ComputeOperationViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return sizeForCollectionViewItemInSection(Section.fromIndex(indexPath.section))
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        guard collectionView.numberOfItemsInSection(section) > 0 else {
            return UIEdgeInsetsZero
        }
        
        switch Section.fromIndex(section) {
        case .MatrixSize, .ComputeOperation:
            return UIEdgeInsets(top: 0.0,
                                left: 0.0,
                                bottom: DefaultSectionInset.top * 2.0,
                                right: 0.0)
        default:
            return UIEdgeInsets(top: DefaultSectionInset.top,
                                left: DefaultSectionInset.left,
                                bottom: DefaultSectionInset.bottom,
                                right: DefaultSectionInset.right)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch Section.fromIndex(section) {
        case .FillMatrixA, .FillMatrixB:
            return CGSize(width: collectionView.bounds.width,
                          height: MatrixHeaderView.height)
        default:
            return CGSizeZero
        }
    }
    
}

//-------------------------------------------------------------------
// MARK: - ComputeOperationViewController: UICollectionViewDelegate -
//-------------------------------------------------------------------

extension ComputeOperationViewController: UICollectionViewDelegate {
    
//    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
//        guard let matrixItemCell = cell as? MatrixItemCollectionViewCell else {
//            return
//        }
//        print("Did end displaying item cell for section: \(indexPath.section), row: \(indexPath.row)")
//        
//        updateMatrixItemArrayItemFromText(matrixItemCell.itemTextField.text, andIndexPath: indexPath)
//    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        switch Section.fromIndex(indexPath.section) {
        case .ComputeOperation:
            computeOperation()
        case .MatrixSize:
            func selectNumberOfColumns(indexPath: NSIndexPath) -> Bool {
                return indexPath.row == 0
            }
            
            let selectedCell = collectionView.cellForItemAtIndexPath(indexPath) as! MatrixSizeCollectionViewCell
            
            let title = selectedCell.titleLabel.text!
            let rows:[Int] = Array(1...7)
            let initialSelection = (selectNumberOfColumns(indexPath) == true
                ? matrixDimention.columns - 1
                : matrixDimention.rows - 1)
            
            ActionSheetStringPicker.showPickerWithTitle(title, rows: rows, initialSelection: initialSelection, doneBlock: { [weak self] (picker, selectedIndex, selectedValue) in
                let value = selectedValue as! Int
                
                print("Did select value: \(value) at index: \(selectedIndex)")
                
                selectedCell.sizeLabel.text = "\(value)"
                
                let oRows = self?.matrixDimention.rows
                let oColumns = self?.matrixDimention.columns
                if selectNumberOfColumns(indexPath) {
                    self?.matrixDimention = MatrixDimention(columns: value,
                        rows: oRows!)
                } else {
                    self?.matrixDimention = MatrixDimention(columns: oColumns!,
                        rows: value)
                }
                
                self?.initMatrices()
                self?.collectionView.reloadData()
                
                }, cancelBlock: { picker in
                    print("User did cancel selection of the size value")
                }, origin: view)
        case .FillMatrixA, .FillMatrixB:
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! MatrixItemCollectionViewCell
            cell.itemTextField.becomeFirstResponder()
        default:
            break
        }
    }
    
}

//--------------------------------------------------------------
// MARK: - ComputeOperationViewController: UITextFieldDelegate -
//--------------------------------------------------------------

extension ComputeOperationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if isMatrixItemInputCorrect(textField.text) {
            textField.resignFirstResponder()
            return true
        } else {
            presentAlertWithTitle(
                NSLocalizedString("Incorrect input",comment: "Incorrect input title"), message:
                NSLocalizedString("Pleasy enter valid data", comment: "incorrect input message")
            )
            return false
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        let cell = textField.superview!.superview as! MatrixItemCollectionViewCell
        
        guard let indexPath = collectionView.indexPathForCell(cell) else {
            return
        }
        
        updateMatrixItemArrayItemFromText(textField.text, andIndexPath: indexPath)
        
        print("Did end editing at section: \(indexPath.section), row: \(indexPath.row)")
        
        print("Size: \(collectionView.contentSize)")
    }
    
}
