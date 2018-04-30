//
//  CommentTableViewCell.swift
//  YoutubeComments
//
//  Created by Abishek on 4/30/18.
//  Copyright © 2018 Abishek. All rights reserved.
//

import UIKit
class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet var comment: UILabel!

    func setDisplay(withCommentText commentText: String) {
        comment.text = commentText
    }
}
