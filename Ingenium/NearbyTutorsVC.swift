//
//  NearbyTutorsVC.swift
//  Ingenium
//
//  Created by Varun Shenoy on 12/17/15.
//  Copyright © 2015 Varun Shenoy. All rights reserved.
//

import UIKit
import MapKit
import Parse

class NearbyTutorsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    var tutors:[Tutor] = [Tutor]()
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var removeButton: UIButton!
    
    
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView?.addSubview(refreshControl)
        self.loading.startAnimating()
        self.loading.hidesWhenStopped = true
        let user = PFUser.currentUser()
        let current = user!["currentlyActive"] as! Bool
        if current == true {
            addButton.hidden = true
            removeButton.hidden = false
        } else {
            addButton.hidden = false
            removeButton.hidden = true
        }
        getTutorsFromParse()
        
        
        
        // Do any additional setup after loading the view.
    }
    @IBAction func removeCurrentHotspot(sender: AnyObject) {
        // create the alert
        let alert = UIAlertController(title: "Remove Current Hotspot", message: "You cannot have more than 1 hotspot at a time.", preferredStyle: UIAlertControllerStyle.Alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Remove", style: UIAlertActionStyle.Destructive, handler: { action in
            let user = PFUser.currentUser()
            user!["currentlyActive"] = false
            user?.saveInBackground()
            self.addButton.hidden = false
            self.removeButton.hidden = true
            self.tutors = []
            self.getTutorsFromParse()
        }))
        
        // show the alert
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func refresh(sender:AnyObject) {
        if self.refreshControl.refreshing
        {
            tutors = []
            getTutorsFromParse()
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            
        }
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tutors.count
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }
    
    func getTutorsFromParse() {
        
        let query:PFQuery = PFUser.query()!
        query.whereKey("username", notEqualTo: (PFUser.currentUser()?.username)!)
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
                    tutor.email = obj["email"] as! String
                    //tutor.rating = obj["Rating"] as! Double
                    //tutor.numberOfRatings = obj["numOfRatings"] as! Double
                    let query = PFQuery(className: "Ratings")
                    query.whereKey("username", equalTo: tutor.username)
                    query.findObjectsInBackgroundWithBlock({ (objs: [PFObject]?, error: NSError?) -> Void in
                        if error == nil {
                            for obj in objs! {
                                tutor.rating = obj["rating"] as! Double
                                tutor.numberOfRatings = obj["numOfRatings"] as! Double
                                print(obj)
                            }
                        } else {
                            print(error.debugDescription)
                        }
                    })
                    tutor.coords = obj["HotspotLoc"] as! PFGeoPoint
                    tutor.phone = obj["phone"] as! String
                    print(tutor.name)
                    self.tutors.append(tutor)
                    
                }
            }
            self.loading.stopAnimating()
            self.tableView.reloadData()
        }
        
    }
    func getTutors() {
        
        let tutor1 = Tutor()
        tutor1.name = "Bob Jones"
        tutor1.subject = "Chemistry"
        tutor1.rating = 4.5
        tutor1.price = "$40/hr, $60 for AP"
        tutor1.descrip = "I majored in Chemistry in College."
        //tutor1.coords = CLLocationCoordinate2DMake(37.33299786, -122.02489972)
        tutor1.numberOfRatings = 5
        
        tutors.append(tutor1)
        
        let tutor2 = Tutor()
        tutor2.name = "John Doe"
        tutor2.subject = "Physics"
        tutor2.rating = 3
        tutor2.price = "$40/hr"
        tutor2.descrip = "I majored in Chemistry in College."
        //tutor2.coords = CLLocationCoordinate2DMake(37.33299786, -122.02489972)
        tutor2.numberOfRatings = 4
        
        tutors.append(tutor2)
        
        let tutor3 = Tutor()
        tutor3.name = "Sam Smith"
        tutor3.subject = "CS"
        tutor3.rating = 4
        tutor3.price = "$60/hr"
        tutor3.descrip = "I majored in Chemistry in College."
        //tutor3.coords = CLLocationCoordinate2DMake(37.33299786, -122.02489972)
        tutor3.numberOfRatings = 7
        
        tutors.append(tutor3)
        
        tutors.append(tutor1)
        tutors.append(tutor2)
        tutors.append(tutor3)
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        
        let tutorName = tutors[indexPath.row].name
        let nameLabel = cell.viewWithTag(1) as! UILabel
        nameLabel.text = tutorName
        
        let tutorPrice = tutors[indexPath.row].price
        let priceLabel = cell.viewWithTag(2) as! UILabel
        priceLabel.text = tutorPrice
        
        let tutorSubject = tutors[indexPath.row].subject
        let subjectImage = cell.viewWithTag(4) as! UIImageView
        subjectImage.image = UIImage(named: "\(tutorSubject.lowercaseString)_full.png")

        PFGeoPoint.geoPointForCurrentLocationInBackground { (point: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                print(self.tutors[indexPath.row].coords)
                print(point)
                let distance = (point?.distanceInMilesTo(self.tutors[indexPath.row].coords))!
                print(distance)
                let randLabel = cell.viewWithTag(5) as! UILabel
                let roundedDist = round(distance*100)/100
                randLabel.text = "\(roundedDist) miles away"
            } else {
                let randLabel = cell.viewWithTag(5) as! UILabel
                randLabel.text = "Distance unknown"
            }
        }
        
        let query = PFQuery(className: "Ratings")
        query.whereKey("username", equalTo: tutors[indexPath.row].username)
        query.findObjectsInBackgroundWithBlock({ (objs: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                for obj in objs! {
                    let numRatings = cell.viewWithTag(6) as! UILabel
                    let starRatings = cell.viewWithTag(3) as! CosmosView
                    numRatings.hidden = true
                    starRatings.hidden = true
                    let tutorRating = obj["rating"] as! Double
                    let tutorRatingNumber = obj["numOfRatings"] as! Int
                    print(obj)
                    if tutorRatingNumber == 1 {
                        numRatings.text = "1 rating"
                    } else {
                        numRatings.text = "\(tutorRatingNumber) ratings"
                    }
                    
                    starRatings.rating = tutorRating
                    numRatings.hidden = false
                    starRatings.hidden = false
                }
            } else {
                print(error.debugDescription)
            }
        })

        
        return cell
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toDetail" {
            let nextScene =  segue.destinationViewController as! TutorDetailVC
            
            // Pass the selected object to the new view controller.
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let selectedTutor = tutors[indexPath.row]
                nextScene.tutor = selectedTutor
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
