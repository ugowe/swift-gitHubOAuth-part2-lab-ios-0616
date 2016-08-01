//
//  ReposDataStore.swift
//  GitHubOAuth
//
//  Created by Joel Bell on 7/31/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
import SwiftyJSON

class ReposDataStore {
    
    static let sharedInstance = ReposDataStore()
    private init() {}
    
    var repositories:[Repo] = []
    
    func getRepositoriesWithCompletion(completion: (Bool) -> ()) {
        
        GitHubAPIClient.getRepositoriesWithCompletion { json in
    
            guard let json = json else {
                print("ERROR: JSON data was not received by data store")
                completion(false)
                return
            }
            
            for (_, object) in json {
                
                let repo = Repo(json: object)
                if let repoForArray = repo {
                    self.repositories.append(repoForArray)
                }
                
            }
            completion(true)
            
        }
    
    }
    
    func toggleStarStatusFor(repo repo: Repo, toggleCompletion: (Bool?) -> ()) {
        
        GitHubAPIClient.checkIfRepositoryIsStarred(repo.fullName) { isStarred in
            
            guard let isStarred = isStarred else {
                print("ERROR: Unable to check if repository is starred")
                toggleCompletion(nil)
                return
            }
            
            if isStarred {
                
                GitHubAPIClient.unStarRepository(repo.fullName, completionHandler: { success in
                    
                    if success {
                        toggleCompletion(false)
                    } else {
                        toggleCompletion(nil)
                    }
                    
                })
                
            } else {
                
                GitHubAPIClient.starRepository(repo.fullName, completionHandler: { success in
                    
                    if success {
                        toggleCompletion(true)
                    } else {
                        toggleCompletion(nil)
                    }
                    
                })
                
            }
            
        }
        
    }

}
