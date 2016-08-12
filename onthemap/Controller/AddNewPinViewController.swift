//
//  AddNewPinViewController.swift
//  onthemap
//
//  Created by gongzhen on 3/24/16.
//  Copyright © 2016 gongzhen. All rights reserved.
//

import UIKit
import MapKit
import Foundation

class AddNewPinViewController: UIViewController {
    
    // MARK: Outlet
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var urlLinkTextField: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    
    // MARK: Properties
    
    var placemark: MKPlacemark!
    var studentInfo: StudentInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitButton.enabled = false
    }
    
    @IBAction func findLocationAction(sender: AnyObject) {
        
        guard checkValidTextField(self.locationTextField.text) == true else {
            let alert = UIAlertController(title: "Error", message: "Must enter a link.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        activityIndicator.startAnimating()
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(self.locationTextField.text!, completionHandler
            :{ ( placemarks: [CLPlacemark]?, error: NSError?) -> Void in
            guard error == nil else {
                return
            }
                
            guard placemarks?.count > 0 else {
                return
            }
            // generating the pin.
            performUIUpdatedsOnMain() {
                self.activityIndicator.stopAnimating()
                self.placemark = MKPlacemark(placemark: placemarks![0])
                self.mapView.addAnnotation(self.placemark)
                let region = MKCoordinateRegionMakeWithDistance(self.placemark.coordinate, 100000, 100000)
                self.mapView.setRegion(region, animated: true)
                self.submitButton.enabled = true
            }
        })
    }
    
    @IBAction func previewURLAction(sender: AnyObject) {
        guard checkValidTextField(self.urlLinkTextField.text) == true else {
            let alert = UIAlertController(title: "Error", message: "Must enter a url link.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        let app = UIApplication.sharedApplication()
        var urlString : String
        if self.urlLinkTextField.text!.rangeOfString("https://") == nil {
            urlString = "https://" + self.urlLinkTextField.text!
        } else {
            urlString = self.urlLinkTextField.text!
        }
        let url = NSURL(string: urlString)!
        if app.canOpenURL(url) {
            app.openURL(url)
        } else {
            let alert = UIAlertController(title: "Error", message: "Cannot open link.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
        
    @IBAction func subNewPinAction(sender: AnyObject) {        
        guard checkValidTextField(self.locationTextField.text) == true else {
            let alert = UIAlertController(title: "Error", message: "Must enter a location.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        guard checkValidTextField(self.urlLinkTextField.text) == true else {
            let alert = UIAlertController(title: "Error", message: "Must enter a url link.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        let userData = getUserData()
        ParseClient.sharedInstance().postStudentLocations(userData) { (success, error) -> Void in
            performUIUpdatedsOnMain {
                if success {
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Error", message: "Pin is not valid.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func checkValidTextField(textField: String?) -> Bool {
        if let textField = self.locationTextField.text where textField != "" {
            return true
        }
        return false
    }
    
    private func getUserData() -> [String: String]{
        var userData = [String: String]()
        userData["accountKey"] = UdacityClient.sharedInstance().accountKey
        userData["first_name"] = UdacityClient.sharedInstance().firstName
        userData["last_name"] = UdacityClient.sharedInstance().lastName
        userData["mapString"] = self.locationTextField.text!
        userData["mediaURL"] = self.urlLinkTextField.text!
        userData["latitude"] = String(self.placemark.coordinate.latitude)
        userData["longitude"] = String(self.placemark.coordinate.longitude)
        return userData
    }
    
    @IBAction func cancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
