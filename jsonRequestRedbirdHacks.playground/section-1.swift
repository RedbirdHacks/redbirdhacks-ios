// Playground - noun: a place where people can play

import UIKit

import XCPlayground
XCPSetExecutionShouldContinueIndefinitely()

let session = NSURLSession.sharedSession()

// parsing announcements json
let announcementsURL = "http://redbirdhacks.org/json/announcements.json"
var announcements = [AnyObject]()

var announcementsDataTask = session.dataTaskWithURL(NSURL(string: announcementsURL)!) { data, urlResponse, error in
    var jsonErrorOptional: NSError?
    let jsonOptional: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &jsonErrorOptional)
    if let json = jsonOptional as? Dictionary<String, AnyObject> {
        if let newResults = json["announcements"]? as? [AnyObject] {
            announcements = newResults
        }
    }
}
announcementsDataTask.resume()


// parsing events json
let eventsURL = "http://redbirdhacks.org/json/events.json"
var events = [AnyObject]()

var eventsDataTask = session.dataTaskWithURL(NSURL(string: eventsURL)!) { data, urlResponse, error in
    var jsonErrorOptional: NSError?
    let jsonOptional: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &jsonErrorOptional)
    if let json = jsonOptional as? Dictionary<String, AnyObject> {
        if let newResults = json["events"]? as? [AnyObject] {
            announcements = newResults
        }
    }
}
eventsDataTask.resume()


// parsing mentors json
let mentorsURL = "http://redbirdhacks.org/json/mentors.json"
var mentors = [AnyObject]()

var mentorsDataTask = session.dataTaskWithURL(NSURL(string: mentorsURL)!) { data, urlResponse, error in
    var jsonErrorOptional: NSError?
    let jsonOptional: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &jsonErrorOptional)
    if let json = jsonOptional as? Dictionary<String, AnyObject> {
        if let newResults = json["mentors"]? as? [AnyObject] {
            announcements = newResults
        }
    }
}
mentorsDataTask.resume()