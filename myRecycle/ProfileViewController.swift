//
//  ProfileViewController.swift
//  myRecycle
//
//  Created by Ben LOWRY on 3/20/16.
//  Copyright © 2016 Ben LOWRY. All rights reserved.
//

// CLEARED FOR ERROR HANDLING

import Foundation
import UIKit

extension UIImage {
    
    func crop() -> UIImage {
        
        let imageRef:CGImageRef = CGImageCreateWithImageInRect(self.CGImage, CGRectMake(0, self.size.height/2 - self.size.width/2, self.size.width, self.size.width))!
        let cropped:UIImage = UIImage(CGImage:imageRef)
        
        return cropped
        
    }
    
}

class ProfileViewController: UIViewController, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var signOutBarButton: UIBarButtonItem!
    @IBOutlet weak var homeBarButton: UIBarButtonItem!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    
    @IBOutlet weak var rankTitleLabel: UILabel!
    @IBOutlet weak var levelValueLabel: UILabel!
    @IBOutlet weak var pointsValueLabel: UILabel!
    
    @IBOutlet weak var levelProgressLabel: UILabel!
    
    @IBOutlet weak var scrollSuperView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    var colors:[UIColor] = [UIColor.redColor(), UIColor.blueColor()]
    var titles:[String] = ["Awards", "Activity"]
    var frame: CGRect = CGRectMake(0, 0, 0, 0)
    @IBOutlet weak var pageControl: UIPageControl!
    
    //awards
    var electricianAward = Award(title: "Electrician", pointWorth: 15000, image: UIImage(named: "Lightning")!)
    var caretakerAward = Award(title: "Caretaker", pointWorth: 8000, image: UIImage(named: "Heart")!)
    
    var tapGestureRecognizer = UILongPressGestureRecognizer()
    
    @IBOutlet weak var usernameLabelVerticalDisplacementConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateAwards()
        
        profileImageButton.setImage(currentAppStatus.loggedInUser?.profilePicture, forState: .Normal)
        
        if UIScreen.mainScreen().bounds.height == 480 { //iPhone 4s
            usernameLabelVerticalDisplacementConstraint.constant = 6
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        configureHeader()
        configureScrollView()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        homeBarButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir Next", size: 15)!], forState: UIControlState.Normal)
        signOutBarButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir Next", size: 15)!], forState: UIControlState.Normal)
        
        if currentAppStatus.loggedIn {
            
            if let usernameText = currentAppStatus.loggedInUser?.username {
                usernameLabel.text = usernameText
            }
            if let points = currentAppStatus.loggedInUser?.points {
                pointsValueLabel.text = String(points)
            }
            //level needs to be updated
            currentAppStatus.loggedInUser?.updateLevel()
            if let level = currentAppStatus.loggedInUser?.level {
                levelValueLabel.text = String(level)
            }
            //rank needs to be updated
            currentAppStatus.loggedInUser?.updateRank()
            if let rankText = currentAppStatus.loggedInUser?.rank {
                rankTitleLabel.text = rankText
            }
            if let levelProgress = currentAppStatus.loggedInUser?.determineProgress() {
                let currentProgress = levelProgress.0
                let threshold = levelProgress.1
                levelProgressLabel.text = String(currentProgress) + " / " + String(threshold)
            }
            
        }
        
    }
    
    @IBAction func returnHome (sender: AnyObject){
    
        self.dismissViewControllerAnimated(true, completion: nil)
    
    }
    
    @IBAction func signOut(sender: AnyObject) {
    
        currentAppStatus.loggedIn = false
        currentAppStatus.loggedInUser = nil
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func profileChangeButtonTapped(sender: UIButton){
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .PhotoLibrary
        
        self.presentViewController(imagePickerController, animated: true, completion: nil)
        
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    
    func configureScrollView() {
        
        scrollSuperView.layoutSubviews()
        
        configurePageControl()
        
        scrollView.delegate = self
        
        for index in 0..<titles.count {
            
            frame.origin.x = self.scrollView.frame.size.width * CGFloat(index)
            frame.size = self.scrollView.frame.size
            
            let view = UIView(frame: frame)
            view.backgroundColor = UIColor(red: 178/255, green: 223/255, blue: 146/255, alpha: 1)
            view.layer.borderColor = UIColor.blackColor().CGColor
            view.layer.borderWidth = 0.5
            //view.backgroundColor = colors[index]
            
            let titleLabelWidthRatio: CGFloat = 70/303 //how large the title should be compared to its superview
            let titleLabel = UILabel(frame: CGRect(x: 25, y: 20, width: (view.frame.width - 25)*titleLabelWidthRatio, height: 28))
            titleLabel.text = titles[index]
            titleLabel.font = UIFont(name: "AvenirNext-Medium", size: 100)
            titleLabel.adjustsFontSizeToFitWidth = true
            titleLabel.baselineAdjustment = .AlignCenters
            view.addSubview(titleLabel)
            
            if index == 1 {
                
                let label = UILabel(frame: CGRect(x: view.frame.width/2 - 200/2, y: view.frame.height/2 - 30/2, width: 200, height: 30))
                label.text = "Coming Soon!"
                label.textAlignment = .Center
                label.font = UIFont(name: "Avenir Next", size: 20)
                view.addSubview(label)
                
                /* FOR LINE GRAPH
                let image = UIImage(named: "Line Graph")
                let imageView = UIImageView(image: image)
                imageView.frame = CGRect(x: 25, y: 68, width: view.frame.width - 50, height: view.frame.height - 88)
                
                view.addSubview(imageView)
                */
                
            } else {
                
                //CARETAKER AWARD
                
                var heartImage = UIImage()
                let heartLabel = UILabel()
                
                if currentAppStatus.loggedInUser?.heartsWarmed > 500 {
                    
                    heartImage = UIImage(named: "Heart")!
                    heartLabel.text = "\"Caretaker\""
                    
                } else {
                    
                    heartImage = UIImage(named: "Heart Grey")!
                    heartLabel.text = "???"
                    
                }
                
                let heartImageView = UIImageView(image: heartImage)
                heartImageView.frame = CGRect(x: 25, y: 78, width: 30, height: 30)
                
                heartLabel.frame = CGRect(x: 65, y: 81, width: view.frame.width, height: 24)
                heartLabel.font = UIFont(name: "Avenir Next", size: 16)
                
                view.addSubview(heartImageView)
                view.addSubview(heartLabel)
                
                
                //ELECTRICIAN AWARD
                
                var lightningImage = UIImage()
                let lightningLabel = UILabel()
                
                if currentAppStatus.loggedInUser?.electricitySaved > 10000 {
                    
                    lightningImage = UIImage(named: "Lightning")!
                    lightningLabel.text = "\"Electrician\""
                    
                } else {
                    
                    lightningImage = UIImage(named: "Lightning Grey")!
                    lightningLabel.text = "???"
                    
                }
                
                let lightningImageView = UIImageView(image: lightningImage)
                lightningImageView.frame = CGRect(x: 25, y: 120, width: 30, height: 30)
                
                lightningLabel.frame = CGRect(x: 65, y: 123, width: view.frame.width, height: 24)
                lightningLabel.font = UIFont(name: "Avenir Next", size: 16)
                
                view.addSubview(lightningImageView)
                view.addSubview(lightningLabel)
                
                
                //MOSES AWARD
                
                var waterImage = UIImage()
                let waterLabel = UILabel()
                
                if currentAppStatus.loggedInUser?.waterSaved > 10000 {
                    
                    waterImage = UIImage(named: "Water Drop")!
                    waterLabel.text = "\"Moses\""
                    
                } else {
                    
                    waterImage = UIImage(named: "Water Drop Grey")!
                    waterLabel.text = "???"
                    
                }
                
                let waterImageView = UIImageView(image: waterImage)
                waterImageView.frame = CGRect(x: 25, y: 159, width: 30, height: 30)
                
                waterLabel.frame = CGRect(x: 65, y: 162, width: view.frame.width, height: 24)
                waterLabel.font = UIFont(name: "Avenir Next", size: 16)
                
                view.addSubview(waterImageView)
                view.addSubview(waterLabel)
                
                
                //TRASH SMASHER AWARD
                
                
                
                
            }
            
            self.scrollView.addSubview(view)
        }
        
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * CGFloat(self.titles.count), self.scrollView.frame.size.height)
        pageControl.addTarget(self, action: #selector(ProfileViewController.changePage(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
    }
    
    func configureHeader() {
        
        headerView.layoutSubviews()
        
        profileImageButton.layer.borderWidth = 0.5
        profileImageButton.layer.masksToBounds = false
        profileImageButton.layer.borderColor = UIColor.blackColor().CGColor
        profileImageButton.layer.cornerRadius = profileImageButton.frame.size.width/2
        profileImageButton.clipsToBounds = true
        
        var pointSize1: CGFloat = 0 //for the value labels
        var pointSize2: CGFloat = 0 //for the progress label
        
        var usernamePointSize: CGFloat = 0
        
        switch UIScreen.mainScreen().bounds.height {
        case 480: //iPhone 4s
            pointSize1 = 11
            pointSize2 = 10
            usernamePointSize = 13
        case 568: //iPhone 5, 5s, 5c
            pointSize1 = 14
            pointSize2 = 12
            usernamePointSize = 25
        case 667: //iPhone 6, 6s
            pointSize1 = 17
            pointSize2 = 14
            usernamePointSize = 33
        case 736: //iPhone 6 Plus, 6s Plus
            pointSize1 = 19
            pointSize2 = 15
            usernamePointSize = 40
        default:
            pointSize1 = 11
            pointSize2 = 10
        }
        
        setLabelFonts([usernameLabel], font: UIFont(name: "Avenir Next", size: usernamePointSize)!)
        
        setLabelFonts([pointsLabel, levelLabel, rankLabel], font: UIFont(name: "AvenirNext-Bold", size: 30)!)
        
        
        setLabelFonts([rankTitleLabel, levelValueLabel, pointsValueLabel], font: UIFont(name: "Avenir Next", size: pointSize1)!)
        
        setLabelFonts([levelProgressLabel], font: UIFont(name: "Avenir Next", size: pointSize2)!)
        
    }
    
    func setLabelFonts(labels: [UILabel], font: UIFont){
        
        for index in 0..<labels.count {
            
            labels[index].font = font
            labels[index].adjustsFontSizeToFitWidth = true
            labels[index].baselineAdjustment = .AlignCenters
            
        }
        
    }
    
    func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        
        pageControl.numberOfPages = titles.count
        pageControl.currentPage = 0
        pageControl.tintColor = UIColor.redColor()
        
    }
    
    func changePage(sender: UIPageControl) {
        
        let pager = sender
        let page: CGFloat = CGFloat(pager.currentPage)
        var frame = scrollView.frame
        frame.origin.x = frame.width * page
        frame.origin.y = 0
        scrollView.scrollRectToVisible(frame, animated: true)
        
    }
    
    func updateAwards() {
        
        if currentAppStatus.loggedInUser?.electricitySaved >= 10000 {
            
        }
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        do {
            
            let image = info[UIImagePickerControllerOriginalImage] as? UIImage
            
            if let croppedImage = image?.crop() {
                
                profileImageButton.setImage(croppedImage, forState: .Normal)
                currentAppStatus.loggedInUser?.profilePicture = croppedImage
                
            } else {
                throw AppError.ImageNotFoundError
            }
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        } catch AppError.ImageNotFoundError {
            
            //present error
            let alertController = UIAlertController(title: "Error #E03", message: "Sorry about that, please try again.", preferredStyle: .Alert)
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
    
    
}
