//
//  ViewController.swift
//  YoutubeComments
//
//  Created by Abishek on 4/28/18.
//  Copyright © 2018 Abishek. All rights reserved.
//

import UIKit

fileprivate struct Segues {
    static let CommentsVC = "Accounts2Comments"
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var commentButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    
        OauthManager.sharedInstance.signinAllUsersSilently {
            self.tableView.reloadData()
        }
    }

    override func viewDidLayoutSubviews() {
        loginButton.layer.cornerRadius = 5
        loginButton.clipsToBounds = true

        commentButton.layer.cornerRadius = 5
        commentButton.clipsToBounds = true
    }
    
    @IBAction func login(_ sender: Any) {
        OauthManager.sharedInstance.signin(controller: self) { (success, user, error) in
            self.tableView.reloadData()
        }
    }
    @IBAction func comment(_ sender: Any) {
        performSegue(withIdentifier: Segues.CommentsVC, sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? InfoTableViewCell {
            let authUser = OauthManager.sharedInstance.authenticatedUsers[indexPath.row]
            cell.setDisplay(user: authUser)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(OauthManager.sharedInstance.authenticatedUsers.count)
        return OauthManager.sharedInstance.authenticatedUsers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
}

