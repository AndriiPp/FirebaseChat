//
//  ChatController.swift
//  FirebaseChat
//
//  Created by Andrii Pyvovarov on 15.08.18.
//  Copyright © 2018 Andrii Pyvovarov. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation
//import Foundation
class ChatController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let cellId = "cellId"
    var user : User? {
        didSet {
            navigationItem.title = user?.name
            observeMessage()
        }
    }
    var messages = [Message]()
    func observeMessage(){
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.id else {
            return
        }
        let userMessage = Database.database().reference().child("user-messages").child(uid).child(toId)
        userMessage.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageId)
            messageRef.observe(.value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String : AnyObject] else {
                    return
                }
                let message = Message(dictionary: dictionary)
                self.messages.append(message)
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                }
                
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = UIColor.white
        collectionView?.alwaysBounceVertical = true
        collectionView?.contentInset = UIEdgeInsetsMake(8, 0, 8, 0)
        collectionView?.register(ChatCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode  = .interactive
        setupKeyboards()
    }
    lazy var inputContainerView : ChatInputContainer = {
        let chatInputContainer = ChatInputContainer(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        chatInputContainer.chatController = self
        return chatInputContainer
    }()
    @objc  func handleUploadImage(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        present(imagePickerController , animated: true, completion: nil)
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        
    }
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL{
            handleVideoSelectedForUrl(url: videoUrl)
        } else {
            handleImageSelected(info: info as [String : AnyObject])
        }
        dismiss(animated: true, completion: nil)
    }
    private func handleVideoSelectedForUrl(url : URL){
        let filename = NSUUID().uuidString + ".mov"
        let uploadTask = Storage.storage().reference().child("message-movies").child(filename).putFile(from: url, metadata: nil, completion: { (metadata, error) in
            if error != nil {
                print("error upload video", error)
                return
            }
            if let videoUrl = metadata?.downloadURL()?.absoluteString{
                
                if let thubnaiImage = self.thumbnaiImageForFileUrl(fileUrl: url){
                    
                    self.uploadToFirebaseStorage(image: thubnaiImage, completion: { (imageUrl) in
                        let properties : [String : AnyObject] = [ "imageUrl" : imageUrl,"imageWidth" : thubnaiImage.size.width, "imageHeight" : thubnaiImage.size.height, "videoUrl" : videoUrl] as [String : AnyObject]
                        self.sendMessageWithProperties(properties: properties)
                    })
                }
            }
        })
        uploadTask.observe(.progress) { (snapshot) in
            if let completedUnitCount = snapshot.progress?.completedUnitCount{
                self.navigationItem.title = String(completedUnitCount)
            }
        }
        uploadTask.observe(.success) { (snapshot) in
            self.navigationItem.title = self.user?.name
        }
    }
    private func thumbnaiImageForFileUrl(fileUrl : URL) -> UIImage?{
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        do {
            
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
            
        } catch let err {
            print(err)
        }
        return nil
    }
    private func handleImageSelected(info : [String : AnyObject]){
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker {
            uploadToFirebaseStorage(image: selectedImage, completion: { (imageUrl) in
                 self.sendImageUrl(imageUrl: imageUrl, image : selectedImage )
            })
        }
    }
    fileprivate func uploadToFirebaseStorage(image : UIImage, completion: @escaping (_ imageUrl: String) -> ()){
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)
        if let uploadData = UIImageJPEGRepresentation(image, 0.2){
            ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print("Failed to upload image:",error)
                    return
                }
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    completion(imageUrl)
                }
            })
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
         dismiss(animated: true, completion: nil)
    }
    override var inputAccessoryView: UIView?{
        get {
            return inputContainerView
        }
    }
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    func setupKeyboards(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    @objc func handleKeyboardDidShow(){
        if messages.count > 0 {
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }
    @objc func handleKeyboardWillHide(notification : NSNotification){
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        //        print(keyboardFrame?.height)
        containerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    @objc func handleKeyboardWillShow(notification : NSNotification){
         let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        containerViewBottomAnchor?.constant = -keyboardFrame!.height
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatCell
        cell.chatController = self
        
        let message = messages[indexPath.item]
        cell.message = message
        cell.textView.text = message.text
       setupCell(cell: cell, message: message)
        if let text = message.text{
            cell.bubleWidthAnchor?.constant = estimateFrameOfText(text: text).width + 32
            cell.textView.isHidden  = false
        } else if message.imageUrl != nil {
            cell.bubleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }
        cell.playButton.isHidden = message.videoUrl == nil
        return cell
    }
    private func setupCell(cell : ChatCell, message : Message) {
        if let profileImageUrl = self.user?.imageUrl {
            cell.profileImageView.loadImageUsingCashe(urlString: profileImageUrl )
        }

        if message.fromId == Auth.auth().currentUser?.uid {
            cell.bubleView.backgroundColor = ChatCell.blueColor
            cell.textView.textColor = UIColor.white
//            cell.bubleWidthAnchor?.isActive = true
            cell.profileImageView.isHidden = true
            cell.bubleViewLeftAnchor?.isActive = false
            cell.bubleViewRightAnchor?.isActive = true
        } else {
            cell.bubleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = UIColor.black
            cell.bubleViewLeftAnchor?.isActive = true
            cell.bubleViewRightAnchor?.isActive = false
            cell.profileImageView.isHidden = false
        }
        if let imageMessageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCashe(urlString: imageMessageUrl)
            cell.messageImageView.isHidden = false
            cell.bubleView.backgroundColor = UIColor.clear
        }else{
            cell.messageImageView.isHidden = true
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height : CGFloat = 80
        let message = messages[indexPath.item]
        if let text = message.text {
            height = estimateFrameOfText(text: text).height + 20
        } else if let imageWidth = message.imageWidth?.doubleValue, let imageHeight = message.imageHeight?.doubleValue {
             height  = CGFloat(imageHeight/imageWidth * 200)
        }
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    private func estimateFrameOfText(text : String) -> CGRect{
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16)], context: nil)
    }
    var containerViewBottomAnchor : NSLayoutConstraint?
    
    @objc func handleSend(){
        let properties = ["text" : inputContainerView.inputTextField.text] as [String : Any]
        sendMessageWithProperties(properties : properties as [String : AnyObject] )
        
    }
    
    
    private func sendImageUrl(imageUrl : String, image : UIImage){
        let properties : [String : AnyObject] = ["imageUrl" : imageUrl, "imageWidth" : image.size.width, "imageHeight" : image.size.height] as [String : AnyObject]
        sendMessageWithProperties(properties: properties)
    }
    
    private func sendMessageWithProperties(properties : [String : AnyObject]){
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = Auth.auth().currentUser!.uid
        let timestamp = Int(Date().timeIntervalSince1970)
        var values = ["toId" : toId , "fromId" : fromId, "timestamp" : timestamp] as [String : Any]
        properties.forEach({values[$0.0] = $0.1})
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error)
                return
            }
            self.inputContainerView.inputTextField.text  = nil
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId:1])
            let recipientUserMessRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
            recipientUserMessRef.updateChildValues([messageId:1])
            
        }
    }

    var startingFrame : CGRect?
    var backgroundView : UIView?
    var imageView : UIImageView?
    func performZoom(imageView : UIImageView){
        self.imageView = imageView
        self.imageView?.isHidden = true
       startingFrame = imageView.superview?.convert(imageView.frame, to: nil)
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = imageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(zoomOut)))
        if let keyWindow  = UIApplication.shared.keyWindow {
            backgroundView = UIView(frame: keyWindow.frame)
            backgroundView?.backgroundColor = UIColor.black
            backgroundView?.alpha = 0
            keyWindow.addSubview(backgroundView!)
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.backgroundView!.alpha = 1
                self.inputContainerView.alpha = 0
                let height = self.startingFrame!.height/self.startingFrame!.width * keyWindow.frame.width
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
            }, completion: { (completion : Bool) in
            })
            
        }
    }
    @objc func zoomOut(tapGesture : UITapGestureRecognizer){
        if let zoomOutView = tapGesture.view{
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutView.frame = self.startingFrame!
                zoomOutView.layer.cornerRadius = 16
                zoomOutView.clipsToBounds  = false
                self.backgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
            }, completion: { (completion : Bool) in
                 zoomOutView.removeFromSuperview()
                self.imageView?.isHidden = false
            })
        }
    }
}
