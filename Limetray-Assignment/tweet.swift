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
class tweet: UITableViewController,TweetsDelegate,UITextViewDelegate {
    
    @IBAction func alert(sender: AnyObject) {
        
        let alerter = UIAlertController(title: "About Twitter Links' ", message: "twitter uses http:\\t.co to shorten link but whenever a mention links to SOME OTHER SITE then twitter does not passes that link in the search api just provide us with the initial t.co thus some links might not work", preferredStyle: UIAlertControllerStyle.Alert)
       
       
        
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "OK ,Cool ", style: .Default) { action -> Void in
            //Just dismiss the action sheet
        }
        alerter.addAction(cancelAction)
      
        self.presentViewController(alerter, animated: true, completion: nil)
    }
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
       
    
        cell.tweetDate.text = tweet.created_at
       
        
        
        cell.tweet_textView.text = tweet.tweet
        cell.tweet_textView.resolveHashTags()
        cell.tweet_textView.sizeToFit()
        

        heightDictionaryForTweet[indexPath.row] = cell.tweet_textView.frame.height + 20
            return cell
        }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetsFromCoreData.count
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let height = heightDictionaryForTweet[indexPath.row]{
            if height > 125{
                return height
            }
        }
        return heightDictionaryForTweet[indexPath.row] ?? 100
    }

    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        
        // check for our fake URL scheme hash:helloWorld
        if let scheme = URL.scheme {
            switch scheme {
            case "hash" :
                showHashTagAlert("hash", payload: URL.resourceSpecifier!)
            case "mention" :
                showHashTagAlert("mention", payload: URL.resourceSpecifier!)
            default:
                println("just a regular url")
            }
        }
        
        return true
    }
    func showHashTagAlert(tagType:String, payload:String){
        let alertView = UIAlertView()
        alertView.title = "\(tagType) tag detected"
        // get a handle on the payload
        alertView.message = "\(payload)"
        alertView.addButtonWithTitle("Ok")
        alertView.show()
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
//            var i = 0
            for results in fetchResults{
                let alreadyFound = tweetsFromCoreData.filter( { return $0.id == results.id })
                if alreadyFound.count == 0 {
                    tweetsFromCoreData.append(Tweets(text: results.text, date: results.date, id: results.id))
                    
//                    let textView = UITextView()
//                    textView.text = results.text
//                    textView.sizeToFit()
//                    textView.resolveHashTags()
//                    
//                    heightDictionaryForTweet[i] = textView.frame.height + 20
//                    println(heightDictionaryForTweet[i])
//                    i = i+1
                    
                    
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
extension UITextView {
    
    func chopOffNonAlphaNumericCharacters(text:String) -> String {
        var nonAlphaNumericCharacters = NSCharacterSet.alphanumericCharacterSet().invertedSet
        let characterArray = text.componentsSeparatedByCharactersInSet(nonAlphaNumericCharacters)
        return characterArray[0]
    }
    
    /// Call this manually if you want to hash tagify your string.
    func resolveHashTags(){
        
        let schemeMap = [
            "#":"hash",
            "@":"mention"
        ]
        
        // Turn string in to NSString.
        // NSString gives us some helpful API methods
        let nsText:NSString = self.text
        
        // Separate the string into individual words.
        // Whitespace is used as the word boundary.
        // You might see word boundaries at special characters, like before a period.
        // But we need to be careful to retain the # or @ characters.
        let words:[NSString] = nsText.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) as! [NSString]
        
        // Attributed text overrides anything set in the Storyboard.
        // So remember to set your font, color, and size here.
        var attrs = [
            //            NSFontAttributeName : UIFont(name: "Georgia", size: 20.0)!,
            //            NSForegroundColorAttributeName : UIColor.greenColor(),
            NSFontAttributeName : UIFont.systemFontOfSize(17.0)
        ]
        
        // Use an Attributed String to hold the text and fonts from above.
        // We'll also append to this object some hashtag URLs for specific word ranges.
        var attrString = NSMutableAttributedString(string: nsText as String, attributes:attrs)
        
        // Iterate over each word.
        // So far each word will look like:
        // - I
        // - visited
        // - #123abc.go!
        // The last word is a hashtag of #123abc
        // Use the following hashtag rules:
        // - Include the hashtag # in the URL
        // - Only include alphanumeric characters.  Special chars and anything after are chopped off.
        // - Hashtags can start with numbers.  But the whole thing can't be a number (#123abc is ok, #123 is not)
        for word in words {
            
            var scheme:String? = nil
            
            if word.hasPrefix("#") {
                scheme = schemeMap["#"]
            } else if word.hasPrefix("@") {
                scheme = schemeMap["@"]
            }
            
            // found a word that is prepended by a hashtag
            if let scheme = scheme {
                
                // convert the word from NSString to String
                // this allows us to call "dropFirst" to remove the hashtag
                var stringifiedWord:String = word as String
                
                // example: #123abc.go!
                
                // drop the hashtag
                // example becomes: 123abc.go!
                stringifiedWord = dropFirst(stringifiedWord)
                
                // Chop off special characters and anything after them.
                // example becomes: 123abc
                stringifiedWord = chopOffNonAlphaNumericCharacters(stringifiedWord)
                
                if let stringIsNumeric = stringifiedWord.toInt() {
                    // don't convert to hashtag if the entire string is numeric.
                    // example: 123abc is a hashtag
                    // example: 123 is not
                } else if stringifiedWord.isEmpty {
                    // do nothing.
                    // the word was just the hashtag by itself.
                } else {
                    // set a link for when the user clicks on this word.
                    var matchRange:NSRange = nsText.rangeOfString(stringifiedWord as String)
                    // Remember, we chopped off the hash tag, so:
                    // 1.) shift this left by one character.  example becomes:  #123ab
                    matchRange.location--
                    // 2.) and lengthen the range by one character too.  example becomes:  #123abc
                    matchRange.length++
                    // URL syntax is http://123abc
                    
                    // Replace custom scheme with something like hash://123abc
                    // URLs actually don't need the forward slashes, so it becomes hash:123abc
                    // Custom scheme for @mentions looks like mention:123abc
                    // As with any URL, the string will have a blue color and is clickable
                    attrString.addAttribute(NSLinkAttributeName, value: "\(scheme):\(stringifiedWord)", range: matchRange)
                }
            }
            
        }
        
        // Use textView.attributedText instead of textView.text
        self.attributedText = attrString
    }
    
}
