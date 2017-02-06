//
//  TweetTableViewController.swift
//  tweets
//
//  Created by Гриша on 03.02.17.
//  Copyright © 2017 ru.sapgv. All rights reserved.
//

import UIKit

class TweetTableViewController: UITableViewController, UITextFieldDelegate {

    var loadMoreStatus = false
    var tweets = [Tweet]() {
    
        didSet{
           tableView.reloadData()
        
        }
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var searchField: UITextField! {
        didSet {
            searchField.delegate = self
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchField {
            textField.resignFirstResponder()
            let defaults = UserDefaults.standard
            defaults.set(textField.text, forKey: "lastRequest")
            search(searchText: textField.text)
        }
        return true

    }
    
    func search(searchText: String?) {
        
        tweets.removeAll()
        
        _ = Twitter.sharedInstance.STTwitter?.getSearchTweets(
                    withQuery: searchText,
                    geocode: nil,
                    lang: nil,
                    locale: nil,
                    resultType: nil,
                    count: "20",
                    until: nil,
                    sinceID: nil,
                    maxID: nil,
                    includeEntities: false,
                    callback: nil,
                    useExtendedTweetMode: nil,
                    successBlock: { (searchMetadata: [AnyHashable : Any]?, statuses: [Any]?) in
                        
                        for status in statuses! {
        
                            if let status = status as? [String: Any] {
        
                                print(status)
        
                                let id = String(status["id"] as! Int)
                                
                                let dateString = status["created_at"] as! String
                                
                                let dateFormatter = DateFormatter()
                                dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                                dateFormatter.locale = NSLocale(localeIdentifier: "en_US") as Locale!
                                
                                dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
                                let created_at = dateFormatter.date(from: dateString)

                                let text = status["text"] as! String
                                
                                let userDict = status["user"] as! [String: Any]
                                let name = userDict["name"] as! String
                                let avaterUrl = userDict["profile_image_url"] as! String
                                
                                let tweet = Tweet(id: id, text: text)
                                tweet.name = name
                                tweet.avatarUrl = avaterUrl
                                tweet.date = created_at
                                
                                self.tweets.append(tweet)
                                
                            }
                        
                        }
                        
                },
                    errorBlock: { (error) in
                        print(error!)
                }
                )
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView?.isHidden = true
        
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(refresh(refreshControl:)), for: .valueChanged)
        
    }
    
    func refresh(refreshControl: UIRefreshControl) {

        _ = Twitter.sharedInstance.STTwitter?.getSearchTweets(
            withQuery: searchField.text,
            geocode: nil,
            lang: nil,
            locale: nil,
            resultType: nil,
            count: "20",
            until: nil,
            sinceID: nil,
            maxID: nil,
            includeEntities: false,
            callback: nil,
            useExtendedTweetMode: nil,
            successBlock: { (searchMetadata: [AnyHashable : Any]?, statuses: [Any]?) in
                
                for status in statuses!.reversed() {
                    
                    if let status = status as? [String: Any] {
                        
                        print(status)
                        
                        let id = String(status["id"] as! Int)
                        
                        let dateString = status["created_at"] as! String
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                        dateFormatter.locale = NSLocale(localeIdentifier: "en_US") as Locale!
                        
                        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
                        let created_at = dateFormatter.date(from: dateString)
                        
                        let text = status["text"] as! String
                        
                        let userDict = status["user"] as! [String: Any]
                        let name = userDict["name"] as! String
                        let avaterUrl = userDict["profile_image_url"] as! String
                        
                        let tweet = Tweet(id: id, text: text)
                        tweet.name = name
                        tweet.avatarUrl = avaterUrl
                        tweet.date = created_at
                        
                        if !self.tweets.contains(where: {$0.id == tweet.id}) {
                            self.tweets.insert(tweet, at: 0)
                        }
                        
                    }
                    
                }
                self.refreshControl!.endRefreshing()
        },
            errorBlock: { (error) in
                print(error!)
        }
        )


    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        
        if deltaOffset <= 0 {
            loadMore()
        }

    }

    
    func loadMore() {
        if ( !loadMoreStatus ) {
            self.loadMoreStatus = true
            self.activityIndicator.startAnimating()
            self.tableView.tableFooterView?.isHidden = false
            loadMoreBegin(newtext: "Load more",
                          loadMoreEnd: {(x:Int) -> () in
                            self.tableView.reloadData()
                            self.loadMoreStatus = false
                            self.activityIndicator.stopAnimating()
                            self.tableView.tableFooterView?.isHidden = true
            })
        }
    }
    
    func loadMoreBegin(newtext:String, loadMoreEnd:@escaping (Int) -> ()) {
        
        // Move to a background thread to do some long running work
        DispatchQueue.global(qos: .default).async {
            
            print("loadmore")
            if let lastTweet = self.tweets.last {
                _ = Twitter.sharedInstance.STTwitter?.getSearchTweets(
                    withQuery: self.searchField.text,
                    geocode: nil,
                    lang: nil,
                    locale: nil,
                    resultType: nil,
                    count: "20",
                    until: nil,
                    sinceID: lastTweet.id,
                    maxID: nil,
                    includeEntities: false,
                    callback: nil,
                    useExtendedTweetMode: nil,
                    successBlock: { (searchMetadata: [AnyHashable : Any]?, statuses: [Any]?) in
                        
                        for status in statuses! {
                            
                            if let status = status as? [String: Any] {
                                
                                print(status)
                                
                                let id = String(status["id"] as! Int)
                                
                                let dateString = status["created_at"] as! String
                                
                                let dateFormatter = DateFormatter()
                                dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                                dateFormatter.locale = NSLocale(localeIdentifier: "en_US") as Locale!
                                
                                dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
                                let created_at = dateFormatter.date(from: dateString)
                                
                                let text = status["text"] as! String
                                
                                let userDict = status["user"] as! [String: Any]
                                let name = userDict["name"] as! String
                                let avaterUrl = userDict["profile_image_url"] as! String
                                
                                let tweet = Tweet(id: id, text: text)
                                tweet.name = name
                                tweet.avatarUrl = avaterUrl
                                tweet.date = created_at
                                


                                if !self.tweets.contains(where: {$0.id == tweet.id}) {
                                    self.tweets.append(tweet)
                                }
                                
                            }
                            
                        }
                        
                        DispatchQueue.main.async {
                            loadMoreEnd(0)
                        }

                        
                },
                    errorBlock: { (error) in
                        print(error!)
                }
                )
            }
            
            DispatchQueue.main.async {
                loadMoreEnd(0)
            }
        }
        
        
    }

    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweets.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let tweet = tweets[indexPath.row]

        let showAvatar = UserDefaults.standard.bool(forKey: "showAvatar")
        
        if showAvatar {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TweetTableViewCell

            if let tweetDate = tweet.date {
                
                let dateFormatter = DateFormatter()
                dateFormatter.locale = NSLocale(localeIdentifier: "ru_RU") as Locale!
                dateFormatter.dateFormat = "d MMM yyyy"
                
                let dateString = dateFormatter.string(from: tweetDate)
                cell.dateLabel?.text = dateString
                
                cell.tweetText?.text = tweet.text
                cell.nameLabel?.text = tweet.name
                
//                DispatchQueue.global(qos: .default).async {
                
                    let urlString = tweet.avatarUrl!
                    
                    let urlAvatar = NSURL(string: urlString)!
                    if let data = NSData(contentsOf: urlAvatar as URL) {
                        
//                        DispatchQueue.main.async {
                            cell.avatarImageView.image = UIImage(data: data as Data)
                            
//                        }
//                    }
                    
                }
            

            }
            return cell

        
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! TweetTableViewCell
            
            if let tweetDate = tweet.date {
                
                let dateFormatter = DateFormatter()
                dateFormatter.locale = NSLocale(localeIdentifier: "ru_RU") as Locale!
                dateFormatter.dateFormat = "d MMM yyyy"
                
                let dateString = dateFormatter.string(from: tweetDate)
                cell.dateLabel?.text = dateString
                
                cell.tweetText?.text = tweet.text
                cell.nameLabel?.text = tweet.name
                
            }
            return cell

        }
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let dvc = segue.destination as? TweetViewController {
            
            if let cell = sender as? TweetTableViewCell {
                
                if let indexPath = tableView.indexPath(for: cell) {
                    
                    let tweet = tweets[indexPath.row]
                    dvc.tweet = tweet
                }
                
            }
        }

    }


}
