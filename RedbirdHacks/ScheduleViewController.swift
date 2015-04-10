//
//  ScheduleViewController.swift
//  RedbirdHacks
//
//  Created by Tallyn Turnbow on 1/20/15.
//  Copyright (c) 2015 Tallyn Turnbow. All rights reserved.
//

import UIKit

class ScheduleViewController: UITableViewController {
    
    let session = NSURLSession.sharedSession()
    
    lazy var data = NSMutableData()
    lazy var jsonResult = NSDictionary()
    
    var tableData = [Event]()
    
    let scheduleURL = "https://redbirdhacks.org/json/events.json"
    //    var announcements = [AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //        self.tableView.estimatedRowHeight = 100.0
        //        startConnection()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChanged:", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        var scheduleDataTask = session.dataTaskWithURL(NSURL(string: scheduleURL)!) { data, urlResponse, error in
            var jsonErrorOptional: NSError?
            let jsonOptional: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &jsonErrorOptional)
            if let json = jsonOptional as? Dictionary<String, AnyObject> {
                if let newResults = json["events"] as? [AnyObject] {
                    
                    // Load the json into events array here
                    var eventsArray = [Event]()
                    
                    for i in 0 ..< newResults.count {
                        let result: AnyObject = newResults[i]
                        if let toDateText = result["to"] as? NSString,
                               fromDateText = result["from"] as? NSString,
                               title = result["title"] as? String {
                                let toSeconds = toDateText.doubleValue
                                let toDate = NSDate(timeIntervalSince1970: toSeconds)
                                
                                let fromSeconds = fromDateText.doubleValue
                                let fromDate = NSDate(timeIntervalSince1970: fromSeconds)
                                
                                let description = result["description"] as? String
                                
                                var event = Event(fromDate: fromDate, toDate: toDate, title: title, description: description)
                                eventsArray.append(event)
                        }
                    }
                    
                    self.tableData = eventsArray
                    
                    // reload data on main thread
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
                }
            }
        }
        scheduleDataTask.resume()
    }
    
    func orientationChanged(notification: NSNotification){
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    // MARK: TableView Stuff
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("EventCell", forIndexPath: indexPath) as! EventCell
        
        let event = self.tableData[indexPath.row]
        
        cell.title.text = event.title
        cell.title.sizeToFit()
        
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        
        cell.startTimeLabel.text = "\(formatter.stringFromDate(event.fromDate)) - "
        cell.endTimeLabel.text = formatter.stringFromDate(event.toDate)
        
        return cell
    }
}