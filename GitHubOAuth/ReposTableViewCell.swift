//
//  ReposTableViewCell.swift
//  GitHubOAuth
//
//  Created by Joel Bell on 7/28/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit

class ReposTableViewCell: UITableViewCell {
    
    let store = ReposDataStore.sharedInstance
    var starButton: UIButton!
    var repo: Repo? {
        
        didSet {
            if let name = repo?.name {
                updateTextLabelWith(name)
            }
            if let repo = repo {
                checkStarredStatusOf(repo)
            }
        }
        
    }
    
    // MARK: Initialization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
        
    }
    
    private func commonInit() {
        
        self.selectionStyle = .None
        
        self.starButton = UIButton()
        self.starButton.hidden = true
        self.starButton.alpha = 0
        self.starButton.addTarget(self, action: #selector(starButtonPressed(_:)), forControlEvents: .TouchUpInside)
        self.addSubview(starButton)
        
        self.starButton.translatesAutoresizingMaskIntoConstraints = false
        self.starButton.heightAnchor.constraintEqualToAnchor(self.heightAnchor, multiplier: 0.5).active = true
        self.starButton.widthAnchor.constraintEqualToAnchor(self.heightAnchor, multiplier: 0.5).active = true
        self.starButton.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor, constant: -20).active = true
        self.starButton.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor).active = true
        
    }
    
    // MARK: Button action
    func starButtonPressed(sender: UIButton) {
        
        self.starButton.userInteractionEnabled = false
        self.starButton.selected = true
        
        
        if let repo = self.repo {
            
            store.toggleStarStatusFor(repo: repo, toggleCompletion: { isStarred in
                
                guard let isStarred = isStarred else {
                    self.setImagesForError(self.starButton)
                    self.starButton.selected = false
                    return
                }
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ 
                    if isStarred {
                        self.setImagesForStarred(self.starButton)
                    } else {
                        self.setImagesForUnstarred(self.starButton)
                    }
                    self.starButton.selected = false
                    self.starButton.userInteractionEnabled = true
                })
                
            })
            
        }
        
    }
    
    // MARK: Repo dependencies
    private func updateTextLabelWith(text: String) {
        self.textLabel?.text = text
    }
    
    private func checkStarredStatusOf(repo: Repo) {
        
        GitHubAPIClient.checkIfRepositoryIsStarred(repo.fullName, completionHandler: { isStarred in
            
            if let isStarred = isStarred {
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ 
                    self.starButton.hidden = false
                    
                    if isStarred {
                        self.setImagesForStarred(self.starButton)
                        UIView.animateWithDuration(0.5, animations: {
                            self.starButton.alpha = 1
                        })
                    } else {
                        self.setImagesForUnstarred(self.starButton)
                        UIView.animateWithDuration(0.5, animations: {
                            self.starButton.alpha = 1
                        })
                    }
                })
                
            }
            
        })
        
    }
    
    // MARK: Button image handling
    private func setImagesForStarred(button: UIButton) {
        self.starButton.setImage(UIImage(named: "starred"), forState: .Normal)
        self.starButton.setImage(UIImage(named: "starredSelected"), forState: .Selected)
    }
    
    private func setImagesForUnstarred(button: UIButton) {
        self.starButton.setImage(UIImage(named: "unstarred"), forState: .Normal)
        self.starButton.setImage(UIImage(named: "unstarredSelected"), forState: .Selected)
    }
    
    private func setImagesForError(button: UIButton) {
        self.starButton.setImage(UIImage(named: "error"), forState: .Normal)
        self.starButton.setImage(UIImage(named: "error"), forState: .Selected)
    }
}

