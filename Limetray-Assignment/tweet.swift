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
class tweet: UITableViewController,TweetsDelegate {
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    var serviceWrapper: TwitterServiceWrapper = TwitterServiceWrapper()
    var heightDictionaryForTweet = [Int:CGFloat]()
    var tweetsFromCoreData = [Tweets]()
    
    //MARK: LifeCycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        serviceWrapper.delegate = self
        reloadData()
        var refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("refreshControlMethod"), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
    }
    
    //MARK: TableView Data Source and Delegate Methods
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TweetCell
        let tweet = tweetsFromCoreData[indexPath.row] as Tweets
       
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

    func refreshControlMethod(){
        check = true
        reloadData()
    }
//MARK: CoreData Fetch Request
   func reloadData(){
    self.refreshControl?.beginRefreshing()
    let fetchRequest = NSFetchRequest(entityName: "LimeTrayTweets")
    
    
    if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [LimeTrayTweets] {
        
        if fetchResults.count != 0{
            
            for results in fetchResults{
                let alreadyFound = tweetsFromCoreData.filter( { return $0.id == results.id })
                if alreadyFound.count == 0 {
                    tweetsFromCoreData.append(Tweets(text: results.text, date: results.date, id: results.id))
                }
                
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
    refreshControl?.endRefreshing()

    }
    // MARK: - TwitterFollowerDelegate methods
    
    func finishedDownloading(tweetu: Tweets) {
     dispatch_async(dispatch_get_main_queue(), { () -> Void in   
            self.createTask(tweetu)
            self.tableView.reloadData()
            self.reloadData()
////            self.activityIndicator.stopAnimating()
////            self.activityIndicator.hidden = true
        })
        
    }
//MARK:- CoreData Save Entity
    func createTask(tweetData:Tweets) {
       
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("LimeTrayTweets", inManagedObjectContext: self.managedObjectContext!) as! LimeTrayTweets
                    newItem.id = tweetData.id!
                    newItem.text = tweetData.tweet!
                    newItem.date = tweetData.created_at!
                    managedObjectContext?.save(nil)
       
    }
    
}
