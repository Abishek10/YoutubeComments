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
import DropDown
import SwiftyJSON

struct Video {
    let videoId: String
    let channelId: String
    
    init (withVideoId videoId: String, withChannelId channelId: String) {
        self.videoId = videoId
        self.channelId = channelId
    }
}

fileprivate struct Strings {
    static let SuccessTitle = "Success"
    static let ErrorTitle = "Error"
    static let SuccessMessage = "Successfully retrieved videos"
    static let PostCommentsSuccessMessage = "Successfully Posted Comment"
    static let OkTitle = "Ok"
}

class PostCommentsViewController: UIViewController {
    
    
    @IBOutlet var timeInterval: UITextField!
    @IBOutlet var orderBy: UIButton!
    @IBOutlet var postCommentsButton: UIButton!
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var searchText: UITextField!
    @IBOutlet var videosCount: UITextField!
    @IBOutlet var commentLabel: UILabel!
    @IBOutlet var videoLabel: UILabel!

    var comments: [String] = [String]()
    var videos: [Video] = [Video]()
    var timer : Timer?
    var userIndex = 0
    var videoIndex = 0
    let dropDown = DropDown()
    
    let color = UIColor(red: 0.35, green: 0.55, blue: 0.86, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)

        customizeDropDown(self)
        setupDropDown()

        dropDown.dismissMode = .onTap
        dropDown.direction = .any
    }


    func customizeDropDown(_ sender: AnyObject) {
        let appearance = DropDown.appearance()
        
        appearance.cellHeight = 60
        appearance.backgroundColor = UIColor(white: 1, alpha: 1)
        appearance.selectionBackgroundColor = UIColor(red: 0.6494, green: 0.8155, blue: 1.0, alpha: 0.2)
        appearance.cornerRadius = 10
        appearance.animationduration = 0.25
        appearance.textColor = .darkGray
    }
    
    @IBAction func orderVideos(_ sender: Any) {
        dropDown.show()
    }

    func setupDropDown() {
        dropDown.anchorView = orderBy
        dropDown.dataSource = ["date",
                               "relevance",
                               ]
        
        dropDown.bottomOffset = CGPoint(x: 0, y: orderBy.bounds.height)
        
        // Action triggered on selection
        dropDown.selectionAction = { [unowned self] (index, item) in
            self.orderBy.setTitle(item, for: .normal)
            self.orderBy.setTitleColor(UIColor.black, for: .normal)
        }
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func search(_ sender: Any) {
        if (searchText.text?.count == 0) {
            return
        }

        if (orderBy.titleLabel?.text == "Order By") {
            return
        }
        
        var maxResults = 50
        
        if (videosCount.text?.count != 0) {
            maxResults = Int(videosCount.text!)!
        }

        let keyword = searchText.text!


        let type = "video"
        let part = "snippet"
        let order =  orderBy.titleLabel?.text!
        
        let url = URL(string: GlobalConstants.URLS.search)!
        var get_data: [String: Any] = [String: Any]()
        
        get_data["type"] = type
        get_data["maxResults"] = maxResults
        get_data["part"] = part
        get_data["q"] = keyword
        get_data["key"] = GlobalConstants.API_KEY
        get_data["order"] = order
        

        Alamofire.request(url, method: .get, parameters: get_data, encoding: URLEncoding.default, headers: nil).validate(statusCode: 200..<300).validate(contentType: ["application/json"]).responseJSON { response in

            switch response.result {
            case .success(let value):
                let json = JSON(value)
                self.parseJSON(json: json)
                break
            case .failure(let error):
                print(error)
                self.showAlert(withTitle: Strings.ErrorTitle, withMessage: error.localizedDescription)
                break
            }
        }
    }

    @objc func postComment() {
        let x = OauthManager.sharedInstance.authenticatedUsers[userIndex]
        let y = videos[videoIndex]
        let part = "snippet"
        let totalComments = comments.count

        let urlString = GlobalConstants.URLS.comment + "?part=\(part)&key=\(GlobalConstants.API_KEY)&access_token=\(x.accessToken)"
        let url = URL(string: urlString)!
        
        let videoId = y.videoId
        let channelId = y.channelId
        let random = Int(arc4random_uniform(UInt32(totalComments)))
        let comment = comments[random]
            
        let parameters : Parameters = [
            "snippet" : [
                "channelId" : channelId,
                "topLevelComment" : [
                    "snippet" : [
                        "textOriginal" : comment
                    ]
                ],
                "videoId" : videoId
            ]
        ]
            
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200..<300).validate(contentType: ["application/json"]).responseJSON { response in
                
            switch response.result {
            case .success(let value):
                break
            case .failure(let error):
                print(error)
                self.showAlert(withTitle: Strings.ErrorTitle, withMessage: error.localizedDescription)
                return
            }
        }

        let commentNumber = Int(commentLabel.text!)!
        commentLabel.text = String(commentNumber + 1)

        videoIndex += 1
        if (videoIndex == 20 || videoIndex == videos.count) {
            videoIndex = 0
            userIndex += 1
            
            if (userIndex == OauthManager.sharedInstance.authenticatedUsers.count) {
                userIndex = 0
                timer?.invalidate()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }

    @IBAction func postComments(_ sender: Any) {
        if (comments.count == 0) {
            return
        }

        if (videos.count == 0) {
            return
        }

        let authenticatedUsers = OauthManager.sharedInstance.authenticatedUsers
        
        if (authenticatedUsers.count == 0) {
            return
        }

        if (timeInterval.text?.count == 0) {
            return
        }

        view.endEditing(true)

        commentLabel.text = "0"

        let interval = Int(timeInterval.text!)!

        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        timer = Timer.scheduledTimer(timeInterval: TimeInterval(interval), target: self, selector: #selector(postComment), userInfo: nil, repeats: true)
    }

    func parseJSON(json: JSON) {
        let items = json["items"].arrayValue
        for x in items {
            print(x)
            let videoId = x["id"]["videoId"].stringValue
            let channelId = x["snippet"]["channelId"].stringValue
            let video = Video(withVideoId: videoId, withChannelId: channelId)
            videos.append(video)
        }

        videoLabel.text = String(videos.count)
    }
    
    override func viewDidLayoutSubviews() {
        searchText.layer.borderWidth = 1
        searchText.layer.borderColor = color.cgColor
        searchText.layer.cornerRadius = 5
        searchText.clipsToBounds = true

        timeInterval.layer.borderColor = color.cgColor
        timeInterval.layer.borderWidth = 1
        timeInterval.layer.cornerRadius = 5
        timeInterval.clipsToBounds = true

        orderBy.layer.cornerRadius = 5
        orderBy.clipsToBounds = true
        orderBy.layer.borderColor = color.cgColor
        orderBy.layer.borderWidth = 1
        
        searchButton.layer.cornerRadius = 5
        searchButton.clipsToBounds = true

        videosCount.layer.cornerRadius = 5
        videosCount.clipsToBounds = true
        videosCount.layer.borderColor = color.cgColor
        videosCount.layer.borderWidth = 1

        postCommentsButton.layer.cornerRadius = 5
        postCommentsButton.clipsToBounds = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        timer?.invalidate()
    }
    
    func showAlert(withTitle title: String, withMessage message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.modalPresentationStyle = .popover
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.sourceRect = self.view.frame
    
        let ok = UIAlertAction(title: Strings.OkTitle, style: .default, handler: nil)
        alertController.addAction(ok)
        
        present(alertController, animated: true, completion: nil)
        
    }
}
