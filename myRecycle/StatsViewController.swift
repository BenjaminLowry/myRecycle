//
//  StatsViewController.swift
//  myRecycle
//
//  Created by Ben LOWRY on 3/21/16.
//  Copyright © 2016 Ben LOWRY. All rights reserved.
//

// CLEARED FOR ERROR HANDLING

import Foundation
import UIKit

class StatsViewController: UIViewController {
    
    //@IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bodyView: UIView!
    @IBOutlet weak var homeBarButton: UIBarButtonItem!
    
    @IBOutlet weak var smokeImageView: UIImageView!
    @IBOutlet weak var treeImageView: UIImageView!
    @IBOutlet weak var waterImageView: UIImageView!
    @IBOutlet weak var lightningImageView: UIImageView!
    @IBOutlet weak var heartImageView: UIImageView!
    @IBOutlet weak var trashImageView: UIImageView!
    
    var highlightedImageView: UIImageView?
    
    @IBOutlet weak var middleHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomHeightConstraint: NSLayoutConstraint!
    
    var tempView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var tempViewHeight: CGFloat = 0
    var titleLabel: UILabel = UILabel(frame: CGRect())
    var contentLabel: UILabel = UILabel(frame: CGRect())
    
    var standardDisplacement: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activateIcons([smokeImageView, treeImageView, waterImageView, lightningImageView, heartImageView, trashImageView])
        
        bodyView.addSubview(tempView)
        
        //determine how much items should move
        if UIScreen.mainScreen().bounds.height == 480 { //iPhone 4s
            standardDisplacement = 50
        } else if UIScreen.mainScreen().bounds.height == 568 { //iPhone 5, 5s, 5c
            standardDisplacement = 70
        } else if UIScreen.mainScreen().bounds.height == 667 { //iPhone 6, 6s
            standardDisplacement = 80
        } else if UIScreen.mainScreen().bounds.height == 736 { //iPhone 6 Plus, 6s Plus
            standardDisplacement = 100
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        homeBarButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir Next", size: 15)!], forState: UIControlState.Normal)
    }
    
    override func viewDidLayoutSubviews() {
        
        layoutBody()
        
    }
    
    @IBAction func returnHome (sender: AnyObject){
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func activateIcons(icons: [UIImageView]){
        
        for index in 0..<icons.count {
            
            let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(StatsViewController.imageTapped(_:)))
            icons[index].userInteractionEnabled = true
            icons[index].addGestureRecognizer(tapGestureRecognizer)

        }
    }
    
