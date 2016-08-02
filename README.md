# GitHub OAuth - Part II

## Objectives

 * Finish setting up the OAuth2 protocol to access a user's GitHub account

### 1. Add files to project
---
 * Add the following five files to this project from your completed version of the part one lab:
  * AppDelegate.swift
  * GitHubAPIClient.swift
  * Info.plist
  * LoginViewController.swift
  * Secrets.swift

![Copy Files Image](https://s3.amazonaws.com/learn-verified/gitHubOAuth-lab-copy-files.png)

### 2. Add OAuth methods to GitHubAPIClient
---
 * Add the following methods to the GitHubAPIClient extension marked "OAuth"

 ```swift
 // Start access token request process
 class func startAccessTokenRequest(url url: NSURL, completionHandler: (Bool) -> ()) {

 }

 // Save access token from request response to keychain
 private class func saveAccess(token token: String, completionHandler: (Bool) -> ()) {

 }

 // Get access token from keychain      
 private class func getAccessToken() -> String? {

         return nil

 }

 // Delete access token from keychain
 class func deleteAccessToken(completionHandler: (Bool) -> ()) {

 }
 ```

### 3. Set up access token request
---
At the end of the last lab you received a temporary code back from GitHub. You are going to use that code to make a request to GitHub for the access token.
 * Inside the `safariLogin(_:)` method of the `LoginViewController`, call the `startAccessTokenRequest(url:completionHandler:)` method from the `GitHubAPIClient`.
 * Pass the URL received back from GitHub to the url parameter of the `startAccessTokenRequest(url:completionHandler:)` method.
  * *Hint:* Remember the notification argument passed in from `safariLogin(_:)` has the url stored in the object property.
 * Head over to the `GitHubAPIClient` class to define the `startAccessTokenRequest(url:completionHandler:)` method.
  * Use this order of tasks to define the method:
    * Use the `NSURL` extension from the `Extensions` file to extract the code.
    * Build your parameter dictionary for the request.
      * "client_id": *your client id*
      * "client_secret": *your client secret*
      * "code": *temporary code from GitHub*
    * Build your headers dictionary to receive JSON data back.
      * "Accept": "application/json"
    * Use `request(_:_:parameters:encoding:headers:)` from [Alamofire](http://cocoadocs.org/docsets/Alamofire/3.4.1/Functions.html#/s:F9Alamofire7requestFTOS_6MethodPS_20URLStringConvertible_10parametersGSqGVs10DictionarySSPs9AnyObject___8encodingOS_17ParameterEncoding7headersGSqGS2_SSSS___CS_7Request) to make a POST request using the `.token` string from the `URLRouter`, the parameter dictionary, and the header dictionary.
    * If the request is successful, print response and call `completionHandler(true)`, else `completionHandler(false)`.
 * Run the application to see if you are getting a successful response.

### 4. Save the access token to the keychain
---
 * Use `SwiftyJSON` to get the access token from the response you were working with in the previous step.
 * Call `saveAccess(token:completionHandler:)` to pass the access token you retrieved from the JSON data.
 * Define the `saveAccess(token:completionHandler:)` method using the [Locksmith](http://cocoadocs.org/docsets/Locksmith/2.0.8/) pod. Use the method, `try Locksmith.saveData(["some key": "some value"], forUserAccount: "myUserAccount")`.
   * Key is "access token". Value is "*token from response*". User account is "github".
   * The `completionHandler` should callback with true or false depending on whether the access token is successfully saved.
 * Back inside the response section of the `startAccessTokenRequest(url:completionHandler:)` method, update the order of events to be:
   * Receive response
   * Serialize JSON data using SwiftyJSON
   * Call `saveAccess(token:completionHandler:)` method
   * If save succeeded, call the completion handler of `startAccessTokenRequest(url:completionHandler:)` with the appropriate response.
   * Run the application using print statements accordingly to see that everything is working correctly.

### 5. Define the `getAccessToken()` method
---
 * Use the Locksmith method, `Locksmith.loadDataForUserAccount()` to retrieve the access token and return it.
 * Update the `starred(repoName:)` static function defined in the `URLRouter` enum.
   * `starredURL` needs to be combined with the access token for user account requests.
 * Update the `hasToken()` method to check if there is a token saved.
   * Use `getAccessToken()` to determine whether the method should return `true` or `false`.
 * Reset the simulator and run the application. At this point you should be able to log in again. Stop the application. Run it again and you should be directed to the table view controller containing a list of repositories.

## Bonus Challenge
Resetting the simulator and rerunning the application will indicate if everything is working correctly but it's not ideal. There are a few more pieces to this puzzle that can make it complete. Here's what's left:

 * Login
    * The `LoginViewController` starts the login process **BUT** the `AppController` doesn't know about the outcome of the process. That means it doesn't know whether it should display the table view controller or not. `startAccessTokenRequest(url:completionHandler:)` is called inside the `LoginViewController` with a callback about whether the process succeeded. If it succeeds, post a notification using the appropriate `Notification` name. The `AppController` already has the observer set up.

 * Logout
   * The `ReposTableViewController` has an IBAction for the log out button. This method needs to call `deleteAccessToken(_:)` from `GitHubAPIClient` and use the completion handler to determine whether to post a notification to the `AppController` to close the table view controller. `deleteAccessToken` still needs to be defined. It should delete the token and call back with the outcome.
