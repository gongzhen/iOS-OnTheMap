//
//  TableViewController.swift
//  onthemap
//
//  Created by gongzhen on 3/22/16.
//  Copyright © 2016 gongzhen. All rights reserved.
//

import UIKit
import MapKit

class TableViewController: UIViewController {

    var studentInfos:[StudentInfo] = [StudentInfo]()
    
    @IBOutlet weak var listTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.listTableView.delegate = self
        self.listTableView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.studentInfos = ParseClient.sharedInstance().studentInfos
        if !self.studentInfos.isEmpty {
            self.listTableView.reloadData()
        }
    }
    
    @IBAction func refreshButtonAction(sender: AnyObject) {
        ParseClient.sharedInstance().getStudentLocations { (success, errorString) -> Void in
            // For updating UI, dispatch_async has to be added first for the different thread.
            // http://stackoverflow.com/questions/28302019/getting-a-this-application-is-modifying-the-autolayout-engine-error
            performUIUpdatedsOnMain() {
                if success {
                    self.listTableView.reloadData()
                } else {
                    let alert = UIAlertController(title: "Error", message: errorString, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func logoutAction(sender: AnyObject) {
        UdacityClient.sharedInstance().logoutUdacity { (success, errorString) -> Void in
            if success {
                /*
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController = storyboard.instantiateViewControllerWithIdentifier("loginViewController") as! LoginViewController
                self.presentViewController(loginViewController, animated: true, completion: nil)
                */
                self.performSegueWithIdentifier("ReturnToLoginScreenSegue", sender: self)
            }
        }
    }
    
}

extension TableViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.studentInfos.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ListTableCell", forIndexPath: indexPath) as! CustomTableViewCell
        let studentInfo = self.studentInfos[indexPath.row]
        cell.pinImage.image = UIImage(named: "Pin")
        cell.firstNameLabel.text = studentInfo.firstName
        cell.lastNameLabel.text = studentInfo.lastName
        cell.mediaURLLabel.text = studentInfo.mediaURL
        return cell
    }   
}
