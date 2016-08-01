//
//  Extensions.swift
//  GitHubOAuth
//
//  Created by Joel Bell on 7/31/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation

extension NSURL {
    
    func getQueryItemValue(named name: String) -> String? {
        
        let components = NSURLComponents(URL: self, resolvingAgainstBaseURL: false)
        let query = components?.queryItems
        return query?.filter({$0.name == name}).first?.value
        
    }
    
}
