//
//  UCell.swift
//  FirebaseChat
//
//  Created by Andrii Pyvovarov on 19.08.18.
//  Copyright © 2018 Andrii Pyvovarov. All rights reserved.
//

import UIKit
import Firebase
class UCell : UITableViewCell {
    var message : Message? {
        didSet {
           setupNameAndImage()
            //         cell.textLabel?.text = message.toId
            detailTextLabel?.text = message?.text
            if let seconds = message?.timestamp?.doubleValue{
                let timestampDate = Date(timeIntervalSince1970: seconds)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat  = "hh:mm:ss a"
                timeLabel.text = dateFormatter.string(from: timestampDate)
            }
        }
    }
    private func setupNameAndImage(){

        if let id = message?.chatPartnerId()  {
            let ref = Database.database().reference().child("users").child(id)
            ref.observe(.value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String : AnyObject]{
                    // possible error!!!!!!!!!!!!!!!!!!!!!!!
                    //                    DispatchQueue.main.async {
                    self.textLabel?.text = dictionary["name"] as? String
                    if let profileImageUrl = dictionary["imageUrl"]  as? String{
                        self.profileImageView.loadImageUsingCashe(urlString: profileImageUrl)
                    }
                    //                    }
                }
                //                print(snapshot)
            }, withCancel: nil)
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y-2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y+2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    let profileImageView: UIImageView = {
        let imageV = UIImageView()
//        imageV.image = UIImage(named: "2")
        imageV.translatesAutoresizingMaskIntoConstraints = false
        imageV.layer.cornerRadius = 10
        imageV.layer.masksToBounds = true
        imageV.contentMode = .scaleAspectFill
        return imageV
    }()
    let timeLabel : UILabel = {
       let label = UILabel()
//        label.text  = "HH:MM:SS"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileImageView)
        addSubview(timeLabel)
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: textLabel!.heightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

