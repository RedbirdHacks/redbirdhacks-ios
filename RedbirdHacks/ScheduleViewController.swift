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
    
    var tableData = NSArray()
    
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
                if let newResults = json["events"]? as? [AnyObject] {
                    self.tableData = newResults
                    
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
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    // MARK: TableView Stuff
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println("Number of Rows: \(data.length)")
        return tableData.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("EventCell", forIndexPath: indexPath) as UITableViewCell
        
        if let event = self.tableData[indexPath.row] as? NSDictionary {
            if let text = event["title"] as? String {
                cell.detailTextLabel?.text = text
            }
            if let text = event["time"] as? String {
                cell.textLabel?.text = text
            }
        }
        return cell
    }
}