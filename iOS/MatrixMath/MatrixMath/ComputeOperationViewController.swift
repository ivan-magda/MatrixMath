//
//  ComputeOperationViewController.swift
//  MatrixMath
//
//  Created by Ivan Magda on 07.04.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import SVProgressHUD

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
    
    private var lhsMatrixDimension: MatrixDimension!
    private var rhsMatrixDimension: MatrixDimension!
    private var resultMatrixDimension: MatrixDimension?
    
    private var lhsMatrixArray: [Double]!
    private var rhsMatrixArray: [Double]!
    private var resultMatrixArray: [Double]?
    
    private lazy var numberFormatter: NSNumberFormatter = {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .DecimalStyle
        
        return numberFormatter
    }()
    
    private var keyboardOnScreen = false
    
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
    
    func performOperation() {
        func presentAlertWithError(error: NSError) {
            hideNetworkActivityIndicator()
            SVProgressHUD.dismiss()
            presentAlert(message: error.localizedDescription)
        }
        
        func presentEmptyResultAlert() {
            hideNetworkActivityIndicator()
            SVProgressHUD.dismiss()
            presentAlert(
                message: NSLocalizedString("An empty result returned",
                comment: "Empty result error message"))
        }
        
        func doneWithSuccess(result result: [Double], dimension: MatrixDimension) {
            resultMatrixArray = result
            resultMatrixDimension = dimension
            
            hideNetworkActivityIndicator()
            SVProgressHUD.showSuccessWithStatus(NSLocalizedString("Successfully",
                comment: "Successfully status"))
            
            collectionView.reloadData()
        }
        
        guard let lhsMatrix = Matrix(data: lhsMatrixArray, dimension: lhsMatrixDimension) else {
            presentAlert(message: NSLocalizedString("Could't perform operation", comment: "Failed to perfrom operation message"))
            return
        }
        
        SVProgressHUD.showWithStatus(NSLocalizedString("Computing...", comment: "Computing status"))
        showNetworkActivityIndicator()
        
        let type = operationToPerform.type
        switch type {
        case .Determinant:
            apiClient.determinant(matrix: lhsMatrix, completionHandler: { (determinant, error) in
                performOnMain {
                    guard error == nil else {
                        presentAlertWithError(error!)
                        return
                    }
                    
                    guard determinant != nil else {
                        presentEmptyResultAlert()
                        return
                    }
                    print("Determinant = \(determinant!)")
                    
                    doneWithSuccess(result: [determinant!],
                        dimension: MatrixDimension(columns: 1, rows: 1))
                }
            })
        case .Solve, .SolveWithErrorCorrection:
            apiClient.performSolveOperationWithType(type, coefficientsMatrix: lhsMatrix, valuesVector: rhsMatrixArray, completionHandler: { (vector, error) in
                performOnMain {
                    guard error == nil else {
                        presentAlertWithError(error!)
                        return
                    }
                    
                    guard vector != nil else {
                        presentEmptyResultAlert()
                        return
                    }
                    print("Solution vector: \(vector!)")
                    
                    let dimension = MatrixDimension(columns: vector!.count, rows: 1)
                    doneWithSuccess(result: vector!, dimension: dimension)
                }
            })
        default:
            var matrices = [lhsMatrix]
            if let rhsMatrix = Matrix(data: rhsMatrixArray, dimension: rhsMatrixDimension) {
                matrices.append(rhsMatrix)
            }
            
            apiClient.performMatrixOperationWithType(type, matrices: matrices, withCompletionHandler: { (matrix, error) in
                performOnMain {
                    guard error == nil else {
                        presentAlertWithError(error!)
                        return
                    }
                    
                    guard matrix != nil else {
                        presentEmptyResultAlert()
                        return
                    }
                    print("\(self.operationToPerform.name): \(matrix!.data))")
                    
                    doneWithSuccess(result: matrix!.getLinearArray(), dimension: matrix!.dimension)
                }
            })
        }
    }
    
    //------------------------------------------------
    // MARK: - Helpers
    //------------------------------------------------
    
    private func setup() {
        configureUI()
    
        // Configure matrix dimentions and data source.
        
        let defaultsMatrixDimention = MatrixDimension(columns: 3, rows: 3)
        lhsMatrixDimension = defaultsMatrixDimention
        
        switch operationToPerform.type {
        case .Addition, .Subtract, .Multiply:
            rhsMatrixDimension = defaultsMatrixDimention
        case .Solve, .SolveWithErrorCorrection:
            rhsMatrixDimension = MatrixDimension(columns: 3, rows: 1)
        default:
            rhsMatrixDimension = MatrixDimension(columns: 0, rows: 0)
        }
        
        initMatrices()
    }
    
    private func initMatrices() {
        lhsMatrixArray = [Double](count: lhsMatrixDimension.count(), repeatedValue: 0.0)
        rhsMatrixArray = [Double](count: rhsMatrixDimension.count(), repeatedValue: 0.0)
    }
    
    private func updateMatrixItem(itemTextField textField: MatrixItemTextField) {
        let text = textField.text
        let indexPath = textField.indexPath
        
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
        
        SVProgressHUD.setForegroundColor(UIColor.blackColor())
        SVProgressHUD.setBackgroundColor(UIColor(
            colorLiteralRed: 239.0 / 255.0,
            green: 239.0 / 255.0,
            blue: 244.0 / 255.0,
            alpha: 1.0)
        )
    }
    
    private func presentAlert(title title: String = NSLocalizedString("Error", comment: "Error"), message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    private func sizeForCollectionViewItemInSection(section: Section) -> CGSize {
        let screenWidth = screenSize().width
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        switch section {
        case .FillMatrixA, .FillMatrixB, .OperationResult:
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
            rows = lhsMatrixDimension.rows
        case .FillMatrixB:
            rows = rhsMatrixDimension.rows
        case .OperationResult:
            rows = resultMatrixDimension!.rows
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
            return lhsMatrixDimension.count()
        case .FillMatrixB:
            switch operationToPerform.type {
            case .Addition, .Subtract, .Multiply:
                return rhsMatrixDimension.count()
            case .Solve, .SolveWithErrorCorrection:
                return rhsMatrixDimension.columns
            default:
                return 0
            }
        case .ComputeOperation:
            return 1
        case .OperationResult:
            return resultMatrixDimension?.count() ?? 0
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
                cell.sizeLabel.text = "\(lhsMatrixDimension.rows)"
            case .Addition, .Subtract, .Transpose, .Determinant, .Invert:
                cell.titleLabel.text = (index % 2 == 0
                    ? numberOfColumnsTitle : numberOfRowsTitle)
                cell.sizeLabel.text  = (index % 2 == 0
                    ? "\(lhsMatrixDimension.columns)" : "\(lhsMatrixDimension.rows)")
            case .Multiply:
                if index < 2 {
                    let matrixA = NSLocalizedString("of the matrix A", comment: "Matrix A end name")
                    cell.titleLabel.text = (index % 2 == 0
                        ? "\(numberOfColumnsTitle) \(matrixA)"
                        : "\(numberOfRowsTitle) \(matrixA)")
                    cell.sizeLabel.text  = (index % 2 == 0
                        ? "\(lhsMatrixDimension.columns)"
                        : "\(lhsMatrixDimension.rows)")
                } else {
                    let matrixB = NSLocalizedString("of the matrix B", comment: "Matrix B end name")
                    cell.titleLabel.text = (index % 2 == 0
                        ? "\(numberOfColumnsTitle) \(matrixB)"
                        : "\(numberOfRowsTitle) \(matrixB)")
                    cell.sizeLabel.text  = (index % 2 == 0
                        ? "\(rhsMatrixDimension.columns)"
                        : "\(rhsMatrixDimension.rows)")
                }
            }
            
            return cell
        case .FillMatrixA, .FillMatrixB:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MatrixItemCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! MatrixItemCollectionViewCell
            cell.itemTextField.delegate = self
            cell.itemTextField.enabled = true
            cell.itemTextField.indexPath = indexPath
            
            if section == .FillMatrixB {
                cell.itemTextField.text = "\(rhsMatrixArray[indexPath.row])"
            } else {
                cell.itemTextField.text = "\(lhsMatrixArray[indexPath.row])"
            }
            
            return cell
        case .ComputeOperation:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ComputeOperationCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! ComputeOperationCollectionViewCell
            cell.computeButton.addTarget(self, action: #selector(performOperation), forControlEvents: .TouchUpInside)
            
            return cell
        case .OperationResult:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MatrixItemCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! MatrixItemCollectionViewCell
            cell.itemTextField.enabled = false
            cell.itemTextField.text = "\(resultMatrixArray![indexPath.row])"
            
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: MatrixHeaderView.reuseIdentifier, forIndexPath: indexPath) as! MatrixHeaderView
        
        if indexPath.section == Section.OperationResult.rawValue {
            headerView.headerTitleLabel.text = NSLocalizedString("Computing result",
                                                                 comment: "Computing result header title")
            return headerView
        }
        
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
        func generateInsetsLikeInFillMatrixASection() -> UIEdgeInsets {
            let itemWidth = sizeForMatrixItemInSection(Section.FillMatrixA, layout: collectionView.collectionViewLayout as! UICollectionViewFlowLayout).width
            
            let margin = floor((screenSize().width - itemWidth) / 2.0)
            
            return UIEdgeInsets(top: EdgeInsets.collectionViewSection.top, left: margin, bottom: EdgeInsets.collectionViewSection.bottom, right: margin)
        }
        
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
                return generateInsetsLikeInFillMatrixASection()
            default:
                return defaultInset
            }
        case .OperationResult:
            switch operationToPerform.type {
            case .Solve, .SolveWithErrorCorrection, .Determinant:
                return generateInsetsLikeInFillMatrixASection()
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
        case .FillMatrixA, .FillMatrixB, .OperationResult:
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
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section != Section.OperationResult.rawValue
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        switch Section.fromIndex(indexPath.section) {
        case .ComputeOperation:
            performOperation()
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
        func setNewDimention(dimension: MatrixDimension) {
            lhsMatrixDimension = dimension
            rhsMatrixDimension = dimension
            resultMatrixDimension = nil
            resultMatrixArray = nil
        }
        
        let newDimension = newMatrixDimentionFromSelectedValue(value, atIndexPath: indexPath)
        
        switch operationToPerform.type {
        case .Addition, .Subtract:
            setNewDimention(newDimension)
        case .Determinant, .Invert:
            setNewDimention(MatrixDimension(columns: value, rows: value))
        case .Multiply, .Transpose:
            if isSelectingNumberOfColumnsAtIndexPath(indexPath) {
                if isLhsMatrixAtIndexPath(indexPath) {
                    lhsMatrixDimension = newDimension
                } else {
                    rhsMatrixDimension = newDimension
                }
            } else {
                if isLhsMatrixAtIndexPath(indexPath) {
                    lhsMatrixDimension = newDimension
                } else {
                    rhsMatrixDimension = newDimension
                }
            }
        case .Solve, .SolveWithErrorCorrection:
            lhsMatrixDimension = MatrixDimension(columns: value, rows: value)
            rhsMatrixDimension = MatrixDimension(columns: value, rows: 1)
        }
        
        initMatrices()
        collectionView.reloadData()
    }
    
    private func initialSelectionValueForActionSheetPickerAtIndexPath(indexPath: NSIndexPath) -> Int {
        if isSelectingNumberOfColumnsAtIndexPath(indexPath) {
            return (isLhsMatrixAtIndexPath(indexPath)
                ? lhsMatrixDimension.columns - 1
                : rhsMatrixDimension.columns - 1)
        } else {
            return (isLhsMatrixAtIndexPath(indexPath)
                ? lhsMatrixDimension.rows - 1
                : rhsMatrixDimension.rows - 1)
        }
    }
    
    private func newMatrixDimentionFromSelectedValue(value: Int, atIndexPath indexPath: NSIndexPath) -> MatrixDimension {
        let originalDimention = originalMatrixDimentionAtIndexPath(indexPath)
        if isSelectingNumberOfColumnsAtIndexPath(indexPath) {
            return MatrixDimension(columns: value, rows: originalDimention.rows)
        } else {
            return MatrixDimension(columns: originalDimention.columns, rows: value)
        }
    }
    
    private func originalMatrixDimentionAtIndexPath(indexPath: NSIndexPath) -> MatrixDimension {
        let columns = (isLhsMatrixAtIndexPath(indexPath)
            ? lhsMatrixDimension.columns
            : rhsMatrixDimension.columns)
        let rows = (isLhsMatrixAtIndexPath(indexPath)
            ? lhsMatrixDimension.rows
            : rhsMatrixDimension.rows)
        
        return MatrixDimension(columns: columns, rows: rows)
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
            presentAlert(
                title: NSLocalizedString("Incorrect input", comment: "Incorrect input title"),
                message: NSLocalizedString("Pleasy enter valid data", comment: "incorrect input message")
            )
            return false
        }
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        return isMatrixItemInputCorrect(textField.text)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        updateMatrixItem(itemTextField: textField as! MatrixItemTextField)
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
        if !keyboardOnScreen {
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
        if keyboardOnScreen {
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
