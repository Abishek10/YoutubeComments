//
//  PostCommentsViewController.swift
//  YoutubeComments
//
//  Created by Abishek on 4/30/18.
//  Copyright © 2018 Abishek. All rights reserved.
//

import Foundation
import UIKit

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
