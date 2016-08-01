//
//  GitHubRepo.swift
//  GitHubOAuth
//
//  Created by Joel Bell on 7/27/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation
import SwiftyJSON


class Repo {
    
    var id: String
    var name: String
    var fullName: String
    var htmlURL: String
    
    init?(json: JSON) {
        guard let
            id = json["id"].int,
            name = json["name"].string,
            fullName = json["full_name"].string,
            htmlURL = json["html_url"].string
            else { return nil }
        
        self.id = String(id)
        self.name = name
        self.fullName = fullName
        self.htmlURL = htmlURL
    }
    
}
