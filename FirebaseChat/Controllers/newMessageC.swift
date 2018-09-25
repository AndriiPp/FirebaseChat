//
//  newMessageC.swift
//  FirebaseChat
//
//  Created by Andrii Pyvovarov on 04.08.18.
//  Copyright © 2018 Andrii Pyvovarov. All rights reserved.
//

import UIKit
import Firebase
class newMessageC: UITableViewController {
    let cellId = "cellId"
    var users = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        tableView.register(UCell.self, forCellReuseIdentifier: cellId)
        fetchUser()
    } 
    func fetchUser() {
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)
                user.id = snapshot.key
                self.users.append(user)
                //this will crash because of background thread, so lets use dispatch_async to fix
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
            
        }, withCancel: nil)
    }
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UCell
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        if let imageUrl = user.imageUrl {
            cell.profileImageView.loadImageUsingCashe(urlString: imageUrl)
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    var MessagesC : messagesC?
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            print("dismiss completed")
            let user = self.users[indexPath.row]
            self.MessagesC?.showChat(user: user)
            
        }
    }
}



