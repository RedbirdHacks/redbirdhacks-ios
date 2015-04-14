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
    
    var tableGrouped = [Int: [Event]]()
    
    var dayKeys = [Int]()
    
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
//                                eventsArray.append(event)
                                
                                // Check what day the event is on
                                let fromSecondsMinusTimeZone = Int(fromSeconds) + NSTimeZone.systemTimeZone().secondsFromGMT
                                let day = Int(fromSecondsMinusTimeZone / 86400)
                                
                                // if the event is on a day with a key
                                if let eventArrayForDay = self.tableGrouped[day] {
                                    // add the event to the array
                                    var newEvents = eventArrayForDay
                                    newEvents.append(event)
                                    self.tableGrouped[day] = newEvents
                                }
                                // if the event is on a day without a key
                                else {
                                    // create the entry in the dictionary and add the event
                                    self.tableGrouped[day] = [event]
                                    self.dayKeys.append(day)
                                    self.dayKeys.sort({ $0 < $1})
                                }
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
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionArray = tableGrouped[dayKeys[section]]
        let event = sectionArray![0]
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        return "\(formatter.stringFromDate(event.fromDate))"
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableGrouped[dayKeys[section]]!.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tableGrouped.count;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("EventCell", forIndexPath: indexPath) as! EventCell
        
//        let event = self.tableData[indexPath.row]
        let sectionArray = tableGrouped[dayKeys[indexPath.section]]
        let event = sectionArray![indexPath.row]
        
        cell.title.text = event.title
        cell.title.sizeToFit()
        
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        
        cell.startTimeLabel.text = "\(formatter.stringFromDate(event.fromDate)) - "
        cell.endTimeLabel.text = formatter.stringFromDate(event.toDate)
        
        return cell
    }
}