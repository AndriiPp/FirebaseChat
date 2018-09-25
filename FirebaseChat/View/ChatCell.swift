//
//  ChatCell.swift
//  FirebaseChat
//
//  Created by Andrii Pyvovarov on 21.08.18.
//  Copyright © 2018 Andrii Pyvovarov. All rights reserved.
//

import UIKit
import AVFoundation

class ChatCell: UICollectionViewCell {
    var message : Message?
    var chatController : ChatController?
    let textView : UITextView = {
       let text = UITextView()
        text.text = "daffffffffi"
        text.translatesAutoresizingMaskIntoConstraints = false
        text.font = UIFont.systemFont(ofSize: 16)
        text.backgroundColor = UIColor.clear
        text.textColor = UIColor.white
        text.isEditable = false
//        text.backgroundColor = UIColor.yellow
        return text
    }()
    var bubleViewRightAnchor : NSLayoutConstraint?
    var bubleViewLeftAnchor : NSLayoutConstraint?
     var bubleWidthAnchor : NSLayoutConstraint?
    static let blueColor = UIColor(r: 0, g: 137, b: 249)
    
    let activityIndicator : UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        return aiv
    }()
    lazy var playButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "play")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        return button
    }()
    var layerPlayer : AVPlayerLayer?
    var player : AVPlayer?
    @objc func handlePlay(){
        if let videoUrlString = message?.videoUrl, let url = URL(string: videoUrlString) {
            player = AVPlayer(url: url)
            layerPlayer = AVPlayerLayer(player: player)
            layerPlayer?.frame = bubleView.bounds
            bubleView.layer.addSublayer(layerPlayer!)
            player?.play()
            activityIndicator.startAnimating()
            playButton.isHidden  = true
            
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        layerPlayer?.removeFromSuperlayer()
        player?.pause()
        activityIndicator.stopAnimating()
    }
    let bubleView : UIView = {
        let view = UIView()
        view.backgroundColor = blueColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
   let profileImageView : UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(named: "2")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    lazy var messageImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoom)))
        return imageView
    }()
    @objc func handleZoom(tapGesture : UITapGestureRecognizer){
        if message?.videoUrl != nil {
            return
        }
        if let imageView = tapGesture.view as? UIImageView{
            self.chatController?.performZoom(imageView: imageView)
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bubleView)
       addSubview(textView)
        addSubview(profileImageView)
        bubleView.addSubview(messageImageView)
        
        messageImageView.leftAnchor.constraint(equalTo: bubleView.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubleView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: bubleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubleView.heightAnchor).isActive = true
        
        bubleView.addSubview(playButton)
        playButton.centerXAnchor.constraint(equalTo: bubleView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: bubleView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        bubleView.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: bubleView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: bubleView.centerYAnchor).isActive = true
        activityIndicator.widthAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicator.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 8).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        bubleViewRightAnchor = bubleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant : -8)
            bubleViewRightAnchor?.isActive = true
        bubleViewLeftAnchor = bubleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
//        bubleViewLeftAnchor?.isActive = false
        bubleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubleWidthAnchor  = bubleView.widthAnchor.constraint(equalToConstant: 200)
            bubleWidthAnchor?.isActive = true
        bubleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true

//        textView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: bubleView.rightAnchor).isActive = true
//        textView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        textView.leftAnchor.constraint(equalTo: bubleView.leftAnchor, constant: 8).isActive = true
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
