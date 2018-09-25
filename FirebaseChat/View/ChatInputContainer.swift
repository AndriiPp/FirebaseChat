//
//  ChatInputContainer.swift
//  FirebaseChat
//
//  Created by Andrii Pyvovarov on 30.08.18.
//  Copyright © 2018 Andrii Pyvovarov. All rights reserved.
//

import UIKit

class ChatInputContainer: UIView, UITextFieldDelegate {
     let sendButton = UIButton(type : .system)
    let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(named: "3")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    var chatController : ChatController?{
        didSet {
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: chatController, action: #selector(ChatController.handleUploadImage)))
            sendButton.addTarget(chatController, action: #selector(ChatController.handleSend), for: .touchUpInside)
        }
    }
    
    lazy var inputTextField : UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        addSubview(imageView)
        
        imageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        sendButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        
        addSubview(self.inputTextField)
        
        self.inputTextField.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 8).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo:heightAnchor).isActive = true
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorView)
        
        separatorView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separatorView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        separatorView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        chatController?.handleSend()
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
