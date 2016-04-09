//
//  ViewController.swift
//  Ingenium
//
//  Created by Varun Shenoy on 12/16/15.
//  Copyright © 2015 Varun Shenoy. All rights reserved.
//

import UIKit
import Parse
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController{
    
    

    @IBOutlet weak var usernameText: DesignableTextField!
    
    @IBOutlet weak var passwordText: DesignableTextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var errorLabel: DesignableView!
    
    @IBOutlet weak var errorText: DesignableLabel!

    @IBAction func signInButtonAction(sender: AnyObject) {
        view.endEditing(true)
        LogIn()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func LogIn() {
        
        let user = PFUser()
        user.username = usernameText.text
        user.password = passwordText.text
        
        if usernameText.text != "" && passwordText.text != "" {
            PFUser.logInWithUsernameInBackground(usernameText.text!, password: passwordText.text!, block: {
                
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
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    @IBAction func signUpViaFacebook(sender: AnyObject) {
        // create the alert
        let alert = UIAlertController(title: "Sign Up via Facebook", message: "Information will automatically be gathered from your account, including your name, email, and profile picture. We will still require your phone number, username, and password.", preferredStyle: UIAlertControllerStyle.Alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Proceed", style: UIAlertActionStyle.Destructive, handler: { action in
            let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
            fbLoginManager.logInWithReadPermissions(["email"], fromViewController: self) { (result, error) -> Void in
                if (error == nil){
                    let fbloginresult : FBSDKLoginManagerLoginResult = result
                    if(fbloginresult.grantedPermissions.contains("email"))
                    {
                        self.getFBUserData()
                    }
                }
            }
        }))
        
        // show the alert
        self.presentViewController(alert, animated: true, completion: nil)

    }
    
    
    func getFBUserData(){
        if((FBSDKAccessToken.currentAccessToken()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name, picture.type(large), email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if (error == nil){
                    let pic = result["picture"]!!["data"]!!["url"] as! String
                    let em = result["email"] as! String
                    let fn = result["name"] as! String
                    let fbobj = FBObject()
                    fbobj.fullName = fn
                    fbobj.email = em
                    fbobj.profPicURL = pic
                    self.performSegueWithIdentifier("SignUpWithFacebook", sender: fbobj)
                }
            })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SignUpWithFacebook" {
            if let setUpSignUp = segue.destinationViewController as? loginVC {
                if let fbobj = sender as? FBObject{
                    setUpSignUp.facebookInfo = fbobj
                }
            }
        }
    }



}

