//
//  LogViewController.swift
//  myRecycle
//
//  Created by Ben LOWRY on 3/16/16.
//  Copyright © 2016 Ben LOWRY. All rights reserved.
//

// CLEARED FOR ERROR HANDLING

import Foundation
import UIKit

class LogViewController: UITableViewController, ItemDetailViewControllerDelegate {
    
    @IBOutlet weak var homeBarButton: UIBarButtonItem!
    
    var items: [LogItem]
    
    required init?(coder aDecoder: NSCoder){
        items = [LogItem]()
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        loadChecklistItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        homeBarButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir Next", size: 15)!], for: UIControlState())
        
    }
    
    //determining what version of the ItemDetailViewController to segue to
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        do {
            
            if segue.identifier == "AddItem" {
                
                let navigationController = segue.destination as! UINavigationController
                
                let controller = navigationController.topViewController as! ItemDetailViewController
                
                controller.delegate = self
                
            } else if segue.identifier == "EditItem" {
                
                let navigationController = segue.destination as! UINavigationController
                
                let controller = navigationController.topViewController as! ItemDetailViewController
                
                controller.delegate = self
                
                if let indexPath = tableView.indexPath(for: sender as! UITableViewCell){
                    
                    controller.itemToEdit = items[indexPath.row]
                    
                } else {
                    
                    throw AppError.cellNotFoundError
                    
                }
                
            }
            
        } catch AppError.cellNotFoundError {
            
            //present error
            let alertController = UIAlertController(title: "Error #E02", message: "Sorry about that, please try again.", preferredStyle: .alert)
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Logitem", for: indexPath)
        
        let item = items[indexPath.row]
        
        configureTextForCell(cell, withChecklistItem: item)
        
        return cell
    }
    
    @IBAction func returnHome (_ sender: AnyObject){
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func itemDetailViewControllerDidCancel(_ controller: ItemDetailViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishAddingItem item: LogItem) {
        
        let newRowIndex = items.count
        
        items.append(item)
        
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        let indexPaths = [indexPath]
        
        tableView.insertRows(at: indexPaths, with: .automatic)
        
        //adding the item's points to the user's points
        currentAppStatus.loggedInUser?.points += item.pointWorth
        
        saveChecklistItems()
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishEditingItem item: LogItem) {
        
        if let index = items.index(of: item) {
            let indexPath = IndexPath(row: index, section: 0)
            
            if let cell = tableView.cellForRow(at: indexPath){
                configureTextForCell(cell, withChecklistItem: item)
            }
            
        }
        
        //re-adding the points for the edited item
        currentAppStatus.loggedInUser?.points += item.pointWorth
        
        saveChecklistItems()
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func configureTextForCell(_ cell: UITableViewCell, withChecklistItem item: LogItem) {
        
        let materialLabel = cell.viewWithTag(1000) as! UILabel
        materialLabel.text = item.materialType
        materialLabel.adjustsFontSizeToFitWidth = true
        
        let amountLabel = cell.viewWithTag(1001) as! UILabel
        amountLabel.text = String(Double(round(100*item.amount)/100)) + " " + item.unit
        amountLabel.adjustsFontSizeToFitWidth = true
        
    }
    
    //deleting a log entry
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let item = items[indexPath.row]
        
        //subtracting item points from user's total points
        currentAppStatus.loggedInUser?.points -= item.pointWorth
        
        //updating stats
        currentAppStatus.loggedInUser?.updateStats(item.materialType, unit: item.unit, amount: item.amount, reducingStats: true)
        currentAppStatus.loggedInUser?.heartsWarmed -= 1
        
        items.remove(at: indexPath.row)
        
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
        
        saveChecklistItems()
    }
    
    func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        return paths[0]
    }
    
    func dataFilePath() -> String {
        return (documentsDirectory() as NSString).appendingPathComponent("LogItems.plist")
    }
    
    func saveChecklistItems() {
        
        currentAppStatus.loggedInUser?.logItems = items
        currentAppStatus.saveLocalData()
        
    }
    
    func loadChecklistItems() {
        
        if let tempItems = currentAppStatus.loggedInUser?.logItems {
            items = tempItems
        }
        
    }
    
}
