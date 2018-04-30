//
//  PostCommentsViewController.swift
//  YoutubeComments
//
//  Created by Abishek on 4/30/18.
//  Copyright © 2018 Abishek. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class PostCommentsViewController: UIViewController {
    
    
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var searchText: UITextField!

    var comments: [String] = [String]()
    
    let color = UIColor(red: 0.35, green: 0.55, blue: 0.86, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func search(_ sender: Any) {
        if (searchText.text?.count == 0) {
            return
        }
        
        let keyword = searchText.text!
        let maxResults = 5
        let type = "video"
        let part = "snippet"
        
        let url = URL(string: GlobalConstants.URLS.search)!
        var get_data: [String: Any] = [String: Any]()
        
        get_data["type"] = type
        get_data["maxResults"] = maxResults
        get_data["part"] = part
        get_data["q"] = keyword
        get_data["key"] = GlobalConstants.API_KEY
        

        Alamofire.request(url, method: .get, parameters: get_data, encoding: URLEncoding.default, headers: nil).responseJSON { response in
            
        }
    }

    override func viewDidLayoutSubviews() {
        searchText.layer.borderWidth = 2
        searchText.layer.borderColor = color.cgColor
        searchText.layer.cornerRadius = 5
        searchText.clipsToBounds = true
        
        searchButton.layer.cornerRadius = 5
        searchButton.clipsToBounds = true
    }
}
