//
//  ViewController.swift
//  FirebaseChat
//
//  Created by Andrii Pyvovarov on 29.06.18.
//  Copyright © 2018 Andrii Pyvovarov. All rights reserved.
//

import UIKit
import Firebase

class messagesC: UITableViewController {
    
    let cellId = "cellId"
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self , action: #selector(handleLogout))
        let image = UIImage(named: "ff")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(newMessage))
        ifLoggedIn()
        tableView.register(UCell.self, forCellReuseIdentifier: cellId)
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let message = messages[indexPath.row]
        if let chatPartnerId = message.chatPartnerId(){
            Database.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue(completionBlock: { (err, ref) in
                if err != nil {
                    print("Failed to delete message : ", err)
                    return
                }
                self.messagesDictionary.removeValue(forKey: chatPartnerId)
                self.attemptReloadOfTable()
//                self.messages.remove(at: indexPath.row)
//                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            })
        }
    }
    var messages = [Message]()
    var messagesDictionary = [String : Message]()
    func observeUserMessages(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            let userId = snapshot.key
            Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                let messageId = snapshot.key
                self.fetchMessageandMessageId(messageId: messageId)
          }, withCancel: nil)
        }, withCancel: nil)
        ref.observe(.childRemoved, with: { (snapshot) in
//            print(snapshot.key)
//            print(self.messagesDictionary)
            self.messagesDictionary.removeValue(forKey: snapshot.key)
            self.attemptReloadOfTable()
        }, withCancel: nil)
    }
        private func fetchMessageandMessageId(messageId : String){
            let messagesRefer = Database.database().reference().child("messages").child(messageId)
            messagesRefer.observe(.value, with: { (snapshot) in
                //                print(snapshot)
                if let dictionary = snapshot.value as? [String : AnyObject]{
                    let message = Message(dictionary: dictionary)
                    //                message.setValuesForKeys(dictionary)
                    //                print(message.text)
                                   self.messages.append(message)
                    if let chatPartnerId = message.chatPartnerId(){
                        self.messagesDictionary[chatPartnerId] = message
                        self.messages = Array(self.messagesDictionary.values)
                        self.messages.sort(by: { (message1, message2) -> Bool in
                            return message1.timestamp!.int32Value > message2.timestamp!.int32Value
                        })
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }, withCancel: nil)
        }
    var timer : Timer?
    func observeMessages(){
        let ref = Database.database().reference().child("messages")
        ref.observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject]{
               let message = Message(dictionary: dictionary)
                if let toId = message.toId{
                 self.messagesDictionary[toId] = message
                }
                self.attemptReloadOfTable()
                }
        }, withCancel: nil)
    }
   private func attemptReloadOfTable(){
    
    self.timer?.invalidate()
    self.timer =  Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    @objc func handleReloadTable(){
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            return message1.timestamp!.int32Value > message2.timestamp!.int32Value
        })
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UCell
        let message = messages[indexPath.row]
        cell.message = message
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observe(.value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String : AnyObject] else {
                return
            }
            let user = User(dictionary: dictionary)
            user.id = chatPartnerId
            self.showChat(user: user)
        }, withCancel: nil)
//        print(message.text, message.toId, message.fromId)
    }
    func ifLoggedIn(){
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            //            handleLogout()
            //            Invokes a method of the receiver on the current thread using the default mode after a delay.
        }  else {
            navBarTitle()
        }
    }
    
    func navBarTitle(){
        guard  let uid = Auth.auth().currentUser?.uid else {
            return
        }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                let user = User(dictionary: dictionary)
                self.setupNavBarWithUser(user: user)
            }
        }, withCancel: nil)
    }
    @objc func newMessage(){
        let NewMessageC = newMessageC()
        NewMessageC.MessagesC = self
        let navC = UINavigationController(rootViewController: NewMessageC)
        present(navC, animated: true, completion: nil)
        
    }
    func setupNavBarWithUser(user : User){
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        observeUserMessages()
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)

        let containerView = UIView()
        titleView.addSubview(containerView)
        self.navigationItem.titleView = titleView
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let profileImage = UIImageView()
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        profileImage.contentMode = .scaleAspectFill
        profileImage.layer.cornerRadius = 7
        profileImage.clipsToBounds = true
        if let profileImageUrl = user.imageUrl{
            profileImage.loadImageUsingCashe(urlString: profileImageUrl)
        }
        containerView.addSubview(profileImage)

        profileImage.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 40).isActive = true

        let nameLabel = UILabel()
        containerView.addSubview(nameLabel)
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leftAnchor.constraint(equalTo: profileImage.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImage.heightAnchor).isActive = true

        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
    }
    @objc func showChat(user : User){
        let chatController = ChatController(collectionViewLayout: UICollectionViewFlowLayout())
        chatController.user = user
        navigationController?.pushViewController(chatController, animated: true)
    }
   @objc func handleLogout(){
        let loginC = LoginC()
    loginC.MessagesC = self
    do {
        try Auth.auth().signOut()
    } catch let  logout {
        print(logout)
    }
    //The view controller to display over the current view controller’s content.
        present(loginC, animated: true, completion: nil)
    }

}

