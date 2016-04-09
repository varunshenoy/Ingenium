//
//  MapViewVC.swift
//  Ingenium
//
//  Created by Varun Shenoy on 12/16/15.
//  Copyright © 2015 Varun Shenoy. All rights reserved.
//
// apple lat = 37.331002° long = -122.029663°

import UIKit
import MapKit
import Parse

class MapViewVC: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    var manager: CLLocationManager!

    var tutors = [Tutor]()
    var tagged:Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        map.delegate = self
        map.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true);
        let user = PFUser.currentUser()
        let current = user!["currentlyActive"] as! Bool
        if current == true {
            addButton.hidden = true
            deleteButton.hidden = false
        } else {
            addButton.hidden = false
            deleteButton.hidden = true
        }
        getTutorsFromParse()
        // Do any additional setup after loading the view.
    }

    func addTutorAnnotations() {
        var count = 0
        for i in tutors {
            let annot = TutorAnnotation()
            //change "PFGeoPoint" -> "CL2DCOordinates" DONE
            let latitude:CLLocationDegrees = i.coords.latitude
            let longitude:CLLocationDegrees = i.coords.longitude
            let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
            annot.coordinate = location
            annot.title = "\(i.name)"
            annot.subtitle = "\(i.price)"
            annot.image = "\(i.subject.lowercaseString).png"
            annot.tutor = i
            annot.index = count
            map.addAnnotation(annot)
            count++
        }
    }
    
    func getTutorsFromParse() {
        let query:PFQuery = PFUser.query()!
        query.findObjectsInBackgroundWithBlock { (objs:[PFObject]?, error: NSError?) -> Void in
            for obj in objs! {
                let cur = obj["currentlyActive"] as! Bool
                if cur == true {
                    let tutor = Tutor()
                    tutor.username = obj["username"] as! String
                    tutor.name = obj["FullName"] as! String
                    tutor.descrip = obj["Description"] as! String
                    tutor.subject = obj["Subject"] as! String
                    tutor.price = obj["Pricing"] as! String
                    tutor.coords = obj["HotspotLoc"] as! PFGeoPoint
                    tutor.email = obj["email"] as! String
                    tutor.phone = obj["phone"] as! String
                    let query = PFQuery(className: "Ratings")
                    query.whereKey("username", equalTo: tutor.username)
                    query.findObjectsInBackgroundWithBlock({ (objs: [PFObject]?, error: NSError?) -> Void in
                        if error == nil {
                            for obj in objs! {
                                tutor.rating = obj["rating"] as! Double
                                tutor.numberOfRatings = obj["numOfRatings"] as! Double
                            }
                        }
                    })
                    self.tutors.append(tutor)
                    
                }
            }
            self.addTutorAnnotations()
            
        }
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Detail" {
            let nextScene =  segue.destinationViewController as! TutorDetailVC
            nextScene.tutor = tutors[tagged]
        }
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is TutorAnnotation) {
            return nil
        }
        
        let reuseId = "test"
        
        var annotatedView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if annotatedView == nil {
            annotatedView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            annotatedView!.canShowCallout = true
        }
        else {
            annotatedView!.annotation = annotation
        }
        
        //Set annotation-specific properties **AFTER**
        //the view is dequeued or created...
        
        let pin = annotation as! TutorAnnotation
        annotatedView!.image = UIImage(named:pin.image)
        
        let btn = UIButton(type: .DetailDisclosure)
        btn.addTarget(self, action: "btnDisclosureAction:", forControlEvents: UIControlEvents.TouchUpInside)
        btn.tag = (annotation as! TutorAnnotation).index
        annotatedView!.rightCalloutAccessoryView = btn
        
        return annotatedView
    }
    
    func btnDisclosureAction(sender: UIButton) {
        tagged = sender.tag
        performSegueWithIdentifier("Detail", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    

    @IBAction func reloadMap(sender: AnyObject) {
        reloadMap()
    }
    
    func reloadMap() {
        tutors = []
        map.removeAnnotations(map.annotations)
        getTutorsFromParse()
    }
    
    @IBAction func deleteCurrentHotspot(sender: AnyObject) {
        // create the alert
        let alert = UIAlertController(title: "Remove Current Hotspot", message: "You cannot have more than 1 hotspot at a time.", preferredStyle: UIAlertControllerStyle.Alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Remove", style: UIAlertActionStyle.Destructive, handler: { action in
            let user = PFUser.currentUser()
            user!["currentlyActive"] = false
            user?.saveInBackground()
            self.addButton.hidden = false
            self.deleteButton.hidden = true
            self.reloadMap()
        }))
        
        // show the alert
        self.presentViewController(alert, animated: true, completion: nil)
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
