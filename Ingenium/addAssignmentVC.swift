//
//  addAssignmentVC.swift
//  Ingenium
//
//  Created by Varun Shenoy on 12/21/15.
//  Copyright © 2015 Varun Shenoy. All rights reserved.
//

import UIKit
import Parse

class addAssignmentVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var loadedAssignments = [Assignment]()

    @IBOutlet weak var taskTitle: DesignableTextField!
    
    @IBOutlet weak var taskDescrip: DesignableTextView!
    
    @IBOutlet weak var subjectPicker: UIPickerView!
    
    var pickerDataSource = [["Regular", "Honors", "AP"],["Physics", "Biology", "Chemistry", "Geometry", "Trigonometry", "Calculus", "CS", "Government", "American History", "European History", "Literature", "Psychology", "Algebra", "Technology", "Geography", "Spanish", "French", "Chinese", "Japanese"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subjectPicker.dataSource = self
        subjectPicker.delegate = self
        
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
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func addAssignment(sender: AnyObject) {

        let newTask = Assignment()
        newTask.title = taskTitle.text!
        newTask.descrip = taskDescrip.text
        let inputInt = subjectPicker.selectedRowInComponent(1)
        newTask.subject = pickerDataSource[1][inputInt]
        print(newTask.subject)
        
        loadedAssignments.append(newTask)
        
        var titles = [String]()
        var descriptions = [String]()
        var subjects = [String]()
        
        for i in loadedAssignments {
            titles.append(i.title)
            descriptions.append(i.descrip)
            subjects.append(i.subject)
        }
        
        print(loadedAssignments.count)
        if newTask.title != "" {
            let user = PFUser.currentUser()
            user!["AssignmentTitles"] = titles
            user!["AssignmentDescriptions"] = descriptions
            user!["AssignmentSubjects"] = subjects
            user?.saveInBackground()
        }
        
        /*let defaults = NSUserDefaults.standardUserDefaults()
        let data = NSKeyedArchiver.archivedDataWithRootObject(loadedAssignments)
        defaults.setObject(data, forKey: "assignments")*/
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addAssignment" {
            let nextScene =  segue.destinationViewController as! UITabBarController
            nextScene.selectedIndex = 2
            //store data
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
