//
//  LoginViewController.swift
//  onthemap
//
//  Created by gongzhen on 3/18/16.
//  Copyright © 2016 gongzhen. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorboxLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    var session: NSURLSession!
    
    private var dataManager: StudentDataAccessManager!
    
    var keyboardOnScreen = false
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataManager = StudentDataAccessManager()
        
        configureUI()
        
        // Keyboard show/hide
        subscribeToNotification(UIKeyboardWillShowNotification, selector: UdacityClient.Selectors.KeyboardWillShow)
        subscribeToNotification(UIKeyboardWillHideNotification, selector: UdacityClient.Selectors.KeyboardWillHide)
        subscribeToNotification(UIKeyboardDidShowNotification, selector: UdacityClient.Selectors.KeyboardDidShow)
        subscribeToNotification(UIKeyboardDidHideNotification, selector: UdacityClient.Selectors.KeyboardDidHide)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
    
    // MARK: Actions
    
    
    func deprecated_loginPressed(sender: AnyObject) {
        UdacityClient.sharedInstance().authWithUdacity(emailTextField.text!, passwd: passwordTextField.text!, completionHandlerForUdacityAuth: ({ (success, errorString) -> Void in
            guard success else {
                // This application is modifying the autolayout engine from a background thread.
                // which can lead to engine corruption and weird crashes.
                performUIUpdatedsOnMain {
                    self.performAlertView(msgForTitle: "Error", msgForAction: "Click", msgForError: errorString!)
                }
                return
            }
            performUIUpdatedsOnMain {
                self.completeLogin()
            }
        }))
    }
    
    @IBAction func loginPressed(sender: AnyObject) {
        loginButton.hidden = true
        if let emailTextField = emailTextField.text,
            passwordTextField = passwordTextField.text {
            dataManager.authenticateByUsername(emailTextField, withPassword: passwordTextField,
                // completionHandler:(success: Bool, error: NSError?)
                completionHandler:handleAuthenticationResponse)
        }
    }
    
    // MARK: Login
    
    private func completeLogin() {
        errorboxLabel.text = ""
        let controller = storyboard!.instantiateViewControllerWithIdentifier("OnthemapTabBarController") as! UITabBarController
        presentViewController(controller, animated: true, completion: nil)
    }
    
    // MARK: Authentication
    
    private func handleAuthenticationResponse(success: Bool, error: NSError?) {
        if success {
            self.transitionSucessfulLoginSegue()
        } else {
            performUIUpdatedsOnMain() {
                if let errorString = error?.localizedDescription {
                    self.performAlertView(msgForTitle: "Error", msgForAction: "Click", msgForError: errorString)
                }
            }
        }
    }
    
    // MARK: Segue Transition
    
    private func transitionSucessfulLoginSegue() {
        performUIUpdatedsOnMain() {
            self.performSegueWithIdentifier("SuccessfulLoginSegue", sender: self.dataManager)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let tabBarController = segue.destinationViewController as? ManagingTabBarController, dataManager = sender as? StudentDataAccessManager {
            tabBarController.dataManager = dataManager
        } else {
            //@todo Error
            
        }
    }
    
    // MARK: Logout
    // unwind segue
    @IBAction func segueToLoginScreen(segue: UIStoryboardSegue) {
        self.errorboxLabel.text = ""
    }
}

// MARK: - LoginViewController: UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {

    // MAKR: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.isFirstResponder()
        return true
    }
}


// MARK: - LoginViewController (Configure UI)

extension LoginViewController {
    
    private func configureUI() {
        configureTextField(emailTextField)
        configureTextField(passwordTextField)
    }
    
    private func configureTextField(textField: UITextField) {
        textField.delegate = self
    }
    
    private func displayError(errorString: String?) {
        if let errorString = errorString {
            errorboxLabel.text = errorString
        }
    }
    
    private func performAlertView(msgForTitle title: String, msgForAction action: String, msgForError error: String) {
        let alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: action, style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

// MARK: - LoginViewController (Notification)

extension LoginViewController {

    private func subscribeToNotification(notification: String, selector: Selector) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: notification, object: nil)
    }

    private func unsubscribeFromAllNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MAKR: Show/Hide Keyboard
    
    func keyboardWillShow(notification: NSNotification) {
        if !keyboardOnScreen {
            view.frame.origin.y -= keyboardHeight(notification)
            imageView.hidden = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if keyboardOnScreen {
            // view.frame.origin.y += keyboardHeight(notification)
            view.frame.origin.y = 0
            imageView.hidden = false
        }
    }
    
    func keyboardDidShow(notification: NSNotification) {
        keyboardOnScreen = true
    }
    
    func keyboardDidHide(notifcation: NSNotification) {
        keyboardOnScreen = false
    }
    
    private func keyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
}

