//
//  GitHubAPIClient.swift
//  GitHubOAuth
//
//  Created by Joel Bell on 7/31/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Locksmith

class GitHubAPIClient {
    
    // MARK: Path Router
    enum URLRouter {
        static let repo = "https://api.github.com/repositories?client_id=\(Secrets.clientID)&client_secret=\(Secrets.clientSecret)"
        static let token = "https://github.com/login/oauth/access_token"
        static let oauth = "https://github.com/login/oauth/authorize?client_id=\(Secrets.clientID)&scope=repo"
        
        static func starred(repoName repo: String) -> String? {
            
            let starredURL = "https://api.github.com/user/starred/\(repo)?client_id=\(Secrets.clientID)&client_secret=\(Secrets.clientSecret)&access_token="
            
            // TO DO: Add access token to starredURL string and return
            if let token = GitHubAPIClient.getAccessToken() {
                return starredURL + token
            }
            
            return nil
        }
    }
    
}

// MARK: Repositories
extension GitHubAPIClient {
    
    class func getRepositoriesWithCompletion(completionHandler: (JSON?) -> Void) {
        
        Alamofire.request(.GET, URLRouter.repo)
            .validate()
            .responseJSON(completionHandler: { response in
                switch response.result {
                case .Success:
                    if let data = response.data {
                        completionHandler(JSON(data: data))
                    }
                case .Failure(let error):
                    print("ERROR: \(error.localizedDescription)")
                    completionHandler(nil)
                }
            })
    }
    
}


// MARK: OAuth
extension GitHubAPIClient {
    
    class func hasToken() -> Bool {
        
        return getAccessToken() != nil
    }
    
    // Start access token request process
    class func startAccessTokenRequest(url url: NSURL, completionHandler: (Bool) -> ()) {
        
        guard let code = url.getQueryItemValue(named: "code") else { fatalError("Unable to parse url") }
        
        let parameters = [
            "client_id" : Secrets.clientID,
            "client_secret" : Secrets.clientSecret,
            "code" : code
        ]
        
        let headers = ["Accept" : "application/json"]
        
        Alamofire.request(.POST, GitHubAPIClient.URLRouter.token, parameters: parameters, encoding: .URLEncodedInURL, headers: headers).validate().responseJSON { (response) in
            
            print("Received Response")
            switch response.result {
            case .Success:
                
                guard let value = response.result.value else {
                    print("Unable to unwrap the value")
                    return
                }
                
                let json = JSON(value)
                print("Serialized json")
                guard let token = json["access_token"].string else {
                    print("no token in json response!")
                    return
                }
                
                print("Saving token..")
                saveAccess(token: token, completionHandler: { (isSaved) in
                    if isSaved {
                        print("Successfully saved token")
                        completionHandler(true)
                    }
                    else {
                        print("Unable to save token")
                        completionHandler(false)
                    }
                })
                
                print(response.result.value)
            case .Failure(let error):
                completionHandler(false)
                print(error)
            }
        }
    }
    
    // Save access token from request response to keychain
    private class func saveAccess(token token: String, completionHandler: (Bool) -> ()) {
        do {
            try Locksmith.saveData(["access_token" : token], forUserAccount: "myUserAccount")
            completionHandler(true)
        }
        catch {
            print(error)
            completionHandler(false)
        }
    }
    
    // Get access token from keychain
    private class func getAccessToken() -> String? {
        
        guard let accountInfo = Locksmith.loadDataForUserAccount("myUserAccount") else { return nil }
        
        return accountInfo["access_token"] as? String
        
    }
    
    // Delete access token from keychain
    class func deleteAccessToken(completionHandler: (Bool) -> ()) {
        
    }
    
}


// MARK: Activity
extension GitHubAPIClient {
    
    class func checkIfRepositoryIsStarred(fullName: String, completionHandler: (Bool?) -> ()) {
        
        guard let urlString = URLRouter.starred(repoName: fullName) else {
            print("ERROR: Unable to get url path for starred status")
            completionHandler(nil)
            return
        }
        
        Alamofire.request(.GET, urlString)
            .validate(statusCode: 204...404)
            .responseString(completionHandler: { response in
                switch response.result {
                case .Success:
                    if response.response?.statusCode == 204 {
                        completionHandler(true)
                    } else if response.response?.statusCode == 404 {
                        completionHandler(false)
                    }
                case .Failure(let error):
                    print("ERROR: \(error.localizedDescription)")
                    completionHandler(nil)
                }
                
                
            })
        
    }
    
    class func starRepository(fullName: String, completionHandler: (Bool) -> ()) {
        
        guard let urlString = URLRouter.starred(repoName: fullName) else {
            print("ERROR: Unable to get url path for starred status")
            completionHandler(false)
            return
        }
        
        Alamofire.request(.PUT, urlString)
            .validate(statusCode: 204...204)
            .responseString(completionHandler: { response in
                switch response.result {
                case .Success:
                    completionHandler(true)
                case .Failure(let error):
                    print("ERROR: \(error.localizedDescription)")
                    completionHandler(false)
                }
            })
        
    }
    
    class func unStarRepository(fullName: String, completionHandler: (Bool) -> ()) {
        
        guard let urlString = URLRouter.starred(repoName: fullName) else {
            print("ERROR: Unable to get url path for starred status")
            completionHandler(false)
            return
        }
        
        Alamofire.request(.DELETE, urlString)
            .validate(statusCode: 204...204)
            .responseString(completionHandler: { response in
                switch response.result {
                case .Success:
                    completionHandler(true)
                case .Failure(let error):
                    print("ERROR: \(error.localizedDescription)")
                    completionHandler(false)
                }
            })
        
    }
    
}

