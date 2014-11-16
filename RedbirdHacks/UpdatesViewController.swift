//
//  FirstViewController.swift
//  RedbirdHacks
//
//  Created by Tallyn Turnbow on 10/19/14.
//  Copyright (c) 2014 Tallyn Turnbow. All rights reserved.
//

import UIKit


class UpdatesViewController: UITableViewController, NSURLConnectionDelegate {
    
    lazy var data = NSMutableData()
    lazy var jsonResult = NSDictionary()
    
    var tableData = NSArray()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //        self.tableView.estimatedRowHeight = 100.0
        startConnection()
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
    
//    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        var size = CGSize()
//        if let update = self.tableData[indexPath.row] as? NSDictionary {
//            if let text = update["text"] as? NSString {
//                size = text.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14.0)])
//            }
//        }
//        size.height += 40.0
//        return size.height
//    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("UpdateCell", forIndexPath: indexPath) as UITableViewCell
        
        if let update = self.tableData[indexPath.row] as? NSDictionary {
            if let text = update["text"] as? String {
                var attributedText = NSMutableAttributedString(string: String())
                let wordsArray = split(text, { $0 == " "}, maxSplit: Int.max, allowEmptySlices: false)
                for word in wordsArray {
                    if word.hasPrefix("#") {
                        var hashtag = NSMutableAttributedString(string: "\(word) ")
                        let wordRange = NSMakeRange(0, word.utf16Count)
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
            }
            if let text = update["date"] as? NSString {
                let formatter = NSDateFormatter()
                formatter.dateStyle = .LongStyle
                formatter.timeStyle = .ShortStyle
                let date = formatter.dateFromString(text)
                formatter.dateStyle = .ShortStyle
                let formattedDateString = formatter.stringFromDate(date!)
                cell.detailTextLabel?.text = formattedDateString
            }
        }
        return cell
    }
    
    
    // MARK: JSON request Stuff
    
    func startConnection() {
        let urlPath: String = "http://mjhavens.com/announcements.json"
        var url: NSURL = NSURL(string: urlPath)!
        var request: NSURLRequest = NSURLRequest(URL: url)
        var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: false)!
        connection.start()
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        self.data.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        var err: NSError
        jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
        var results: NSArray = jsonResult["announcements"] as NSArray
        self.tableData = results
        println(jsonResult)
        self.tableView.reloadData()
    }

}
