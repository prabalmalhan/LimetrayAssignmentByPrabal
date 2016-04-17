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
var check = true
class tweet: UITableViewController,TwitterFollowerDelegate {

    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    var serviceWrapper: TwitterServiceWrapper = TwitterServiceWrapper()
    var heightDictionaryForTweet = [Int:CGFloat]()
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
        cell.tweetDate.text = tweet.created_at
        cell.tweet_text.sizeToFit()
        heightDictionaryForTweet[indexPath.row] = cell.tweet_text.frame.height + 30
            return cell
        }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetsFromCoreData.count
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let height = heightDictionaryForTweet[indexPath.row]{
            if height > 70{
                return height
            }
        }
        return 70
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
             
                
                lastSinceId = "\(fetchResults[0].id.toInt()!+1)"
                
                
            }
      
            if (check){
                serviceWrapper.getResponseForRequest("https://api.twitter.com/1.1/search/tweets.json?&since_id=\(lastSinceId)f=tweets&vertical=default&q=%22limetray%22&count=800&src=typd")
                check = false
            }
            tweetsFromCoreData.sort({ $0.id > $1.id })
            self.tableView.reloadData()
        }
        else{
            serviceWrapper.getResponseForRequest("https://api.twitter.com/1.1/search/tweets.json?f=tweets&vertical=default&q=%22limetray%22&count=800&src=typd")
            check = false
            
 
            
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
