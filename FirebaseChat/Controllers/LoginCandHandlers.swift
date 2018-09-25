//
//  LoginCandHandlers.swift
//  FirebaseChat
//
//  Created by Andrii Pyvovarov on 10.08.18.
//  Copyright © 2018 Andrii Pyvovarov. All rights reserved.
//

import UIKit
import Firebase

extension LoginC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func Register() {
        guard let email = emailText.text, let password = passwordText.text, let name = nameText.text else {
            print("Form is not valid")
            return
        }
     
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            //successfully authenticated user
            let imageName = NSUUID().uuidString
            let storageR = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
            if let profileImage = self.imageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1){
                storageR.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    
                    if let error = error {
                        print(error)
                        return
                    }
                    
                    if let imageUrl = metadata?.downloadURL()?.absoluteString {
                        
                        let values = ["name": name, "email": email, "imageUrl": imageUrl]
                        
                        self.registerUserIntoDatabase(uid, values: values as [String : AnyObject])
                    }
                })
            }
        })
    }
    
    fileprivate func registerUserIntoDatabase(_ uid: String, values: [String: AnyObject]) {
        let ref = Database.database().reference()
        let usersReference = ref.child("users").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if let err = err {
                print(err)
                return
            }
//            self.MessagesC?.navigationItem.title = values["users"] as? String
//            self.MessagesC?.navBarTitle
            let user = User(dictionary: values)
            self.MessagesC?.setupNavBarWithUser(user: user )
            self.dismiss(animated: true, completion: nil)
        })
    }
    
 @objc   func selectImageView() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            imageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    
}

