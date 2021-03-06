//
//  AddItemViewController.swift
//  myRecycle
//
//  Created by Ben LOWRY on 4/19/16.
//  Copyright © 2016 Ben LOWRY. All rights reserved.
//

// CLEARED FOR ERROR HANDLING

import Foundation
import UIKit

protocol ItemDetailViewControllerDelegate: class {
    func itemDetailViewControllerDidCancel(_ controller: ItemDetailViewController)
    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishAddingItem item: LogItem)
    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishEditingItem item: LogItem)
}

class ItemDetailViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var materialCell: UITableViewCell!
    @IBOutlet weak var amountCell: UITableViewCell!
    @IBOutlet weak var unitCell: UITableViewCell!
    @IBOutlet weak var pointCell: UITableViewCell!
    
    @IBOutlet weak var materialTextField: UITextField! = UITextField()
    @IBOutlet weak var amountTextField: UITextField! = UITextField()
    @IBOutlet weak var unitTextField: UITextField! = UITextField()
    @IBOutlet weak var pointTextField: UITextField!
    
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    
    @IBOutlet weak var bottomView: UIView!
    
    var materialPickerData: [String] = [String]()
    var materialPickerView = UIPickerView()
    var materialSelectedOption: String = ""
    
    var unitPickerData: [String] = [String]()
    var unitPickerView = UIPickerView()
    var unitSelectedOption: String = ""
    
    var lightningContentLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var waterContentLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var treeContentLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var smokeContentLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var trashContentLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    
    var currentLightningValue: Double = 0.0
    var currentWaterValue: Double = 0.0
    var currentTreeValue: Double = 0.0
    var currentSmokeValue: Double = 0.0
    var currentTrashValue: Double = 0.0
    
    weak var delegate: ItemDetailViewControllerDelegate?
    
    var itemToEdit: LogItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissAmountKeyboard))
        view.addGestureRecognizer(tap)
        
        materialTextField.delegate = self
        amountTextField.delegate = self
        unitTextField.delegate = self
        
        materialPickerView.dataSource = self
        materialPickerView.delegate = self
        materialPickerView.tag = 1
        
        unitPickerView.dataSource = self
        unitPickerView.delegate = self
        unitPickerView.tag = 2

        materialPickerData = ["Aluminum Cans", "Plastic Bags", "Paper", "Food Waste", "Plastic Bottles", "Plastic Packaging", "Glass", "Cardboard", "Electronics", "Rubber"]
        materialPickerData.sort()
        materialPickerData.insert("~ Material Type ~", at: 0)
        
        unitPickerData = ["Pounds", "Kilograms"]
        unitPickerData.insert("~ Unit ~", at: 0)
        
        initializePickerViewToolBar("clearPressedForMaterialPickerView:", doneButtonFunc: "donePressedForMaterialPickerView:", textField: materialTextField)
        initializePickerViewToolBar("clearPressedForUnitPickerView", doneButtonFunc: "donePressedForUnitPickerView", textField: unitTextField)
        
        amountTextField.addTarget(self, action: #selector(ItemDetailViewController.amountTextFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        
        //initialize bottomView width
        bottomView.frame.size.width = UIScreen.main.bounds.width
        
        //view height/width ratio
        let ratio: CGFloat = 312/320
        
        //make the bottom view fill up all the space below the table
        bottomView.frame.size.height = bottomView.frame.width * ratio
        
        if let item = itemToEdit {
            title = "Edit Item"
            materialTextField.text = item.materialType
            amountTextField.text = String(item.amount)
            unitTextField.text = item.unit
            
            materialSelectedOption = materialTextField.text!
            unitSelectedOption = unitTextField.text!
            //this makes sure that the correct unit options will popup
            updateUnitPickerChoices()
            
            //this sets the default index of the pickers to the right point
            initializePickerLocation()
            
            pointTextField.text = String(item.pointWorth)
            
            do {
                
                if materialTextField.text != nil || unitTextField.text != nil {
                    
                    if let amount = Double(amountTextField.text!) {
                        
                        //if it is editting, then the stats will be loaded
                        let previousStats: [Double] = (currentAppStatus.loggedInUser?.updateStats(materialTextField.text!, unit: unitTextField.text!, amount: amount, reducingStats: false))!
                        
                        //to offset the previous call
                        currentAppStatus.loggedInUser?.updateStats(materialTextField.text!, unit: unitTextField.text!, amount: amount, reducingStats: true)
                        
                        setupStatsView(Double(previousStats[0]), previousWater: Double(previousStats[1]), previousTrees: Double(previousStats[2]), previousSmoke: Double(previousStats[3]), previousTrash: Double(previousStats[4]))
                        
                    } else {
                        throw AppError.numberParseError
                    }
                    
                } else {
                    throw AppError.nilError
                }
                
            } catch AppError.numberParseError {
                
                //present error
                let alertController = UIAlertController(title: "Error #E04", message: "Sorry about that, please try again.", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alertController.addAction(alertAction)
                self.present(alertController, animated: true, completion: nil)
                
            } catch AppError.nilError {
                
                //present error
                let alertController = UIAlertController(title: "Error #E01", message: "Sorry about that, please try again.", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alertController.addAction(alertAction)
                self.present(alertController, animated: true, completion: nil)
                
            } catch {
                
                //present error
                let alertController = UIAlertController(title: "Error", message: "Sorry about that, please try again.", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alertController.addAction(alertAction)
                self.present(alertController, animated: true, completion: nil)
                
            }
            
            
        } else {
            
            //if it is not editting, the stats will start at "0.0"
            setupStatsView(0.0, previousWater: 0.0, previousTrees: 0.0, previousSmoke: 0.0, previousTrash: 0.0)
            
        }
        
    
    }
    
    
    //setting tableView rows and sections
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRows: Int = 0
        
        if section == 0 {
            numberOfRows = 1
        } else if section == 1 {
            numberOfRows = 2
        } else if section == 2 {
            numberOfRows = 1
        }
        
        return numberOfRows
    }
    
    //returing static cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cellToReturn: UITableViewCell!
        
        if indexPath.section == 0 {
            
            materialTextField.inputView = materialPickerView
            
            cellToReturn = materialCell
            
        } else if indexPath.section == 1 && indexPath.row == 0 {
            
            unitTextField.inputView = unitPickerView
            
            cellToReturn = unitCell
            
        } else if indexPath.section == 1 && indexPath.row == 1 {
            
            //the amountTextField still uses a keyboard as its inputView
            
            cellToReturn = amountCell
            
        } else if indexPath.section == 2 {
            
            cellToReturn = pointCell
            
        }
        
        return cellToReturn
    }
    
    @IBAction func cancel() {
        delegate?.itemDetailViewControllerDidCancel(self)
    }
    
    @IBAction func done() {
        
        do {
            
            if let item = itemToEdit { //if it is in edit-mode
                
                if materialTextField.text != nil && amountTextField.text != nil && unitTextField.text != nil {
                    
                    if let amount: Double = Double(amountTextField.text!) { //if the amount is a number
                        
                        item.materialType = materialTextField.text!
                        item.amount = amount
                        item.unit = unitTextField.text!
                        
                        currentAppStatus.loggedInUser?.points -= item.pointWorth
                        item.determinePointWorth()
                        
                        /* NOT IN USE
                         currentAppStatus.loggedInUser?.updateStats(materialTextField.text!, unit: unitTextField.text!, amount: Double(amountTextField.text!)!, reducingStats: false)
                         */
                        
                        delegate?.itemDetailViewController(self, didFinishEditingItem: item)
                        
                    } else { //if the amount is not a number
                        
                        throw AppError.numberParseError
                        
                    }
                    
                } else {
                    
                    throw AppError.nilError
                    
                }
                
                
            } else { //if it is in add-mode
                
                //if there is text in each box
                if materialTextField.text != nil && amountTextField.text != nil && unitTextField.text != nil {
                    
                    if let amount: Double = Double(amountTextField.text!) { //if the amount is a number
                        
                        let item = LogItem(materialType: materialTextField.text!, amount: amount, unit: unitTextField.text!)
                        
                        currentAppStatus.loggedInUser?.heartsWarmed += 1
                        
                        delegate?.itemDetailViewController(self, didFinishAddingItem: item)
                        
                    } else {
                        
                        throw AppError.numberParseError
                        
                    }
                    
                } else {
                    
                    throw AppError.nilError
                    
                }
                
            }
            
        } catch AppError.numberParseError {
            
            //present error
            let alertController = UIAlertController(title: "Error #E04", message: "Amount must be a number, please try again.", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
            
        } catch AppError.nilError {
            
            //present error
            let alertController = UIAlertController(title: "Error #E01", message: "One or more fields are empty, please try again.", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
            
        } catch {
            
            //present error
            let alertController = UIAlertController(title: "Error", message: "Sorry about that, please try again.", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
        
    }
    
    
    @IBAction func materialPickerViewDismissed(_ sender: UITextField) {
        
        hideMaterialPicker()
        
    }
    
    @IBAction func unitPickerViewDismissed(_ sender: UITextField) {
        
        updatePointWorthCell()
        
    }
    
    func initializePickerViewToolBar(_ clearButtonFunc: String, doneButtonFunc: String, textField: UITextField){
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: textField.frame.size.height/6, width: textField.frame.size.width, height: 40.0))
        toolBar.layer.position = CGPoint(x: textField.frame.size.width/2, y: textField.frame.size.height-20.0)
        toolBar.barStyle = UIBarStyle.default
        toolBar.tintColor = UIColor.black
        
        let clearButton = UIBarButtonItem(title: "Clear", style: UIBarButtonItemStyle.plain, target: self, action: Selector(clearButtonFunc))
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: Selector(doneButtonFunc))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        toolBar.setItems([clearButton,flexSpace,doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        
        textField.inputAccessoryView = toolBar
        
    }
    
    //for dismissing the keyboard for the amount text field
    func dismissAmountKeyboard() {
        
        amountTextField.endEditing(true)
    }

    /*** Material Picker Done/Clear ***/
    
    func clearPressedForMaterialPickerView(_ sender: UIBarButtonItem) {
        hideMaterialPicker()
        
        materialTextField.text = ""
    }
    
    func donePressedForMaterialPickerView(_ sender: UIBarButtonItem) {
        hideMaterialPicker()
        
    }
    
    func hideMaterialPicker(){
        materialTextField.resignFirstResponder()
        
        updateUnitPickerChoices()
        
        updatePointWorthCell()
        updateStatsView()
    }
    
    func updateUnitPickerChoices() {
        
        if materialSelectedOption == "Aluminum Cans" {
            
            unitPickerData = ["~ Unit ~", "Cans", "Kilograms", "Pounds"]
            
        } else if materialSelectedOption == "Cardboard" {
            
            unitPickerData = ["~ Unit ~", "Kilograms", "Pounds"]
            
        } else if materialSelectedOption == "Electronics" {
            
            unitPickerData = ["~ Unit ~", "Smart Phones", "MP3 Players", "Laptops", "Televisions", "DVD Players", "Kilograms", "Pounds"]
            
        } else if materialSelectedOption == "Food Waste" {
            
            unitPickerData = ["~ Unit ~", "Kilograms", "Pounds"]
            
        } else if materialSelectedOption == "Glass" {
            
            unitPickerData = ["~ Unit ~", "Bottles", "Kilograms", "Pounds"]
            
        } else if materialSelectedOption == "Paper" {
            
            unitPickerData = ["~ Unit ~", "Pages", "Kilograms", "Pounds"]
            
        } else if materialSelectedOption == "Plastic Bags" {
            
            unitPickerData = ["~ Unit ~", "Bags", "Kilograms", "Pounds"]
            
        } else if materialSelectedOption == "Plastic Bottles" {
            
            unitPickerData = ["~ Unit ~", "Bottles", "Kilograms", "Pounds"]
            
        } else if materialSelectedOption == "Plastic Packaging" {
            
            unitPickerData = ["~ Unit ~", "Kilograms", "Pounds"]
            
        } else if materialSelectedOption == "Rubber" {
            
            unitPickerData = ["~ Unit ~", "Kilograms", "Pounds"]
            
        }
        
    }
    
    func initializePickerLocation() {
        
        do {
            
            if materialPickerData.index(of: materialSelectedOption) != nil { //+1 is to account for the "~ Unit ~" row
                
                let materialRowWanted = materialPickerData.index(of: materialSelectedOption)
                materialPickerView.selectRow(materialRowWanted!, inComponent: 0, animated: false)
            
            } else {
                throw AppError.nilError
            }
            
            if unitPickerData.index(of: unitSelectedOption) != nil { //+1 is to account for the "~ Unit ~" row
                
                let unitRowWanted = unitPickerData.index(of: unitSelectedOption)
                unitPickerView.selectRow(unitRowWanted!, inComponent: 0, animated: false)
                
            } else {
                throw AppError.nilError
            }
            
            
        } catch AppError.nilError {
           
            //present error
            let alertController = UIAlertController(title: "Error #E01", message: "Error, please try again.", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
            
        } catch {
            
            //present error
            let alertController = UIAlertController(title: "Error", message: "Sorry about that, please try again.", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
        
        
    }
    
    /*** Unit Picker Done/Clear ***/
    
    func clearPressedForUnitPickerView() {
        unitTextField.resignFirstResponder()
        
        unitTextField.text = nil
        
        updatePointWorthCell()
        updateStatsView()
    }
    
    func donePressedForUnitPickerView() {
        unitTextField.resignFirstResponder()
        
        updatePointWorthCell()
        updateStatsView()
    }
    
    // The number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        var returnIndex: Int = 0
        
        if pickerView.tag == 1 {
            returnIndex = materialPickerData.count
        } else if pickerView.tag == 2 {
            returnIndex = unitPickerData.count
        }
        
        return returnIndex
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        var returnRow: String!
    
        if pickerView.tag == 1 {
            returnRow = materialPickerData[row]
        } else if pickerView.tag == 2 {
            returnRow = unitPickerData[row]
        }
        
        return returnRow
    }
    
    // Catpure the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        
        if pickerView.tag == 1 {
            if materialPickerData[row] == "~ Material Type ~" { //nothing happens
                materialTextField.text = nil
            } else {
                materialTextField.text = materialPickerData[row]
                materialSelectedOption = materialPickerData[row]
            }
            
            
        } else if pickerView.tag == 2 {
            if unitPickerData[row] == "~ Unit ~" { //nothing happens
                unitTextField.text = nil
            } else {
                unitTextField.text = unitPickerData[row]
                unitSelectedOption = unitPickerData[row]
            }
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        /*
        let oldMaterialText: NSString = materialTextField.text!
        let newMaterialText: NSString = oldMaterialText.stringByReplacingCharactersInRange(range, withString: string)

        let oldUnitText: NSString = unitTextField.text!
        let newUnitText: NSString = oldUnitText.stringByReplacingCharactersInRange(range, withString: string)
        
        let oldAmountText: NSString = amountTextField.text!
        let newAmountText: NSString = oldAmountText.stringByReplacingCharactersInRange(range, withString: string)
        */
        
        //for establishing a max character count to avoid Int overload
        let currentCharacterCount = textField.text?.characters.count ?? 0
        
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        
        let newLength = currentCharacterCount + string.characters.count - range.length
        
        return newLength <= 5
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { //called when 'return' key is pressed
        
        textField.resignFirstResponder()
        return true
        
    }
    
    func amountTextFieldDidChange(_ sender: UITextField){
        
        updatePointWorthCell()
        updateStatsView()
        
    }
    
    func updatePointWorthCell() {
        
        if materialTextField.text != nil {
            
            if let amountText: Double = Double(amountTextField.text!) {
                
                if unitTextField.text != nil {
                    
                    let item = LogItem(materialType: materialTextField
                        .text!, amount: amountText, unit: unitTextField.text!)
                    item.determinePointWorth()
                    
                    pointTextField.text = String(item.pointWorth)
                    
                }
                
            }
            
        }
        
    }
    
    func setupStatsView(_ previousLightning: Double, previousWater: Double, previousTrees: Double, previousSmoke: Double, previousTrash: Double){
        
        var imageSize: CGFloat = 0
        var fontSize: CGFloat = 0
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        switch UIScreen.main.bounds.height {
        case 568: //iPhone 5, 5s, 5c
            imageSize = 50
            fontSize = 12
        case 667: //iPhone 6, 6s
            imageSize = 60
            fontSize = 15
        case 736: //iPhone 6 Plus, 6s Plus
            imageSize = 80
            fontSize = 15
        default:
            imageSize = 35
            fontSize = 10
        }
        
        let middleLeftX = (bottomView.frame.width / 2) - (bottomView.frame.width / 4)
        let middleRightX = (bottomView.frame.width / 2) + (bottomView.frame.width / 4)
        
        /* %%%%%%%%% */
        /* LIGHTNING */
        /* %%%%%%%%% */
        
        let lightningImage = UIImage(named: "Lightning")
        let lightningImageView = UIImageView(image: lightningImage)
        
        lightningImageView.frame.size = CGSize(width: imageSize, height: imageSize)
        lightningImageView.frame.origin.x = middleLeftX - imageSize/2
        lightningImageView.frame.origin.y = 20
        
        let lightningTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: fontSize + 5))
        lightningTitleLabel.text = "Energy Saved (kWh):"
        lightningTitleLabel.font = UIFont(name: "AvenirNext-Medium", size: fontSize)
        lightningTitleLabel.textAlignment = .center
        lightningTitleLabel.frame.origin = CGPoint(x: middleLeftX - lightningTitleLabel.frame.width/2, y: 20 + imageSize + 10)
        
        lightningContentLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: fontSize))
        lightningContentLabel.text = numberFormatter.string(from: NSNumber(value: round(previousLightning * 100) / 100))
        lightningContentLabel.font = UIFont(name: "AvenirNext-UltraLight", size: fontSize)
        lightningContentLabel.textAlignment = .center
        lightningContentLabel.frame.origin = CGPoint(x: middleLeftX - lightningContentLabel.frame.width/2, y: 20 + imageSize + 10 + (fontSize + 5) + 10)
        lightningContentLabel.adjustsFontSizeToFitWidth = true
        
        /* %%%%%%%%%% */
        /* WATER DROP */
        /* %%%%%%%%%% */
        
        let waterImage = UIImage(named: "Water Drop")
        let waterImageView = UIImageView(image: waterImage)
        
        waterImageView.frame.size = CGSize(width: imageSize, height: imageSize)
        waterImageView.frame.origin.x = middleRightX - imageSize/2
        waterImageView.frame.origin.y = 20
        
        let waterTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: fontSize + 5))
        waterTitleLabel.text = "Water Saved (liters):"
        waterTitleLabel.font = UIFont(name: "AvenirNext-Medium", size: fontSize)
        waterTitleLabel.textAlignment = .center
        waterTitleLabel.frame.origin = CGPoint(x: middleRightX - waterTitleLabel.frame.width/2, y: 20 + imageSize + 10)
        
        waterContentLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: fontSize))
        waterContentLabel.text = numberFormatter.string(from: NSNumber(value: round(previousWater * 100) / 100))
        waterContentLabel.font = UIFont(name: "AvenirNext-UltraLight", size: fontSize)
        waterContentLabel.textAlignment = .center
        waterContentLabel.frame.origin = CGPoint(x: middleRightX - waterContentLabel.frame.width/2, y: 20 + imageSize + 10 + (fontSize + 5) + 10)
        waterContentLabel.adjustsFontSizeToFitWidth = true
        
        /* %%%% */
        /* TREE */
        /* %%%% */
        
        let previousHeight = 20 + imageSize + 10 + (fontSize + 5) + 10 + fontSize
        
        let treeImage = UIImage(named: "Tree")
        let treeImageView = UIImageView(image: treeImage)
        
        treeImageView.frame.size = CGSize(width: imageSize, height: imageSize)
        treeImageView.frame.origin.x = middleLeftX - imageSize/2
        treeImageView.frame.origin.y = previousHeight + 20
        
        let treeTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: fontSize + 5))
        treeTitleLabel.text = "Trees Saved:"
        treeTitleLabel.font = UIFont(name: "AvenirNext-Medium", size: fontSize)
        treeTitleLabel.textAlignment = .center
        treeTitleLabel.frame.origin = CGPoint(x: middleLeftX - treeTitleLabel.frame.width/2, y: previousHeight + 20 + imageSize + 10)
        
        treeContentLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: fontSize))
        treeContentLabel.text = numberFormatter.string(from: NSNumber(value: round(previousTrees * 100) / 100))
        treeContentLabel.font = UIFont(name: "AvenirNext-UltraLight", size: fontSize)
        treeContentLabel.textAlignment = .center
        treeContentLabel.frame.origin = CGPoint(x: middleLeftX - treeContentLabel.frame.width/2, y: previousHeight + 20 + imageSize + 10 + (fontSize + 5) + 10)
        treeContentLabel.adjustsFontSizeToFitWidth = true
        
        
        /* %%%%% */
        /* SMOKE */
        /* %%%%% */
        
        let smokeImage = UIImage(named: "Smoke")
        let smokeImageView = UIImageView(image: smokeImage)
        
        smokeImageView.frame.size = CGSize(width: imageSize, height: imageSize)
        smokeImageView.frame.origin.x = middleRightX - imageSize/2
        smokeImageView.frame.origin.y = previousHeight + 20
        
        let smokeTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: fontSize + 5))
        smokeTitleLabel.text = "CO2 Prevented (kilos):"
        smokeTitleLabel.font = UIFont(name: "AvenirNext-Medium", size: fontSize)
        smokeTitleLabel.textAlignment = .center
        smokeTitleLabel.frame.origin = CGPoint(x: middleRightX - smokeTitleLabel.frame.width/2, y: previousHeight + 20 + imageSize + 10)
        
        smokeContentLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: fontSize))
        smokeContentLabel.text = numberFormatter.string(from: NSNumber(value: round(previousSmoke * 100) / 100))
        smokeContentLabel.font = UIFont(name: "AvenirNext-UltraLight", size: fontSize)
        smokeContentLabel.textAlignment = .center
        smokeContentLabel.frame.origin = CGPoint(x: middleRightX - smokeContentLabel.frame.width/2, y: previousHeight + 20 + imageSize + 10 + (fontSize + 5) + 10)
        smokeContentLabel.adjustsFontSizeToFitWidth = true
        
        /* %%%%% */
        /* TRASH */
        /* %%%%% */
        
        trashContentLabel.isHidden = true
        trashContentLabel.text = numberFormatter.string(from: NSNumber(value: round(previousTrash * 100) / 100))

        bottomView.addSubview(lightningTitleLabel)
        bottomView.addSubview(lightningContentLabel)
        
        bottomView.addSubview(waterTitleLabel)
        bottomView.addSubview(waterContentLabel)
        
        bottomView.addSubview(treeTitleLabel)
        bottomView.addSubview(treeContentLabel)
        
        bottomView.addSubview(smokeTitleLabel)
        bottomView.addSubview(smokeContentLabel)
        
        bottomView.addSubview(lightningImageView)
        bottomView.addSubview(waterImageView)
        bottomView.addSubview(treeImageView)
        bottomView.addSubview(smokeImageView)
       
    }
    
    func updateStatsView() {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        //to offset the new numbers being added
        currentAppStatus.loggedInUser?.electricitySaved -= Double(lightningContentLabel.text!.replacingOccurrences(of: ",", with: ""))!
        currentAppStatus.loggedInUser?.waterSaved -= Double(waterContentLabel.text!.replacingOccurrences(of: ",", with: ""))!
        currentAppStatus.loggedInUser?.treesSaved -= Double(treeContentLabel.text!.replacingOccurrences(of: ",", with: ""))!
        currentAppStatus.loggedInUser?.carbonDioxideEmissionsPrevented -= Double(smokeContentLabel.text!.replacingOccurrences(of: ",", with: ""))!
        currentAppStatus.loggedInUser?.trashRecycled -= Double(trashContentLabel.text!.replacingOccurrences(of: ",", with: ""))!
        
        if let amount: Double = Double(amountTextField.text!) {
            
            let changeValues: [Double] = (currentAppStatus.loggedInUser?.updateStats(materialTextField.text!, unit: unitTextField.text!, amount: amount, reducingStats: false))!
            
            //to offset the previous call
            //currentAppStatus.loggedInUser?.updateStats(materialTextField.text!, unit: unitTextField.text!, amount: amount, reducingStats: true)
            
            lightningContentLabel.text = numberFormatter.string(from: NSNumber(value: round(changeValues[0] * 100) / 100))
            waterContentLabel.text = numberFormatter.string(from: NSNumber(value: round(changeValues[1] * 100) / 100))
            treeContentLabel.text = numberFormatter.string(from: NSNumber(value: round(changeValues[2] * 100) / 100))
            smokeContentLabel.text = numberFormatter.string(from: NSNumber(value: round(changeValues[3] * 100) / 100))
            trashContentLabel.text = numberFormatter.string(from: NSNumber(value: round(changeValues[4] * 100) / 100))
            
            currentLightningValue = Double(lightningContentLabel.text!.replacingOccurrences(of: ",", with: ""))!
            currentWaterValue = Double(waterContentLabel.text!.replacingOccurrences(of: ",", with: ""))!
            currentTreeValue = Double(treeContentLabel.text!.replacingOccurrences(of: ",", with: ""))!
            currentSmokeValue = Double(smokeContentLabel.text!.replacingOccurrences(of: ",", with: ""))!
            currentTrashValue = Double(trashContentLabel.text!.replacingOccurrences(of: ",", with: ""))!
            
        } else {
            
            lightningContentLabel.text = "0.0"
            waterContentLabel.text = "0.0"
            treeContentLabel.text = "0.0"
            smokeContentLabel.text = "0.0"
            trashContentLabel.text = "0.0"
            
        }
        
    }
    
}
