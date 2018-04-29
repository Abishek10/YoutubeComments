//
//  CommentViewController.swift
//  YoutubeComments
//
//  Created by Abishek on 4/29/18.
//  Copyright © 2018 Abishek. All rights reserved.
//

import Foundation
import UIKit

class CommentViewController: UIViewController {
    
    @IBOutlet var commentButton: UIButton!
    @IBOutlet var comment: UITextView!

    let color = UIColor(red: 0.35, green: 0.55, blue: 0.86, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    override func viewDidLayoutSubviews() {
        commentButton.layer.cornerRadius = 5
        commentButton.clipsToBounds = true

        comment.layer.cornerRadius = 5
        comment.clipsToBounds = true
        
        comment.layer.borderWidth = 1
        comment.layer.borderColor = color.cgColor
    }
}
