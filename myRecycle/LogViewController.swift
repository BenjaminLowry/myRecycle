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
    
    override func viewWillAppear(animated: Bool) {
        homeBarButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir Next", size: 15)!], forState: UIControlState.Normal)
        
    }
    
    //determining what version of the ItemDetailViewController to segue to
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        do {
            
            if segue.identifier == "AddItem" {
                
                let navigationController = segue.destinationViewController as! UINavigationController
                
                let controller = navigationController.topViewController as! ItemDetailViewController
                
                controller.delegate = self
                
            } else if segue.identifier == "EditItem" {
                
                let navigationController = segue.destinationViewController as! UINavigationController
                
                let controller = navigationController.topViewController as! ItemDetailViewController
                
                controller.delegate = self
                
                if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell){
                    
                    controller.itemToEdit = items[indexPath.row]
                    
                } else {
                    
                    throw AppError.CellNotFoundError
                    
                }
                
            }
            
        } catch AppError.CellNotFoundError {
            
            //present error
            let alertController = UIAlertController(title: "Error #E02", message: "Sorry about that, please try again.", preferredStyle: .Alert)
            let alertAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alertController.addAction(alertAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } catch {
            
            //present error
            let alertController = UIAlertController(title: "Error", message: "Sorry about that, please try again.", preferredStyle: .Alert)
            let alertAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alertController.addAction(alertAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Logitem", forIndexPath: indexPath)
        
        let item = items[indexPath.row]
        
        configureTextForCell(cell, withChecklistItem: item)
        
        return cell
    }
    
    @IBAction func returnHome (sender: AnyObject){
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func itemDetailViewControllerDidCancel(controller: ItemDetailViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func itemDetailViewController(controller: ItemDetailViewController, didFinishAddingItem item: LogItem) {
        
        let newRowIndex = items.count
        
        items.append(item)
        
        let indexPath = NSIndexPath(forRow: newRowIndex, inSection: 0)
        let indexPaths = [indexPath]
        
        tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
        
        //adding the item's points to the user's points
        currentAppStatus.loggedInUser?.points += item.pointWorth
        
        saveChecklistItems()
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func itemDetailViewController(controller: ItemDetailViewController, didFinishEditingItem item: LogItem) {
        
        if let index = items.indexOf(item) {
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            
            if let cell = tableView.cellForRowAtIndexPath(indexPath){
                configureTextForCell(cell, withChecklistItem: item)
            }
            
        }
        
        //re-adding the points for the editted item
        currentAppStatus.loggedInUser?.points += item.pointWorth
        
        saveChecklistItems()
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func configureTextForCell(cell: UITableViewCell, withChecklistItem item: LogItem) {
        
        let materialLabel = cell.viewWithTag(1000) as! UILabel
        materialLabel.text = item.materialType
        materialLabel.adjustsFontSizeToFitWidth = true
        
        let amountLabel = cell.viewWithTag(1001) as! UILabel
        amountLabel.text = String(Double(round(100*item.amount)/100)) + " " + item.unit
        amountLabel.adjustsFontSizeToFitWidth = true
        
    }
    
    //deleting a log entry
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let item = items[indexPath.row]
        
        //subtracting item points from user's total points
        currentAppStatus.loggedInUser?.points -= item.pointWorth
        
        //updating stats
        currentAppStatus.loggedInUser?.updateStats(item.materialType, unit: item.unit, amount: item.amount, reducingStats: true)
        currentAppStatus.loggedInUser?.heartsWarmed -= 1
        
        items.removeAtIndex(indexPath.row)
        
        let indexPaths = [indexPath]
        tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
        
        saveChecklistItems()
    }
    
    func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return paths[0]
    }
    
    func dataFilePath() -> String {
        return (documentsDirectory() as NSString).stringByAppendingPathComponent("LogItems.plist")
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