    func imageTapped(recognizer: UITapGestureRecognizer){
        
        var imageViewLayout = [lightningImageView, waterImageView, treeImageView, smokeImageView, trashImageView, heartImageView]
        
        //identify sender view
        let tappedView = recognizer.view as! UIImageView
        
        //set basic local variables
        var tappedViewIndex = imageViewLayout.indexOf{
            $0 == tappedView
        }
        
        var tempViewHeight: CGFloat = 0
        if tappedViewIndex <= 1 { //if the tapped view is in the first row
            let otherView = imageViewLayout[tappedViewIndex! + 2] //takes view from second row
            tempViewHeight = otherView.frame.origin.y - (tappedView.frame.origin.y + tappedView.frame.height) - 20 + standardDisplacement
        } else { //if the tapped view is in the second or third row
            let otherView = imageViewLayout[tappedViewIndex! - 2]
            tempViewHeight = tappedView.frame.origin.y - (otherView.frame.origin.y + otherView.frame.height) - 20 + standardDisplacement
        }
        
        /* ### EXPLANATION ###
         
        the following statement prevents larger tempViewHeights from being used when the items have been moved farther away from each other
         
        this problem occurs when switching item selection directly, which takes the expanded height based on the current position, which is inaccurate
         
        */
        if self.tempViewHeight == 0 { //if it has not been initialized before
            
            self.tempViewHeight = tempViewHeight
        }
        
        //find lower views of the tapped view
        var tappedLowerViews: [UIImageView] = []
        tappedViewIndex = tappedViewIndex! + 1
        if tappedViewIndex! % 2 == 0 { //if the icon is at the end of the row
            for index in tappedViewIndex! ..< imageViewLayout.count {
                tappedLowerViews.append(imageViewLayout[index]) //add lower views
            }
        } else { //if the icon is at the beginning of the row
            for index in tappedViewIndex! + 1 ..< imageViewLayout.count { //+1 to account for other icon in the row
                tappedLowerViews.append(imageViewLayout[index]) //add lower views
            }
        }
        
        //find lower views of the selected view
        var highlightedLowerViews: [UIImageView] = []
        if highlightedImageView != nil { //if there is a highlighted view
            
            let highlightedViewIndex = imageViewLayout.indexOf{
                $0 == highlightedImageView
                }! + 1 //+1 to convert to 1,2,3,4....
            if highlightedViewIndex % 2 == 0 { //if the icon is at the end of the row
                for index in highlightedViewIndex ..< imageViewLayout.count {
                    highlightedLowerViews.append(imageViewLayout[index]) //add lower views
                }
            } else { //if the icon is at the beginning of the row
                for index in highlightedViewIndex + 1 ..< imageViewLayout.count { //+1 to account for other icon in the row
                    highlightedLowerViews.append(imageViewLayout[index]) //add lower views
                }
    
            }
            
        }
        
        //set highlight settings
        tappedView.highlighted = true
        highlightedImageView?.highlighted = false
        
        if highlightedImageView == tappedView { //if the icon is being 'deselected'
            
            //un-highlight the view
            highlightedImageView!.highlighted = false
            highlightedImageView = nil //there is currently not highlighted view
            
            closeTempView(tappedLowerViews, highlightedLowerViews: highlightedLowerViews, tempViewHeight: self.tempViewHeight, tappedView: tappedView, reopen: false)
            
        } else { //if the icon is being 'selected'
            /*
                $$$$$ THIS NEEDS TO BE EXPANDED TO INCLUDE SWITCHING TO OTHER ICONS $$$$$
            */
            
            var closeFirst: Bool = false
            
            if highlightedImageView != nil { //if there is another icon already highlighted
                
                if highlightedImageView?.frame.origin.y == tappedView.frame.origin.y { //if the icons are on the same row
                    
                    //set the current icon as the highlighted icon
                    highlightedImageView = tappedView
                    
                    titleLabel.removeFromSuperview()
                    contentLabel.removeFromSuperview()
                    
                    setLabels(tappedView)
                    
                    //the icons don't need to move, so stop execution
                    return
                    
                } else if highlightedImageView?.frame.origin.y != tappedView.frame.origin.y { //if the icons are not on the same row
                                        //animation needs to happen again for the other row
                    closeFirst = true
                    
                }
                
                
            }
            
            if closeFirst {
                
                closeTempView(tappedLowerViews, highlightedLowerViews: highlightedLowerViews, tempViewHeight: self.tempViewHeight, tappedView: tappedView, reopen: true)
                
            } else {
                
                //initialize tempView
                tempView.frame.origin.y = tappedView.frame.height + tappedView.frame.origin.y + 10
                tempView.frame.size.width = bodyView.frame.width
                //height and x still remain zero
                tempView.backgroundColor = UIColor(red: 178/255, green: 223/255, blue: 146/255, alpha: 1)
                
                openTempView(tappedLowerViews, tappedView: tappedView, tempViewHeight: self.tempViewHeight, reopened: false)
                
            }
            
            //set the current icon as the highlighted icon
            highlightedImageView = tappedView
            
        }
        
    }
    
