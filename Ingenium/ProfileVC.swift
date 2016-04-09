//
//  ProfileVC.swift
//  Ingenium
//
//  Created by Varun Shenoy on 12/23/15.
//  Copyright © 2015 Varun Shenoy. All rights reserved.
//

import UIKit
import Parse

class ProfileVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    
    var actions = [Action]()
    
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var userLable: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var slideView: DesignableView!
    @IBOutlet weak var emailInput: DesignableTextField!
    
    @IBOutlet weak var nameInput: DesignableTextField!
    
    @IBOutlet weak var phoneInput: DesignableTextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
        
        let user = PFUser.currentUser()
        userLable.text = user?.username
        nameLabel.text = user!["FullName"] as? String
        email.text = user?.email
        phoneLabel.text = user!["phone"] as? String
        emailInput.text = user?.email
        phoneInput.text = user!["phone"] as? String
        nameInput.text = user!["FullName"] as? String
        let profPic = user!["ProfilePicture"] as! PFFile
        profPic.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
            if error == nil {
                let image = UIImage(data: data!)
                self.profileImage.image = image
            }
        }
        
        getActions()
        // Do any additional setup after loading the view.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func getActions() {
        let act1 = Action()
        act1.type = "phone"
        act1.subject = "chemistry"
        act1.labelText = "+1408478582"
        
        let act2 = Action()
        act2.type = "pencil"
        act2.subject = "physics"
        act2.labelText = "Finish lab."
        
        actions.append(act1)
        actions.append(act2)
        actions.append(act1)
        actions.append(act2)
        actions.append(act1)
        actions.append(act2)
        actions.append(act1)
        actions.append(act2)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeProfilePictureAction(sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let scaledImage = resizeImage(pickedImage, newWidth: 125)
            let imageData = UIImagePNGRepresentation(scaledImage)
            let imageFile:PFFile = PFFile(data: imageData!)!
            let currentUser = PFUser.currentUser()
            currentUser!["ProfilePicture"] = imageFile
            currentUser?.saveInBackground()
            profileImage.image = scaledImage
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    @IBAction func logOut(sender: AnyObject) {
        PFUser.logOutInBackground()
    }

    @IBAction func editUserInfoActionSlideUp(sender: AnyObject) {
        slideView.hidden = false
        slideView.animation = "slideUp"
        self.slideView.animate()
        UIView.animateWithDuration(0.5) { () -> Void in
            self.slideView.alpha = 1
        }
    }
    
    @IBAction func closeSlideView(sender: AnyObject) {
        slideView.animation = "fall"
        self.slideView.animate()
        UIView.animateWithDuration(0.5) { () -> Void in
            self.slideView.alpha = 0
        }
    }
    @IBAction func changeUserInfo(sender: AnyObject) {
        let user = PFUser.currentUser()
        user!["email"] = emailInput.text
        email.text = emailInput.text
        user!["phone"] = phoneInput.text
        phoneLabel.text = phoneInput.text
        user!["FullName"] = nameInput.text
        nameLabel.text = nameInput.text
        user?.saveInBackgroundWithBlock({ (bool:Bool, error: NSError?) -> Void in
            if error == nil {
                self.slideView.animation = "fall"
                self.slideView.animate()
                self.view.endEditing(true)
            }
        })
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
