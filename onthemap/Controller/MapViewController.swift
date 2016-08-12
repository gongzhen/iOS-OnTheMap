//
//  MapViewController.swift
//  onthemap
//
//  Created by gongzhen on 3/21/16.
//  Copyright © 2016 gongzhen. All rights reserved.
//

import UIKit
import MapKit

class MapViewController : UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var dropButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    var annotations = [MKPointAnnotation]()
    var studentInfos:[StudentInfo] = [StudentInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // load students info
        studentInfos = ParseClient.sharedInstance().studentInfos
        mapView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // hard to catch
        studentInfos = ParseClient.sharedInstance().studentInfos
        removeAllAnnotations()
        loadAllAnnotations()
    }
    
    private func loadAllAnnotations() {
        var annotations = [MKPointAnnotation]()
        for studentInfo in studentInfos {
            let annotation = MKPointAnnotation()
            if studentInfo.latitude != nil && studentInfo.longitude != nil {
                annotation.coordinate = CLLocationCoordinate2D(latitude: studentInfo.latitude!, longitude: studentInfo.longitude!)
                annotation.title = studentInfo.firstName! + " " + studentInfo.lastName!
                annotation.subtitle = studentInfo.mediaURL!
                annotations.append(annotation)
            }
        }
        mapView.addAnnotations(annotations)
    }
    
    private func removeAllAnnotations() {
        let locationsToRemove = mapView.annotations.filter { (annotation: MKAnnotation) -> Bool in
            annotation !== mapView.userLocation
        }
        mapView.removeAnnotations(locationsToRemove)
    }
    
    @IBAction func refreshButtonAction(sender: AnyObject) {
        ParseClient.sharedInstance().getStudentLocations { (success, errorString) -> Void in
            // For updating UI, dispatch_async has to be added first for the different thread.
            // http://stackoverflow.com/questions/28302019/getting-a-this-application-is-modifying-the-autolayout-engine-error
            performUIUpdatedsOnMain() {
                if success {
                    self.removeAllAnnotations()
                    self.loadAllAnnotations()
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
    
    @IBAction func dropPinAction(sender: AnyObject) {
        // drop pin Present segue modally.
    }
}

extension MapViewController : MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as? MKPinAnnotationView
        if let pinView = pinView {
            pinView.annotation = annotation
        } else {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        return pinView
    }
    
    // callout button is pin button.
    // app will open the mediaURL.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // The right accessory view to be used in the standard callout.
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            // subtitle is mediaURL
            if let toOpen = view.annotation?.subtitle {
                app.openURL(NSURL(string: toOpen!)!)
            }
        }
    }
}