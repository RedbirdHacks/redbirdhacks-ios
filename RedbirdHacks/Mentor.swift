//
//  Mentor.swift
//  RedbirdHacks
//
//  Created by Tallyn Turnbow on 4/12/15.
//  Copyright (c) 2015 Tallyn Turnbow. All rights reserved.
//

import Foundation

enum ContactMethod {
    case Twitter(NSURL)
    case Facebook(NSURL)
    case Email(String)
    case LinkedIn(NSURL)
    case Phone(Int)
}

struct Mentor {
    var name: String
    var specialty: String?
    var contacts: [ContactMethod]
    var description: String?
}
