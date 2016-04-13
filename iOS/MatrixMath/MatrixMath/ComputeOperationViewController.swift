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
// MARK: EdgeInsets
//----------------------------------------------------------

private struct EdgeInsets {
    static let scrollView = UIEdgeInsets(top: 64.0, left: 0.0, bottom: 22.0, right: 0.0)
    static let collectionViewSection = UIEdgeInsets(top: 8.0, left: 15.0, bottom: 8.0, right: 8.0)
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
    
    private var keyboardOnScreen = false
    private var isFillMatrixBTextFieldActive = false
    
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
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
        
        let scrollView = collectionView as UIScrollView
        scrollView.contentInset.bottom = EdgeInsets.scrollView.bottom
        
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
        let section = Section.fromIndex(indexPath.section)
        
        switch section {
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
            
            if section == .FillMatrixB {
                cell.itemTextField.tag = Section.FillMatrixB.rawValue
            }
            
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
        case .MatrixSize:
            return UIEdgeInsets(top: 0.0,
                                left: 0.0,
                                bottom: EdgeInsets.collectionViewSection.bottom * 2.0,
                                right: 0.0)
        case .ComputeOperation:
            return UIEdgeInsets(top: EdgeInsets.scrollView.bottom,
                                left: 0.0,
                                bottom: EdgeInsets.collectionViewSection.bottom * 2,
                                right: 0.0)
        default:
            return UIEdgeInsets(top: EdgeInsets.collectionViewSection.top,
                                left: EdgeInsets.collectionViewSection.left,
                                bottom: EdgeInsets.collectionViewSection.bottom,
                                right: EdgeInsets.collectionViewSection.right)
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
    
    //----------------------------------------------
    // MARK: UITextFieldDelegate
    //----------------------------------------------
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        isFillMatrixBTextFieldActive = textField.tag == Section.FillMatrixB.rawValue
        return true
    }
    
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
    
    //----------------------------------------------
    // MARK: Show/Hide Keyboard
    //----------------------------------------------
    
    func keyboardWillShow(notification: NSNotification) {
        if !keyboardOnScreen && isFillMatrixBTextFieldActive {
            let info = notification.userInfo!
            
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(info[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue!)
            UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: info[UIKeyboardAnimationCurveUserInfoKey]!.integerValue!)!)
            UIView.setAnimationBeginsFromCurrentState(true)
            
            let scrollView = collectionView as UIScrollView
            
            var insets = EdgeInsets.scrollView
            insets.bottom += keyboardHeight(notification)
            scrollView.contentInset = insets
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x,
                                               y: scrollView.contentOffset.y + keyboardHeight(notification))
            
            UIView.commitAnimations()
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if keyboardOnScreen && isFillMatrixBTextFieldActive  {
            let info = notification.userInfo!
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(info[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue!)
            UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: info[UIKeyboardAnimationCurveUserInfoKey]!.integerValue!)!)
            UIView.setAnimationBeginsFromCurrentState(true)
            
            let scrollView = collectionView as UIScrollView
            scrollView.contentInset = EdgeInsets.scrollView
            
            UIView.commitAnimations()
        }
    }
    
    func keyboardDidShow(notification: NSNotification) {
        keyboardOnScreen = true
    }
    
    func keyboardDidHide(notification: NSNotification) {
        keyboardOnScreen = false
    }
    
    private func keyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
}

//---------------------------------------------------------
// MARK: - ComputeOperationViewController (Notifications) -
//---------------------------------------------------------

extension ComputeOperationViewController {
    
    private func subscribeToKeyboardNotifications() {
        subscribeToNotification(
            UIKeyboardWillShowNotification,
            selector: #selector(ComputeOperationViewController.keyboardWillShow(_:)))
        subscribeToNotification(
            UIKeyboardWillHideNotification,
            selector: #selector(ComputeOperationViewController.keyboardWillHide(_:)))
        subscribeToNotification(
            UIKeyboardDidShowNotification,
            selector: #selector(ComputeOperationViewController.keyboardDidShow(_:)))
        subscribeToNotification(
            UIKeyboardDidHideNotification,
            selector: #selector(ComputeOperationViewController.keyboardDidHide(_:)))
    }
    
    private func subscribeToNotification(notification: String, selector: Selector) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    private func unsubscribeFromAllNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
