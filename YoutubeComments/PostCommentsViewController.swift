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
    
    
    @IBOutlet var postCommentsButton: UIButton!
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var searchText: UITextField!
    @IBOutlet var videosCount: UITextField!
    
    var comments: [String] = [String]()
    var videos: [Video] = [Video]()
    var timer : Timer?
    var userIndex = 0
    var videoIndex = 0
    
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
        
        var maxResults = 100
        
        if (videosCount.text?.count != 0) {
            maxResults = Int(videosCount.text!)!
        }

        let keyword = searchText.text!


        let type = "video"
        let part = "snippet"
        let order = "date"
        
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
            case .success( _):
                self.showAlert(withTitle: Strings.SuccessTitle, withMessage: Strings.PostCommentsSuccessMessage)
                break
            case .failure(let error):
                print(error)
                self.showAlert(withTitle: Strings.ErrorTitle, withMessage: error.localizedDescription)
                break
            }
        }

        videoIndex += 1
        if (videoIndex == videos.count) {
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

        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        timer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(postComment), userInfo: nil, repeats: true)
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

        showAlert(withTitle: Strings.SuccessTitle, withMessage: Strings.SuccessMessage)
    }
    
    override func viewDidLayoutSubviews() {
        searchText.layer.borderWidth = 1
        searchText.layer.borderColor = color.cgColor
        searchText.layer.cornerRadius = 5
        searchText.clipsToBounds = true
        
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
