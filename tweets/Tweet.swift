//
//  Tweet.swift
//  tweets
//
//  Created by Гриша on 03.02.17.
//  Copyright © 2017 ru.sapgv. All rights reserved.
//

import Foundation


class Tweet {

    var id: String
    var date: Date? = nil
    var name: String? = nil
    var avatarUrl: String? = nil
    var text: String? = nil

    init(id: String, text: String) {
        self.id = id
        self.text = text
    }
}
