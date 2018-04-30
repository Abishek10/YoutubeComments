//
//  CommentViewController.swift
//  YoutubeComments
//
//  Created by Abishek on 4/29/18.
//  Copyright © 2018 Abishek. All rights reserved.
//

import Foundation
import UIKit

fileprivate struct Segues {
    static let PostCommentsVC = "Comments2PostComments"
}

class CommentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    
    @IBOutlet var commentButton: UIButton!
    @IBOutlet var comment: UITextView!
    @IBOutlet var addCommentButton: UIButton!
    @IBOutlet var tableView: UITableView!

    var comments: [String] = [String]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    let color = UIColor(red: 0.35, green: 0.55, blue: 0.86, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)

        tableView.estimatedRowHeight = 75.0
        
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    override func viewDidLayoutSubviews() {
        commentButton.layer.cornerRadius = 5
        commentButton.clipsToBounds = true

        comment.layer.cornerRadius = 5
        comment.clipsToBounds = true

        addCommentButton.layer.cornerRadius = 5
        addCommentButton.clipsToBounds = true
        
        comment.layer.borderWidth = 1
        comment.layer.borderColor = color.cgColor

        tableView.layer.borderColor = color.cgColor
        tableView.layer.borderWidth = 1

        tableView.layer.cornerRadius = 5
        tableView.clipsToBounds = true
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as? CommentTableViewCell  {
            let comment = comments[indexPath.row]
            cell.setDisplay(withCommentText: comment)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    @IBAction func postComments(_ sender: Any) {
        performSegue(withIdentifier: Segues.PostCommentsVC, sender: self)
    }
    @IBAction func addComment(_ sender: Any) {
        if (comment.text.count == 0) {
            return
        }

        let commentText = comment.text
        comments.append(commentText!)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let postCommentsVC = segue.destination as? PostCommentsViewController {
            postCommentsVC.comments = comments
        }
    }
}
