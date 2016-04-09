//
//  addHotspotVC.swift
//  Ingenium
//
//  Created by Varun Shenoy on 12/22/15.
//  Copyright © 2015 Varun Shenoy. All rights reserved.
//

import UIKit
import Parse

class addHotspotVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var priceperhour: DesignableTextField!
    
    @IBOutlet weak var descrip: DesignableTextField!
    
    @IBOutlet weak var subjectPicker: UIPickerView!
    
    @IBOutlet weak var addedView: DesignableView!
    var pickerDataSource = [["Regular", "Honors", "AP"],["Physics", "Biology", "Chemistry", "Geometry", "Trigonometry", "Calculus", "CS", "Government", "American History", "European History", "Literature", "Psychology", "Algebra", "Technology", "Geography", "Spanish", "French", "Chinese", "Japanese"]]
    
    var pins = [Tutor]()
    override func viewDidLoad() {
        super.viewDidLoad()

        subjectPicker.delegate = self
        subjectPicker.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource[component].count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[component][row]
    }

    @IBAction func addHotspotAction(sender: AnyObject) {
        
        print(priceperhour.text!)
        print(descrip.text!)
        let inputInt = subjectPicker.selectedRowInComponent(1)
        print(pickerDataSource[1][inputInt])
        
        let user = PFUser.currentUser()
        user!["Description"] = descrip.text
        user!["Pricing"] = priceperhour.text
        user!["Subject"] = pickerDataSource[1][inputInt]
        user!["currentlyActive"] = true
        PFGeoPoint.geoPointForCurrentLocationInBackground { (geopoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                user!["HotspotLoc"] = geopoint!
                print(geopoint)
            } else {
                print(error.debugDescription)
            }
        }
        
        user!.saveInBackgroundWithBlock { (bool: Bool, error: NSError?) -> Void in
            if error == nil {
                self.addedView.hidden = false
                self.addedView.animate()
            }
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
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
