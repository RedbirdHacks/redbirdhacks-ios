//
//  UpdatesViewController.swift
//  RedbirdHacks
//
//  Created by Tallyn Turnbow on 10/19/14.
//  Copyright (c) 2014 Tallyn Turnbow. All rights reserved.
//

import UIKit


class UpdatesViewController: UITableViewController {
    
    let session = NSURLSession.sharedSession()
    
//    lazy var data = NSMutableData()
    lazy var jsonResult = NSDictionary()
    
    var tableData = NSArray()
    
    let announcementsURL = "https://redbirdhacks.org/json/announcements.json"
//    var announcements = [AnyObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.estimatedRowHeight = 100.0
//        startConnection()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChanged:", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        var announcementsDataTask = session.dataTaskWithURL(NSURL(string: announcementsURL)!) { data, urlResponse, error in
            var jsonErrorOptional: NSError?
            let jsonOptional: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &jsonErrorOptional)
            if let json = jsonOptional as? Dictionary<String, AnyObject> {
                if let newResults = json["announcements"] as? [AnyObject] {
//                    self.announcements = newResults
                    self.tableData = newResults
                    
                    // reload data on main thread
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
                }
            }
        }
        announcementsDataTask.resume()
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
//        println("Number of Rows: \(data.length)")
        return tableData.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("UpdateCell", forIndexPath: indexPath) as! UITableViewCell
        
        if let update = self.tableData[indexPath.row] as? NSDictionary {
            if let text = update["text"] as? String {
                var attributedText = NSMutableAttributedString(string: String())
                let wordsArray = split(text, maxSplit: Int.max, allowEmptySlices: false, isSeparator: { $0 == " "})
//                let wordsArray = split(text, { $0 == " "}, maxSplit: Int.max, allowEmptySlices: false)
                for word in wordsArray {
                    if word.hasPrefix("#") {
                        var hashtag = NSMutableAttributedString(string: "\(word) ")
                        let wordRange = NSMakeRange(0, count(word.utf16))
                        // color it red
                        hashtag.addAttribute(NSForegroundColorAttributeName, value: UIColor(red:0.7, green:0, blue:0.1, alpha:1), range:wordRange)
                        // add the URL
//                        hashtag.addAttribute(NSLinkAttributeName, value: "https://twitter.com/search?q=\(word)", range: wordRange)
                        attributedText.appendAttributedString(hashtag)
                    }
                    else {
                        attributedText.appendAttributedString(NSAttributedString(string: "\(word) "))
                    }
                }
                //
                
                cell.textLabel?.attributedText = attributedText
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.sizeToFit()
            }
            if let text = update["date"] as? NSString {
//                formatter.dateStyle = .LongStyle
//                formatter.timeStyle = .ShortStyle
//                let date = formatter.dateFromString(text)
                let seconds = text.doubleValue
                let date = NSDate(timeIntervalSince1970: seconds)
                
                let formatter = NSDateFormatter()
                formatter.dateStyle = .ShortStyle
                formatter.timeStyle = .ShortStyle
                let formattedDateString = formatter.stringFromDate(date)
                cell.detailTextLabel?.text = formattedDateString
            }
        }
        return cell
    }
    
    
    // MARK: JSON request Stuff
}
