//
//  ViewController.swift
//  YoutubeComments
//
//  Created by Abishek on 4/28/18.
//  Copyright © 2018 Abishek. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 5
        loginButton.clipsToBounds = true
        
        OauthManager.sharedInstance.signinAllUsersSilently {
            self.tableView.reloadData()
        }
    }
    
    @IBAction func login(_ sender: Any) {
        OauthManager.sharedInstance.signin(controller: self) { (success, user, error) in
            print(success)
            print(user?.email)
            print(user?.accessToken)
            print(error)
            self.tableView.reloadData()
        }
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

