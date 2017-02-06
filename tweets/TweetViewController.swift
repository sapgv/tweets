//
//  TweetViewController.swift
//  tweets
//
//  Created by Гриша on 05.02.17.
//  Copyright © 2017 ru.sapgv. All rights reserved.
//

import UIKit

class TweetViewController: UIViewController {

    var tweet: Tweet? = nil
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tweetText: UITextView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        if let tweet = tweet {
            self.tweetText?.text = tweet.text
            self.nameLabel?.text = tweet.name
            
            if let tweetDate = tweet.date {
                
                let dateFormatter = DateFormatter()
                dateFormatter.locale = NSLocale(localeIdentifier: "ru_RU") as Locale!
                dateFormatter.dateFormat = "d MMM yyyy HH:mm:ss"
                let dateString = dateFormatter.string(from: tweetDate)
                self.dateLabel?.text = dateString
            
            }
            
            
            let urlString = tweet.avatarUrl!
            let newUrlString = urlString.replacingOccurrences(of: "normal", with: "400x400", options: .literal, range: nil)
            
            let urlAvatar = NSURL(string: newUrlString)!
            if let data = NSData(contentsOf: urlAvatar as URL) {
                avatarImageView.image = UIImage(data: data as Data)
            }
        }
    }

    

}
