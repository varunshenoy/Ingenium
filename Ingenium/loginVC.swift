//
//  loginVC.swift
//  Ingenium
//
//  Created by Varun Shenoy on 12/17/15.
//  Copyright © 2015 Varun Shenoy. All rights reserved.
//

import UIKit
import Parse
import MapKit

class loginVC: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var username: DesignableTextField!
    
    @IBOutlet weak var email: DesignableTextField!
    
    @IBOutlet weak var password: DesignableTextField!
    
    @IBOutlet weak var passwordCheck: DesignableTextField!
    
    @IBOutlet weak var phone: DesignableTextField!
    
    @IBOutlet weak var errorText: DesignableLabel!
    
    @IBOutlet weak var errorLabel: DesignableView!
    
    @IBOutlet weak var fullName: DesignableTextField!
    
    var facebookInfo: FBObject?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if facebookInfo != nil {
            
            fullName.text = facebookInfo!.fullName;
            email.text = facebookInfo!.email;
            
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signUpButtonAction(sender: AnyObject) {
        view.endEditing(true)
        SignUp()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func SignUp() {
        let user = PFUser()
        user.username = username.text
        user.password = password.text
        user.email = email.text
        
        if password.text != "" && username.text != "" && passwordCheck.text != "" && email.text != "" && phone.text != ""  && fullName.text != ""{
            if password.text == passwordCheck.text {
                user.signUpInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                    if error == nil {
                        self.errorLabel.hidden = false
                        self.errorLabel.animate()
                        self.errorText.text = "Signed Up."
                        user["phone"] = self.phone.text
                        user["FullName"] = self.fullName.text
                        user["currentlyActive"] = false
                        user["Rating"] = 0
                        user["numOfRatings"] = 0
                        user["alreadyRated"] = ["\(self.username.text!)"]
                        print(self.username.text!)
                        let query = PFObject(className: "Ratings")
                        query.setObject(user.username!, forKey: "username")
                        query.setObject(0, forKey: "rating")
                        query.setObject(0, forKey: "numOfRatings")
                        query.saveInBackgroundWithBlock({ (bool: Bool, error: NSError?) -> Void in
                            if bool == true {
                                 print("Object Uploaded")
                            } else {
                                
                            }
                        })
                        if self.facebookInfo?.profPicURL != nil {
                            let string = self.facebookInfo?.profPicURL
                            let profPicURL = NSURL(string: string!)
                            
                            if profPicURL != nil {
                                
                                //Create an NSURLRequest object
                                let request = NSURLRequest(URL: profPicURL!)
                                
                                //Create an NSURLSession
                                let session = NSURLSession.sharedSession()
                                
                                //Create a datatask and pass in the request
                                let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                                    
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        //get a ref to img view in cell
                                        let image = UIImage(data: data!)
                                        let scaledImage = self.resizeImage(image!, newWidth: 125)
                                        let imageData = UIImagePNGRepresentation(scaledImage)
                                        let imageFile:PFFile = PFFile(data: imageData!)!
                                        let currentUser = PFUser.currentUser()
                                        currentUser!["ProfilePicture"] = imageFile
                                        currentUser?.saveInBackground()
                                        
                                    })
                                    
                                })
                                
                                dataTask.resume()
                            }
                            
                        } else {
                            let image = UIImage(named: "user_male.png")!
                            let scaledImage = self.resizeImage(image, newWidth: 125)
                            let imageData = UIImagePNGRepresentation(scaledImage)
                            let imageFile:PFFile = PFFile(data: imageData!)!
                            let currentUser = PFUser.currentUser()
                            currentUser!["ProfilePicture"] = imageFile
                            currentUser?.saveInBackground()
                        }
                        user.saveInBackground()
                        let user = PFUser()
                        user.username = self.username.text
                        user.password = self.password.text
                        
                        if self.username.text != "" && self.password.text != "" {
                            PFUser.logInWithUsernameInBackground(self.username.text!, password: self.password.text!, block: {
                                
                                (User: PFUser?, Error: NSError?) -> Void in
                                
                                if Error == nil {
                                    
                                    dispatch_async(dispatch_get_main_queue()) {
                                        let Storyboard = UIStoryboard(name: "Main", bundle: nil)
                                        let MainVC : UITabBarController = Storyboard.instantiateViewControllerWithIdentifier("MainVC") as! UITabBarController
                                        self.presentViewController(MainVC, animated: true, completion: nil)
                                        
                                        
                                    }
                                    
                                } else {
                                    
                                    self.errorLabel.hidden = false
                                    self.errorLabel.animate()
                                    self.errorText.text = "Username/Password do not match."
                                    
                                    
                                }
                                
                            })
                        } else {
                            
                            self.errorLabel.hidden = false
                            self.errorLabel.animate()
                            self.errorText.text = "A field is empty."
                            /*self.errorLabel.animation = "zoomOut"
                            self.errorLabel.animate()*/
                            
                        }
                    } else {
                        let errorCode = error!.code
                        switch errorCode {
                        case 100:
                            self.showErrorLabel("Connection Failed")
                            break
                        case 202:
                            self.showErrorLabel("Username Taken")
                            break
                        case 203:
                            self.showErrorLabel("Email Taken")
                        case 124:
                            self.showErrorLabel("Timeout")
                        default:
                            break
                        }
                    }
                }
            } else {
                self.errorLabel.hidden = false
                self.errorLabel.animate()
                self.errorText.text = "Passwords do not match."
            }

        } else {
            self.errorLabel.hidden = false
            self.errorLabel.animate()
            self.errorText.text = "One or more fields are empty."
        }
    }
    
    func showErrorLabel(string: String) {
        self.errorLabel.hidden = false
        self.errorLabel.animate()
        self.errorText.text = string
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SignedUp" {
            if let setUpSignUp = segue.destinationViewController as? loginVC {
                if let fbobj = sender as? FBObject{
                    setUpSignUp.facebookInfo = fbobj
                }
            }
        }
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
