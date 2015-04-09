//
//  MentorsViewController.swift
//  RedbirdHacks
//
//  Created by Tallyn Turnbow on 1/19/15.
//  Copyright (c) 2015 Tallyn Turnbow. All rights reserved.
//

import UIKit


class MentorsViewController: UITableViewController {
    
    let session = NSURLSession.sharedSession()
    
    lazy var data = NSMutableData()
    lazy var jsonResult = NSDictionary()
    
    var tableData = NSArray()
    
    let mentorsURL = "http://redbirdhacks.org/json/mentors.json"
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
                if let newResults = json["mentors"]? as? [AnyObject] {
                    self.tableData = newResults
                    
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
        println("Number of Rows: \(data.length)")
        return tableData.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MentorCell", forIndexPath: indexPath) as MentorCell
        
        if let mentor = self.tableData[indexPath.row] as? NSDictionary {
            if let text = mentor["name"] as? String {
                cell.name.text = text
            }
            if let text = mentor["specialty"] as? String {
                cell.specialty.text = text
            }
        }
        return cell
    }
    
    
    // MARK: JSON request Stuff
}
