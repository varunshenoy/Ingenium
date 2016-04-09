//
//  AssignmentVC.swift
//  Ingenium
//
//  Created by Varun Shenoy on 12/21/15.
//  Copyright © 2015 Varun Shenoy. All rights reserved.
//

import UIKit
import Parse

class AssignmentVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var removeButton: UIButton!
    
    var assignments = [Assignment]()
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        var titles = [String]()
        var descriptions = [String]()
        var subjects = [String]()
        let user = PFUser.currentUser()
        if  user!["AssignmentTitles"] != nil {
            titles = user!["AssignmentTitles"] as! [String]
            descriptions = user!["AssignmentDescriptions"] as! [String]
            subjects = user!["AssignmentSubjects"] as! [String]
        }
         
        
        for i in titles {
            let task = Assignment()
            let ind = titles.indexOf(i)!
            task.title = titles[ind]
            task.descrip = descriptions[ind]
            task.subject = subjects[ind]
            assignments.append(task)
        }

        /*let assigned = PFUser.currentUser()!["homework"] as? [Assignment]
        assignments = assigned!*/
        
        //getAssign()
        
    }
    
    func getAssign() {
        
        let newTask = Assignment()
        newTask.title = "Finish Chem Lab"
        newTask.descrip = "Record results in lab book."
        newTask.subject = "Chemistry"
        
        let newTask2 = Assignment()
        newTask2.title = "Finish Physics Worksheet"
        newTask2.descrip = "Show all your work!"
        newTask2.subject = "Physics"
        
        assignments.append(newTask)
        assignments.append(newTask2)
        assignments.append(newTask)
        assignments.append(newTask2)
        assignments.append(newTask)
        assignments.append(newTask2)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return assignments.count
        
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("taskCell")!
        
        let taskName = assignments[indexPath.row].title
        let nameLabel = cell.viewWithTag(1) as! UILabel
        nameLabel.text = taskName
        
        let taskDescription = assignments[indexPath.row].descrip
        let descripLabel = cell.viewWithTag(2) as! UILabel
        descripLabel.text = taskDescription

        let taskSubject = assignments[indexPath.row].subject
        let subjectImage = cell.viewWithTag(3) as! UIImageView
        subjectImage.image = UIImage(named: "\(taskSubject.lowercaseString)_full.png")
        let subjectName = cell.viewWithTag(4) as! UILabel
        subjectName.text = taskSubject.uppercaseString
        
        
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toAddAssignment" {
            let nextScene =  segue.destinationViewController as! addAssignmentVC
            nextScene.loadedAssignments = assignments
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            assignments.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            
            var titles = [String]()
            var descriptions = [String]()
            var subjects = [String]()
            
            for i in assignments {
                titles.append(i.title)
                descriptions.append(i.descrip)
                subjects.append(i.subject)
            }
            
            print(assignments.count)
            let user = PFUser.currentUser()
            user!["AssignmentTitles"] = titles
            user!["AssignmentDescriptions"] = descriptions
            user!["AssignmentSubjects"] = subjects
            user?.saveInBackground()

            
            /*let defaults = NSUserDefaults.standardUserDefaults()
            let assignmentsArray = NSKeyedArchiver.archivedDataWithRootObject(assignments)
            defaults.setObject(assignmentsArray, forKey: "assignments")*/
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
