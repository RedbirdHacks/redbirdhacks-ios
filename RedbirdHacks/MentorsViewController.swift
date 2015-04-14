//
//  MentorsViewController.swift
//  RedbirdHacks
//
//  Created by Tallyn Turnbow on 1/19/15.
//  Copyright (c) 2015 Tallyn Turnbow. All rights reserved.
//

import UIKit
import Social
import MessageUI


class MentorsViewController: UITableViewController {
    
    let session = NSURLSession.sharedSession()
    
    lazy var data = NSMutableData()
    lazy var jsonResult = NSDictionary()
    
    var tableData = NSArray()
    
    var mentors = [Mentor]()
    
    let mentorsURL = "https://redbirdhacks.org/json/mentors.json"
//    var announcements = [AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //        self.tableView.estimatedRowHeight = 100.0
        //        startConnection()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChanged:", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        var mentorsDataTask = session.dataTaskWithURL(NSURL(string: mentorsURL)!) { data, urlResponse, error in
            var jsonErrorOptional: NSError?
            let jsonOptional: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &jsonErrorOptional)
            if let json = jsonOptional as? Dictionary<String, AnyObject> {
                if let newResults = json["mentors"] as? [AnyObject] {
//                    self.tableData = newResults
                    
                    // Add the mentors to the mentorsArray
                    for i in 0 ..< newResults.count {
                        let result: AnyObject = newResults[i]
                        if let name = result["name"] as? String,
                            specialty = result["specialty"] as? String,
                            contacts = result["contacts"] as? [AnyObject],
                            description = result["description"] as? String {
                                var contactMethods = [ContactMethod]()
                                
                                if let contacts = contacts[0] as? Dictionary<String, AnyObject> {
                                    if let twitterString = contacts["twitter"] as? String where !twitterString.isEmpty {
                                        let twitter = ContactMethod.Twitter(NSURL(string: twitterString)!)
                                        contactMethods.append(twitter)
                                    }
                                    if let facebookString = contacts["facebook"] as? String where !facebookString.isEmpty {
                                        let facebook = ContactMethod.Facebook(NSURL(string: facebookString)!)
                                        contactMethods.append(facebook)
                                    }
                                    if let emailString = contacts["email"] as? String where !emailString.isEmpty {
                                        let email = ContactMethod.Email(emailString)
                                        contactMethods.append(email)
                                    }
                                    if let linkedinString = contacts["linkedin"] as? String where !linkedinString.isEmpty {
                                        let linkedin = ContactMethod.LinkedIn(NSURL(string: linkedinString)!)
                                        contactMethods.append(linkedin)
                                    }
                                    if let phoneString = contacts["phone"] as? String where !phoneString.isEmpty {
                                        let phone = ContactMethod.Phone(phoneString)
                                        contactMethods.append(phone)
                                    }
                                }
                                
                                var mentor = Mentor(name: name, specialty: specialty, contacts: contactMethods, description: "")
                                self.mentors.append(mentor)
                        }
                    }
                    
                    // reload data on main thread
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
                }
            }
        }
        mentorsDataTask.resume()
    }
    
    func orientationChanged(notification: NSNotification){
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    // MARK: TableView Stuff
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mentors.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MentorCell", forIndexPath: indexPath) as! MentorCell
        
        let mentor = mentors[indexPath.row]
        
        cell.name.text = mentor.name
        cell.specialty.text = mentor.specialty
        let title: String
        switch mentor.contacts[0] {
        case .Email(let email):
            title = "email"
        case .Facebook(let facebookURL):
            title = "facebook"
        case .LinkedIn(let linkedInURL):
            title = "linkedin"
        case .Phone(let phoneNumber):
            title = "text"
        case .Twitter(let twitterURL):
            title = "tweet"
        }
        cell.contact.setTitle(title, forState: UIControlState.Normal)
        cell.contact.addTarget(self, action: "tapContactButton:", forControlEvents: .TouchUpInside)
        
        return cell
    }
    
    func tapContactButton(sender: UIButton) {
        // get indexPath for button
        // get mentor for indexPath
        // get tapped ContactMethod for mentor
        // perform correct action for ContactMethod
        println("contact button tapped")
        
        if let tappedCell = sender.superview?.superview as? MentorCell,
               tappedCellIndexPath = self.tableView.indexPathForCell(tappedCell) {
            
            let mentor = mentors[tappedCellIndexPath.row]
            let contact = mentor.contacts[0]
                
                switch contact {
                case ContactMethod.Twitter(let twitterURL):
                    let twitterText = twitterURL.relativePath
                    let twitterHandle = twitterText!.substringFromIndex(advance(twitterText!.startIndex,1))
                    
                    if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
                        var tweetSheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                        tweetSheet.setInitialText("@\(twitterHandle) #RedbirdHacks ")
                        self.presentViewController(tweetSheet, animated: true, completion: nil)
                    } else {
                        println("error")
                    }
                case ContactMethod.Email(let emailAddress):
                    println("sending email")
                    var composeViewController = MFMailComposeViewController()
                    composeViewController.mailComposeDelegate = self
                    composeViewController.setSubject("RedbirdHacks - Mentor")
                    composeViewController.setToRecipients([emailAddress])
                    self.presentViewController(composeViewController, animated: true, completion: nil)
                case ContactMethod.Facebook(let facebookURL):
                    UIApplication.sharedApplication().openURL(facebookURL)
                case ContactMethod.LinkedIn(let linkedInURL):
                    UIApplication.sharedApplication().openURL(linkedInURL)
                case ContactMethod.Phone(let phoneNumber):
                    if MFMessageComposeViewController.canSendText() {
                        let messageComposeVC = MFMessageComposeViewController()
                        messageComposeVC.messageComposeDelegate = self
                        messageComposeVC.recipients = [phoneNumber]
                        messageComposeVC.body = "RedbirdHacks - "
                        self.presentViewController(messageComposeVC, animated: true, completion: nil)
                    }
                default:
                    println("tap action not defined")
                }
        }
    }
}

extension MentorsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        switch result.value {
        case MFMailComposeResultCancelled.value:
            NSLog("Mail cancelled")
        case MFMailComposeResultSaved.value:
            NSLog("Mail saved")
        case MFMailComposeResultSent.value:
            NSLog("Mail sent")
        case MFMailComposeResultFailed.value:
            NSLog("Mail sent failure: %@", [error.localizedDescription])
        default:
            break
        }
        self.dismissViewControllerAnimated(false, completion: nil)
    }
}

extension MentorsViewController: MFMessageComposeViewControllerDelegate {
    func deviceCanSendText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
}
