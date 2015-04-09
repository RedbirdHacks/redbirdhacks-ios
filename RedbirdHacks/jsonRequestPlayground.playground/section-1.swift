


import UIKit
//import Foundation
import XCPlayground

XCPSetExecutionShouldContinueIndefinitely()

class RemoteAPI {
    func getData(completionHandler: ((NSArray!, NSError!) -> Void)!) -> Void {
        let url: NSURL = NSURL(string: "http://itunes.apple.com/search?term=Turistforeningen&media=software")!
        let ses = NSURLSession.sharedSession()
        let task = ses.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
            if (error != nil) {
                return completionHandler(nil, error)
            }
            
            var error: NSError?
            let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
            
            if (error != nil) {
                return completionHandler(nil, error)
            } else {
                return completionHandler(json["results"] as [NSDictionary], nil)
            }
        })
        task.resume()
    }
}

var api = RemoteAPI()

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tableView: UITableView!
    var items: NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        self.tableView = UITableView(frame:self.view.frame)
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(self.tableView)
        
        api.getData({data, error -> Void in
            if (data != nil) {
                self.items = NSMutableArray(array: data)
                self.tableView!.reloadData()
                self.view
            } else {
                println("api.getData failed")
                println(error)
            }
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        
        if let navn = self.items[indexPath.row]["trackName"] as? NSString {
            cell.textLabel?.text = navn
        } else {
            cell.textLabel?.text = "No Name"
        }
        
        if let desc = self.items[indexPath.row]["description"] as? NSString {
            cell.detailTextLabel?.text = desc
        }
        
        return cell
    }
}

XCPShowView("Table View", ViewController().view)