    func openTempView(tappedLowerViews: [UIView], tappedView: UIView, tempViewHeight: CGFloat, reopened: Bool) {
        
        lightningImageView.userInteractionEnabled = false
        waterImageView.userInteractionEnabled = false
        treeImageView.userInteractionEnabled = false
        smokeImageView.userInteractionEnabled = false
        trashImageView.userInteractionEnabled = false
        heartImageView.userInteractionEnabled = false
        
        //animate icons moving down / up
        UIView.animateWithDuration(0.3, delay: 0.1, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            
            for index in 0..<tappedLowerViews.count {
                
                tappedLowerViews[index].frame.origin.y += self.standardDisplacement
                
            }
            
            if tappedLowerViews.count > 2 { //if there are two rows being moved
                
                self.middleHeightConstraint.constant += self.standardDisplacement
                self.bottomHeightConstraint.constant += self.standardDisplacement
                
            } else if tappedLowerViews.count == 2 {
                
                self.bottomHeightConstraint.constant += self.standardDisplacement
                
            }
            
            }, completion: {(finished: Bool) in //when the icons have finished moving:
                
                //animate tempView appearing
                UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    
                    self.tempView.frame.size.height = tempViewHeight
                    
                    }, completion: {(finished: Bool) in
                        
                        //add labels
                        self.setLabels(tappedView)
                        
                        self.lightningImageView.userInteractionEnabled = true
                        self.waterImageView.userInteractionEnabled = true
                        self.treeImageView.userInteractionEnabled = true
                        self.smokeImageView.userInteractionEnabled = true
                        self.trashImageView.userInteractionEnabled = true
                        self.heartImageView.userInteractionEnabled = true
                        
                })
                
        })

        
    }
    
    func closeTempView(tappedLowerViews: [UIView], highlightedLowerViews: [UIView], tempViewHeight: CGFloat, tappedView: UIView, reopen: Bool) {
        
        lightningImageView.userInteractionEnabled = false
        waterImageView.userInteractionEnabled = false
        treeImageView.userInteractionEnabled = false
        smokeImageView.userInteractionEnabled = false
        trashImageView.userInteractionEnabled = false
        heartImageView.userInteractionEnabled = false
        
        //remove the labels from the screen
        titleLabel.removeFromSuperview()
        contentLabel.removeFromSuperview()
        
        //animate the tempView shrinking
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            
            self.tempView.frame.size.height = 0;
            
            }, completion: {(finished: Bool) in //when the shrinking has finished
                
                //animate the icons moving up
                UIView.animateWithDuration(0.3, delay: 0.1, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    
                    for index in 0..<highlightedLowerViews.count {
                        
                        highlightedLowerViews[index].frame.origin.y -= self.standardDisplacement
                        
                    }
                    
                    }, completion: {(finished: Bool) in
                
                        if reopen {
                            
                            if highlightedLowerViews.count > 2 { //if there are two rows being moved
                                
                                self.middleHeightConstraint.constant -= self.standardDisplacement
                                self.bottomHeightConstraint.constant -= self.standardDisplacement
                                
                            } else if highlightedLowerViews.count == 2 {
                                
                                self.bottomHeightConstraint.constant -= self.standardDisplacement
                                
                            } else if highlightedLowerViews.count == 0 {
                                //should be empty
                            }
                            
                            //initialize tempView
                            self.tempView.frame.origin.y = tappedView.frame.height + tappedView.frame.origin.y + 10
                            self.tempView.frame.size.width = self.bodyView.frame.width
                            //height and x still remain zero
                            self.tempView.backgroundColor = UIColor(red: 178/255, green: 223/255, blue: 146/255, alpha: 1)
                            
                            self.openTempView(tappedLowerViews, tappedView: tappedView, tempViewHeight: tempViewHeight, reopened: true)
                            
                        } else { //if an object is being deselected
                            
                            if tappedLowerViews.count > 2 { //if there are two rows being moved
                                
                                self.middleHeightConstraint.constant -= self.standardDisplacement
                                self.bottomHeightConstraint.constant -= self.standardDisplacement
                                
                            } else if tappedLowerViews.count == 2 {
                                
                                self.bottomHeightConstraint.constant -= self.standardDisplacement
                                
                            }
                            
                            self.lightningImageView.userInteractionEnabled = true
                            self.waterImageView.userInteractionEnabled = true
                            self.treeImageView.userInteractionEnabled = true
                            self.smokeImageView.userInteractionEnabled = true
                            self.trashImageView.userInteractionEnabled = true
                            self.heartImageView.userInteractionEnabled = true
                            
                        }
                        
                
                })
                
        })
        
    }
    
    func setLabels(selectedView: UIView) {
        
        var titleFontSize: CGFloat = 0
        var contentFontSize: CGFloat = 0
        var bufferSize: CGFloat = 0
        
        //determine font size
        if UIScreen.mainScreen().bounds.height == 480 { //iPhone 4s
            titleFontSize = 11
            contentFontSize = 11
            bufferSize = 10
        } else if UIScreen.mainScreen().bounds.height == 568 { //iPhone 5, 5s, 5c
            titleFontSize = 13
            contentFontSize = 13
            bufferSize = 20
        } else if UIScreen.mainScreen().bounds.height == 667 { //iPhone 6, 6s
            titleFontSize = 16
            contentFontSize = 16
            bufferSize = 20
        } else if UIScreen.mainScreen().bounds.height == 736 { //iPhone 6 Plus, 6s Plus
            titleFontSize = 20
            contentFontSize = 20
            bufferSize = 20
        }
        
        let tempViewYValue = tempView.frame.origin.y
        
        titleLabel = UILabel(frame: CGRect(x: 20, y: tempViewYValue + bufferSize, width: tempView.frame.width - 40, height: titleFontSize + 5))
        titleLabel.font = UIFont(name: "AvenirNext-Medium", size: titleFontSize)
        
        
        let centerOfTempView = ((tempViewYValue + bufferSize + titleLabel.frame.height) +
            (tempViewYValue + tempView.frame.height)) / 2
        
        contentLabel = UILabel(frame: CGRect(x: 20, y: centerOfTempView - (contentFontSize/2), width: tempView.frame.width - 40, height: contentFontSize + 5))
        contentLabel.font = UIFont(name: "AvenirNext-UltraLight", size: contentFontSize)
        
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .DecimalStyle
        
        //determine label text
        if selectedView.tag == 1 {
            titleLabel.text = "Energy Saved (kWh):"
            contentLabel.text = numberFormatter.stringFromNumber(round(100*(currentAppStatus.loggedInUser?.electricitySaved)!)/100)
        } else if selectedView.tag == 2 {
            titleLabel.text = "Water Saved (liters):"
            contentLabel.text = numberFormatter.stringFromNumber(round(100*(currentAppStatus.loggedInUser?.waterSaved)!)/100)
        } else if selectedView.tag == 3 {
            titleLabel.text = "Trees Saved:"
            contentLabel.text = numberFormatter.stringFromNumber(round(100*(currentAppStatus.loggedInUser?.treesSaved)!)/100)
        } else if selectedView.tag == 4 {
            titleLabel.text = "CO2 Emissions Prevented (kilograms):"
            contentLabel.text = numberFormatter.stringFromNumber(round(100*(currentAppStatus.loggedInUser?.carbonDioxideEmissionsPrevented)!)/100)
        } else if selectedView.tag == 5 {
            titleLabel.text = "Trash Recycled (kilograms):"
            contentLabel.text = numberFormatter.stringFromNumber(round(100*(currentAppStatus.loggedInUser?.trashRecycled)!)/100)
        } else if selectedView.tag == 6 {
            titleLabel.text = "Hearts Warmed:"
            if let value = currentAppStatus.loggedInUser?.heartsWarmed {
                contentLabel.text = numberFormatter.stringFromNumber(value)
            }
            
        }
        
        bodyView.addSubview(titleLabel)
        bodyView.addSubview(contentLabel)
        
    }
    
    func layoutBody() {
        
        bodyView.layoutSubviews()
        
    }
    
    
}