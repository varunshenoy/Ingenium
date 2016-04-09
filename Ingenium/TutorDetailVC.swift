//
//  TutorDetailVC.swift
//  Ingenium
//
//  Created by Varun Shenoy on 12/20/15.
//  Copyright © 2015 Varun Shenoy. All rights reserved.
//

import UIKit
import MapKit
import Parse

class TutorDetailVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var tutorProfile: UIImageView!
    
    @IBOutlet weak var tutorDescription: UILabel!
    
    @IBOutlet weak var tutorPrice: UILabel!
    
    @IBOutlet weak var tutorRating: CosmosView!
    
    @IBOutlet weak var tutorMap: MKMapView!
    
    @IBOutlet weak var tutorName: UILabel!
    
    @IBOutlet weak var call: UIButton!
    
    @IBOutlet weak var mail: DesignableButton!
    
    @IBOutlet weak var newTutorRating: CosmosView!
    
    @IBOutlet weak var closeMapView: UIButton!
    
    @IBOutlet weak var showMapView: UIButton!
    
    @IBOutlet weak var subjectIcon: UIImageView!
    
    @IBOutlet weak var ratingView: DesignableView!
    
    @IBOutlet weak var ratingButton: DesignableButton!
    
    @IBOutlet weak var mapView: DesignableView!
    var tutor: Tutor!
    
    let regionRadius: CLLocationDistance = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tutorMap.delegate = self
        
        
        tutorName.text = tutor.name
        tutorDescription.text = tutor.descrip
        tutorRating.rating = tutor.rating
        tutorPrice.text = tutor.price
        let user = PFUser.currentUser()
        let alreadyRated = user!["alreadyRated"] as! [String]
        if alreadyRated.indexOf("\(tutor.username)") != nil {
            ratingButton.hidden = true
        }
        subjectIcon.image = UIImage(named: "\(tutor.subject.lowercaseString)_full.png")
        // Do any additional setup after loading the view.
        let query:PFQuery = PFUser.query()!
        query.whereKey("username", equalTo: tutor.username)
        query.findObjectsInBackgroundWithBlock { (objs:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
                for i in objs! {
                    let profPic = i["ProfilePicture"] as! PFFile
                    profPic.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
                        if error == nil {
                            let image = UIImage(data: data!)
                            self.tutorProfile.image = image
                        } 
                    }
                }
            }
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func ratingButtonAction(sender: AnyObject) {
        ratingView.hidden = false
        ratingView.animation = "slideUp"
        ratingView.animate()
        UIView.animateWithDuration(0.5) { () -> Void in
            self.ratingView.alpha = 1;
        }

        
    }
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        tutorMap.setRegion(coordinateRegion, animated: true)
    }
    
    @IBAction func callTutor(sender: AnyObject) {
        if let url = NSURL(string: "tel://\(tutor.phone)") {
            UIApplication.sharedApplication().openURL(url)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showMap(sender: AnyObject) {
        mapView.hidden = false
        mapView.animation = "slideUp"
        mapView.animate()
        UIView.animateWithDuration(0.5) { () -> Void in
            self.mapView.alpha = 1;
        }
        let annot = TutorAnnotation()
        let latitude:CLLocationDegrees = tutor.coords.latitude
        let longitude:CLLocationDegrees = tutor.coords.longitude
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let initLoc = CLLocation(latitude: latitude, longitude: longitude)
        centerMapOnLocation(initLoc)
        annot.coordinate = location
        annot.title = "\(tutor.name)"
        annot.subtitle = "\(tutor.price)"

        tutorMap.addAnnotation(annot)
    }

    @IBAction func addRating(sender: AnyObject) {
        let newRating = newTutorRating.rating
        let numRating = tutor.numberOfRatings
        let curRating = tutor.rating
        let num = curRating * numRating + newRating
        let denom = numRating + 1
        let wholeNewRating = num/denom
        let query = PFQuery(className: "Ratings")
        query.whereKey("username", equalTo: tutor.username)
        query.findObjectsInBackgroundWithBlock { (objs: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                print("not nil")
                print(objs)
                for obj in objs! {
                    print("adding")
                    obj["rating"] = wholeNewRating
                    obj["numOfRatings"] = numRating + 1
                    let curUser = PFUser.currentUser()
                    var alreadyRated = curUser!["alreadyRated"] as! [String]
                    alreadyRated.append("\(self.tutor.username)")
                    curUser!["alreadyRated"] = alreadyRated
                    self.ratingButton.hidden = true
                    curUser?.saveInBackground()
                    print(alreadyRated)
                    obj.saveInBackgroundWithBlock({ (bool: Bool, error: NSError?) -> Void in
                        if error == nil {
                            self.ratingView.animation = "fall"
                            self.ratingView.animate()
                        } else {
                            print(error.debugDescription)
                        }
                    })
                    self.tutorRating.rating = wholeNewRating
                    print("------------")
                    print(obj)
                }
            } else {
                print(error.debugDescription)
            }
        }
        
    }
    
    @IBAction func closeMap(sender: AnyObject) {
        mapView.animation = "fall"
        mapView.animate()
        UIView.animateWithDuration(0.5) { () -> Void in
            self.mapView.alpha = 0;
        }
    }
    
    @IBAction func sendEmail(sender: AnyObject) {
        let email = tutor.email
        let url = NSURL(string: "mailto:\(email)?subject=\(tutor.subject)%20Tutor%20Session%20Request%20through%20Ingenium&body=I%20would%20like%20to%20request%20a%20tutoring%20session%20for%20me%20in%20\(tutor.subject).%0D%0A%0D%0ASent%20with%20Ingenium.")
        UIApplication.sharedApplication().openURL(url!)
    }
    
    @IBAction func closeRatings(sender: AnyObject) {
        ratingView.animation = "fall"
        ratingView.animate()
        UIView.animateWithDuration(0.5) { () -> Void in
            self.ratingView.alpha = 0;
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
