//
//  tweet.swift
//  Limetray-Assignment
//
//  Created by Prabal Malhan on 4/16/16.
//  Copyright (c) 2016 Prabal Malhan. All rights reserved.
//

import UIKit
import CoreData


var lastSinceId = ""
class tweet: UITableViewController,TwitterFollowerDelegate {

    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    var serviceWrapper: TwitterServiceWrapper = TwitterServiceWrapper()
//    var tweets = [TwitterFollower]()
    var tweetsFromCoreData = [TwitterFollower]()
    override func viewDidLoad() {
        super.viewDidLoad()
        serviceWrapper.delegate = self
        reloadData()
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TweetCell
        let tweet = tweetsFromCoreData[indexPath.row] as TwitterFollower
                cell.tweet_text.text = tweet.tweet
        return cell
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetsFromCoreData.count
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
   func reloadData(){
     // Create a new fetch request using the LogItem entity
    let fetchRequest = NSFetchRequest(entityName: "LimeTrayTweets")
    
    // Execute the fetch request, and cast the results to an array of LogItem objects
    if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [LimeTrayTweets] {
        
        if fetchResults.count != 0{
            
            println("Fetch Results COunt \(fetchResults.count)")
            for results in fetchResults{
               
                    
                
               let alreadyFound = tweetsFromCoreData.filter( { return $0.id == results.id })
                if alreadyFound.count == 0 {
                    tweetsFromCoreData.append(TwitterFollower(text: results.text, date: results.date, id: results.id))
                }
                println("Fetch Results  ")
                println(results.date + results.id)
            }
            lastSinceId = fetchResults[0].id
            serviceWrapper.getResponseForRequest("https://api.twitter.com/1.1/search/tweets.json?&since_id=\(lastSinceId)f=tweets&vertical=default&q=%22limetray%22&count=800&src=typd")
            self.tableView.reloadData()
        }
        else{
            serviceWrapper.getResponseForRequest("https://api.twitter.com/1.1/search/tweets.json?f=tweets&vertical=default&q=%22limetray%22&count=800&src=typd")
            
            
//            let seconds = 5.0
//            let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
//            let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
//            
//            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
//                
//                // here code perfomed with delay
//                println("after 10 sec")
//                self.serviceWrapper.getResponseForRequest("https://api.twitter.com/1.1/search/tweets.json?&max_id=718678414312534015f=tweets&vertical=default&q=%22limetray%22&count=200&src=typd")
//                
//            })
            
        }
        
        
    }

    }
    // MARK: - TwitterFollowerDelegate methods
    
    func finishedDownloading(follower: TwitterFollower) {
//        createTask(follower)
        
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            
//            self.tweets.append(follower)
            self.createTask(follower)
            self.tableView.reloadData()
            self.reloadData()
////            self.activityIndicator.stopAnimating()
////            self.activityIndicator.hidden = true
        })
        
    }
    func createTask(tweetData:TwitterFollower) {
       
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("LimeTrayTweets", inManagedObjectContext: self.managedObjectContext!) as! LimeTrayTweets
                    newItem.id = tweetData.id!
                    newItem.text = tweetData.tweet!
                    newItem.date = tweetData.created_at!
                    managedObjectContext?.save(nil)
       
    }
    
}
