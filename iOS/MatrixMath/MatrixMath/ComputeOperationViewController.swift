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
    var apiClient: MatrixMathApiClient!
    
    private var lhsMatrixDimention: MatrixDimention!
    private var rhsMatrixDimention: MatrixDimention!
    
    private var lhsMatrixArray: [Double]!
    private var rhsMatrixArray: [Double]!
    
    private lazy var numberFormatter: NSNumberFormatter = {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .DecimalStyle
        
        return numberFormatter
    }()
    
    private var keyboardOnScreen = false
    private var isFillMatrixBTextFieldActive = false
    
    private lazy var matrixItemTextFieldInputAccessoryView: MatrixItemTextFieldInputAccessoryView = {
        return MatrixItemTextFieldInputAccessoryView.loadView()
    }()
    
    //------------------------------------------------
    // MARK: UI Constants
    //------------------------------------------------
    
    private static let minimumMatrixItemWidth: CGFloat = 35.0
    private static let defaultCollectionViewCellHeight: CGFloat = 44.0
    private static let computeButtonHeight: CGFloat = 44.0
    
    //------------------------------------------------
    // MARK: - View Life Cycle
    //------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(operationToPerform != nil, "Operation to perform be passed when segue to this VC")
        assert(apiClient != nil, "Api client instance must be passed when segue to this VC")
        
        setup()
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
    }
    
    //------------------------------------------------
    // MARK: - Actions
    //------------------------------------------------
    
    func computeOperation() {
        
    }
    
    //------------------------------------------------
    // MARK: - Helpers
    //------------------------------------------------
    
    private func setup() {
        configureUI()
        
        // Configure matrix dimentions and data source.
        
        let defaultsMatrixDimention = MatrixDimention(columns: 3, rows: 3)
        lhsMatrixDimention = defaultsMatrixDimention
        
        switch operationToPerform.type {
        case .Addition, .Subtract, .Multiply:
            rhsMatrixDimention = defaultsMatrixDimention
        case .Solve, .SolveWithErrorCorrection:
            rhsMatrixDimention = MatrixDimention(columns: 3, rows: 1)
        default:
            rhsMatrixDimention = MatrixDimention(columns: 0, rows: 0)
        }
        
        initMatrices()
    }
    
    private func initMatrices() {
        lhsMatrixArray = [Double](count: lhsMatrixDimention.count(), repeatedValue: 0.0)
        rhsMatrixArray = [Double](count: rhsMatrixDimention.count(), repeatedValue: 0.0)
    }
    
    private func updateMatrixItemFromText(text: String?, andIndexPath indexPath: NSIndexPath) {
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
            return sizeForMatrixItemInSection(section, layout: layout)
        case .ComputeOperation:
            return CGSize(width: screenWidth, height: ComputeOperationViewController.computeButtonHeight)
        default:
            return CGSize(width: screenWidth,
                          height: ComputeOperationViewController.defaultCollectionViewCellHeight)
        }
    }
    
    private func sizeForMatrixItemInSection(section: Section, layout: UICollectionViewFlowLayout) -> CGSize {
        guard collectionView.numberOfItemsInSection(section.rawValue) != 0 else {
            return CGSizeZero
        }
        
        let screenWidth = screenSize().width
        
        // Get number of rows for matrix that we currently layouts.
        // It may be lhs matrix(when perform binary/unary operation) or
        // rhs matrix(when perform binary operation).
        
        var rows: Int!
        switch section {
        case .FillMatrixA:
            rows = lhsMatrixDimention.rows
        case .FillMatrixB:
            rows = rhsMatrixDimention.rows
        default:
            break
        }
        
        // Determine size value for the collection item.
        
        let delegateFlowLayout = collectionView.delegate as! UICollectionViewDelegateFlowLayout
        let sectionInset = delegateFlowLayout.collectionView!(collectionView, layout: layout, insetForSectionAtIndex: section.rawValue)
        let minimumInteritemSpacing = layout.minimumInteritemSpacing
        
        let remainingWidth = screenWidth - (sectionInset.left + sectionInset.right
            + CGFloat((rows - 1)) * minimumInteritemSpacing)
        
        var width = floor(remainingWidth / CGFloat(rows))
        
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
            switch operationToPerform.type {
            case .Solve, .SolveWithErrorCorrection:
                return 1
            case .Addition, .Subtract, .Transpose, .Determinant, .Invert:
                return 2
            case .Multiply:
                return 4
            }
        case .FillMatrixA:
            return lhsMatrixDimention.count()
        case .FillMatrixB:
            switch operationToPerform.type {
            case .Addition, .Subtract, .Multiply:
                return rhsMatrixDimention.count()
            case .Solve, .SolveWithErrorCorrection:
                return rhsMatrixDimention.columns
            default:
                return 0
            }
        case .ComputeOperation:
            return 1
        case .OperationResult:
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let section = Section.fromIndex(indexPath.section)
        
        switch section {
        case .MatrixSize:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MatrixSizeCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! MatrixSizeCollectionViewCell
            
            let numberOfColumnsTitle = NSLocalizedString("Number of columns",
                                                         comment: "Number of columns title")
            let numberOfRowsTitle = NSLocalizedString("Number of rows",
                                                      comment: "Number of rows title")
            
            let index = indexPath.row
            
            switch operationToPerform.type {
            case .Solve, .SolveWithErrorCorrection:
                cell.titleLabel.text = NSLocalizedString("Number of unknowns",
                                                         comment: "Number of unknowns title")
                cell.sizeLabel.text = "\(lhsMatrixDimention.rows)"
            case .Addition, .Subtract, .Transpose, .Determinant, .Invert:
                cell.titleLabel.text = (index % 2 == 0
                    ? numberOfColumnsTitle : numberOfRowsTitle)
                cell.sizeLabel.text  = (index % 2 == 0
                    ? "\(lhsMatrixDimention.columns)" : "\(lhsMatrixDimention.rows)")
            case .Multiply:
                if index < 2 {
                    let matrixA = NSLocalizedString("of the matrix A", comment: "Matrix A end name")
                    cell.titleLabel.text = (index % 2 == 0
                        ? "\(numberOfColumnsTitle) \(matrixA)"
                        : "\(numberOfRowsTitle) \(matrixA)")
                    cell.sizeLabel.text  = (index % 2 == 0
                        ? "\(lhsMatrixDimention.columns)"
                        : "\(lhsMatrixDimention.rows)")
                } else {
                    let matrixB = NSLocalizedString("of the matrix B", comment: "Matrix B end name")
                    cell.titleLabel.text = (index % 2 == 0
                        ? "\(numberOfColumnsTitle) \(matrixB)"
                        : "\(numberOfRowsTitle) \(matrixB)")
                    cell.sizeLabel.text  = (index % 2 == 0
                        ? "\(rhsMatrixDimention.columns)"
                        : "\(rhsMatrixDimention.rows)")
                }
            }
            
            return cell
        case .FillMatrixA, .FillMatrixB:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MatrixItemCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! MatrixItemCollectionViewCell
            cell.itemTextField.delegate = self
            
            if section == .FillMatrixB {
                cell.itemTextField.tag = Section.FillMatrixB.rawValue
                cell.itemTextField.text = "\(rhsMatrixArray[indexPath.row])"
            } else {
                cell.itemTextField.text = "\(lhsMatrixArray[indexPath.row])"
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
        
        switch operationToPerform.type {
        case .Solve, .SolveWithErrorCorrection:
            switch Section.fromIndex(indexPath.section) {
            case .FillMatrixA:
                headerView.headerTitleLabel.text = NSLocalizedString(
                    "Fill a matrix of coefficients",
                    comment: "Matrix of coefficients header view title")
            case .FillMatrixB:
                headerView.headerTitleLabel.text = NSLocalizedString(
                    "Fill a vector of values",
                    comment: "Vector of values header view title")
            default:
                break
            }
            
            return headerView
        default:
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
        
        let defaultInset = UIEdgeInsets(top: EdgeInsets.collectionViewSection.top,
                                        left: EdgeInsets.collectionViewSection.left,
                                        bottom: EdgeInsets.collectionViewSection.bottom,
                                        right: EdgeInsets.collectionViewSection.right)
        
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
        case .FillMatrixB:
            switch operationToPerform.type {
            case .Solve, .SolveWithErrorCorrection:
                let itemWidth = sizeForMatrixItemInSection(Section.FillMatrixA, layout: collectionView.collectionViewLayout as! UICollectionViewFlowLayout).width
                
                let margin = floor((screenSize().width - itemWidth) / 2.0)
                
                return UIEdgeInsets(top: EdgeInsets.collectionViewSection.top, left: margin, bottom: EdgeInsets.collectionViewSection.bottom, right: margin)
            default:
                return defaultInset
            }
        default:
            return defaultInset
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard collectionView.numberOfItemsInSection(section) > 0 else {
            return CGSizeZero
        }
        
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
    
    //------------------------------------------------
    // MARK: UICollectionViewDelegate
    //------------------------------------------------
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        switch Section.fromIndex(indexPath.section) {
        case .ComputeOperation:
            computeOperation()
        case .FillMatrixA, .FillMatrixB:
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! MatrixItemCollectionViewCell
            cell.itemTextField.becomeFirstResponder()
        case .MatrixSize:
            let selectedCell = collectionView.cellForItemAtIndexPath(indexPath) as! MatrixSizeCollectionViewCell
            
            let title = selectedCell.titleLabel.text!
            let rows:[Int] = Array(1...7)
            
            let initialSelection = initialSelectionValueForActionSheetPickerAtIndexPath(indexPath)
            
            ActionSheetStringPicker.showPickerWithTitle(title, rows: rows, initialSelection: initialSelection, doneBlock: { [weak self] (picker, selectedIndex, selectedValue) in
                guard let value = selectedValue as? Int else {
                    return
                }
                print("Did select value: \(value) at index: \(selectedIndex)")
                
                selectedCell.sizeLabel.text = "\(value)"
                self?.updateMatrixDimentionsWithSelectedValue(value, atIndexPath: indexPath)
                }, cancelBlock: { picker in
                    print("User did cancel selection of the size value")
                }, origin: view)
        default:
            break
        }
    }
    
    //------------------------------------------------
    // MARK: Helpers
    //------------------------------------------------
    
    private func updateMatrixDimentionsWithSelectedValue(value: Int, atIndexPath indexPath: NSIndexPath) {
        func setNewDimention(dimention: MatrixDimention) {
            lhsMatrixDimention = dimention
            rhsMatrixDimention = dimention
        }
        
        let newDimention = newMatrixDimentionFromSelectedValue(value, atIndexPath: indexPath)
        
        switch operationToPerform.type {
        case .Addition, .Subtract:
            setNewDimention(newDimention)
        case .Determinant, .Invert:
            setNewDimention(MatrixDimention(columns: value, rows: value))
        case .Multiply, .Transpose:
            if isSelectingNumberOfColumnsAtIndexPath(indexPath) {
                if isLhsMatrixAtIndexPath(indexPath) {
                    lhsMatrixDimention = newDimention
                } else {
                    rhsMatrixDimention = newDimention
                }
            } else {
                if isLhsMatrixAtIndexPath(indexPath) {
                    lhsMatrixDimention = newDimention
                } else {
                    rhsMatrixDimention = newDimention
                }
            }
        case .Solve, .SolveWithErrorCorrection:
            lhsMatrixDimention = MatrixDimention(columns: value, rows: value)
            rhsMatrixDimention = MatrixDimention(columns: value, rows: 1)
        }
        
        initMatrices()
        collectionView.reloadData()
    }
    
    private func initialSelectionValueForActionSheetPickerAtIndexPath(indexPath: NSIndexPath) -> Int {
        if isSelectingNumberOfColumnsAtIndexPath(indexPath) {
            return (isLhsMatrixAtIndexPath(indexPath)
                ? lhsMatrixDimention.columns - 1
                : rhsMatrixDimention.columns - 1)
        } else {
            return (isLhsMatrixAtIndexPath(indexPath)
                ? lhsMatrixDimention.rows - 1
                : rhsMatrixDimention.rows - 1)
        }
    }
    
    private func newMatrixDimentionFromSelectedValue(value: Int, atIndexPath indexPath: NSIndexPath) -> MatrixDimention {
        let originalDimention = originalMatrixDimentionAtIndexPath(indexPath)
        if isSelectingNumberOfColumnsAtIndexPath(indexPath) {
            return MatrixDimention(columns: value, rows: originalDimention.rows)
        } else {
            return MatrixDimention(columns: originalDimention.columns, rows: value)
        }
    }
    
    private func originalMatrixDimentionAtIndexPath(indexPath: NSIndexPath) -> MatrixDimention {
        let columns = (isLhsMatrixAtIndexPath(indexPath)
            ? lhsMatrixDimention.columns
            : rhsMatrixDimention.columns)
        let rows = (isLhsMatrixAtIndexPath(indexPath)
            ? lhsMatrixDimention.rows
            : rhsMatrixDimention.rows)
        
        return MatrixDimention(columns: columns, rows: rows)
    }
    
    private func isSelectingNumberOfColumnsAtIndexPath(indexPath: NSIndexPath) -> Bool {
        return indexPath.row % 2 == 0
    }
    
    private func isLhsMatrixAtIndexPath(indexPath: NSIndexPath) -> Bool {
        return indexPath.row < 2
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
        
        // Add input accessory view to the text field.
        // It enables to return text field.
        
        matrixItemTextFieldInputAccessoryView.parentTextField = textField
        matrixItemTextFieldInputAccessoryView.doneButton.addTarget(
            self,
            action: #selector(ComputeOperationViewController.matrixItemTextFieldDidDoneOnEditing),
            forControlEvents: .TouchUpInside)
        textField.inputAccessoryView = matrixItemTextFieldInputAccessoryView
        
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
        guard let cell = textField.superview?.superview as? MatrixItemCollectionViewCell,
            let indexPath = collectionView.indexPathForCell(cell) else {
                return
        }
        updateMatrixItemFromText(textField.text, andIndexPath: indexPath)
    }
    
    //----------------------------------------------
    // MARK: Input Accessory View
    //----------------------------------------------
    
    func matrixItemTextFieldDidDoneOnEditing() {
        let textField = matrixItemTextFieldInputAccessoryView.parentTextField
        textField.delegate?.textFieldShouldReturn?(textField)
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
