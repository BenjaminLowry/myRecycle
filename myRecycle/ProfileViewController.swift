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
/*// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}*/


extension UIImage {
    
    func crop() -> UIImage {
        
        let imageRef:CGImage = self.cgImage!.cropping(to: CGRect(x: 0, y: self.size.height/2 - self.size.width/2, width: self.size.width, height: self.size.width))!
        let cropped:UIImage = UIImage(cgImage:imageRef)
        
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
    var colors:[UIColor] = [UIColor.red, UIColor.blue]
    var titles:[String] = ["Awards", "Activity"]
    var frame: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    @IBOutlet weak var pageControl: UIPageControl!
    
    //awards
    var electricianAward = Award(title: "Electrician", pointWorth: 15000, image: UIImage(named: "Lightning")!)
    var caretakerAward = Award(title: "Caretaker", pointWorth: 8000, image: UIImage(named: "Heart")!)
    
    var tapGestureRecognizer = UILongPressGestureRecognizer()
    
    @IBOutlet weak var usernameLabelVerticalDisplacementConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageButton.setImage(currentAppStatus.loggedInUser?.profilePicture, for: UIControlState())
        
        if UIScreen.main.bounds.height == 480 { //iPhone 4s
            usernameLabelVerticalDisplacementConstraint.constant = 6
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        configureHeader()
        configureScrollView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        homeBarButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir Next", size: 15)!], for: UIControlState())
        signOutBarButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir Next", size: 15)!], for: UIControlState())
        
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
    
    @IBAction func returnHome (_ sender: AnyObject){
    
        self.dismiss(animated: true, completion: nil)
    
    }
    
    @IBAction func signOut(_ sender: AnyObject) {
    
        currentAppStatus.loggedIn = false
        currentAppStatus.loggedInUser = nil
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func profileChangeButtonTapped(_ sender: UIButton){
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        
        self.present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
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
            view.layer.borderColor = UIColor.black.cgColor
            view.layer.borderWidth = 0.5
            //view.backgroundColor = colors[index]
            
            let titleLabelWidthRatio: CGFloat = 70/303 //how large the title should be compared to its superview
            let titleLabel = UILabel(frame: CGRect(x: 25, y: 20, width: (view.frame.width - 25)*titleLabelWidthRatio, height: 28))
            titleLabel.text = titles[index]
            titleLabel.font = UIFont(name: "AvenirNext-Medium", size: 100)
            titleLabel.adjustsFontSizeToFitWidth = true
            titleLabel.baselineAdjustment = .alignCenters
            view.addSubview(titleLabel)
            
            if index == 1 {
                
                let label = UILabel(frame: CGRect(x: view.frame.width/2 - 200/2, y: view.frame.height/2 - 30/2, width: 200, height: 30))
                label.text = "Coming Soon!"
                label.textAlignment = .center
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
                
                if let user = currentAppStatus.loggedInUser {
                    if user.heartsWarmed > 500 {
                        
                        heartImage = UIImage(named: "Heart")!
                        heartLabel.text = "\"Caretaker\""
                        
                    } else {
                        
                        heartImage = UIImage(named: "Heart Grey")!
                        heartLabel.text = "???"
                        
                    }
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
                
                if let user = currentAppStatus.loggedInUser {
                    if user.electricitySaved > 10000.0 {
                        
                        lightningImage = UIImage(named: "Lightning")!
                        lightningLabel.text = "\"Electrician\""
                        
                    } else {
                        
                        lightningImage = UIImage(named: "Lightning Grey")!
                        lightningLabel.text = "???"
                        
                    }
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
                
                if let user = currentAppStatus.loggedInUser {
                    if user.waterSaved > 10000.0 {
                        
                        waterImage = UIImage(named: "Water Drop")!
                        waterLabel.text = "\"Moses\""
                        
                    } else {
                        
                        waterImage = UIImage(named: "Water Drop Grey")!
                        waterLabel.text = "???"
                        
                    }
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
        
        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width * CGFloat(self.titles.count), height: self.scrollView.frame.size.height)
        pageControl.addTarget(self, action: #selector(ProfileViewController.changePage(_:)), for: UIControlEvents.valueChanged)
        
    }
    
    func configureHeader() {
        
        headerView.layoutSubviews()
        
        profileImageButton.layer.borderWidth = 0.5
        profileImageButton.layer.masksToBounds = false
        profileImageButton.layer.borderColor = UIColor.black.cgColor
        profileImageButton.layer.cornerRadius = profileImageButton.frame.size.width/2
        profileImageButton.clipsToBounds = true
        
        var pointSize1: CGFloat = 0 //for the value labels
        var pointSize2: CGFloat = 0 //for the progress label
        
        var usernamePointSize: CGFloat = 0
        
        switch UIScreen.main.bounds.height {
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
    
    func setLabelFonts(_ labels: [UILabel], font: UIFont){
        
        for index in 0..<labels.count {
            
            labels[index].font = font
            labels[index].adjustsFontSizeToFitWidth = true
            labels[index].baselineAdjustment = .alignCenters
            
        }
        
    }
    
    func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        
        pageControl.numberOfPages = titles.count
        pageControl.currentPage = 0
        pageControl.tintColor = UIColor.red
        
    }
    
    func changePage(_ sender: UIPageControl) {
        
        let pager = sender
        let page: CGFloat = CGFloat(pager.currentPage)
        var frame = scrollView.frame
        frame.origin.x = frame.width * page
        frame.origin.y = 0
        scrollView.scrollRectToVisible(frame, animated: true)
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        do {
            
            let image = info[UIImagePickerControllerOriginalImage] as? UIImage
            
            if let croppedImage = image?.crop() {
                
                profileImageButton.setImage(croppedImage, for: .normal)
                currentAppStatus.loggedInUser?.profilePicture = croppedImage
                
            } else {
                throw AppError.imageNotFoundError
            }
            
            self.dismiss(animated: true, completion: nil)
            
        } catch AppError.imageNotFoundError {
            
            //present error
            let alertController = UIAlertController(title: "Error #E03", message: "Sorry about that, please try again.", preferredStyle: .alert)
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
    
    
}
