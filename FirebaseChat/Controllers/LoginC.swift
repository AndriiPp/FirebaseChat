//
//  LoginC.swift
//  FirebaseChat
//
//  Created by Andrii Pyvovarov on 29.06.18.
//  Copyright © 2018 Andrii Pyvovarov. All rights reserved.
//

import UIKit
import Firebase

class LoginC: UIViewController {
    var MessagesC : messagesC?
    let inputsContainer : UIView = {
       let cv = UIView()
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = UIColor.white
        cv.layer.cornerRadius = 5
        cv.layer.masksToBounds = true
        return cv
    }()
    
    let loginButton : UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Register", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.backgroundColor = UIColor.darkGray
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(loginRegister), for: .touchUpInside)
        return button
    }()
    let nameText : UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
       return tf
    }()

    let nameSeparator : UIView = {
        let  cv = UIView()
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        return cv
    }()
    
    let emailText : UITextField = {
        let et = UITextField()
        et.placeholder = "Email"
        et.translatesAutoresizingMaskIntoConstraints = false
        return et
    }()
    let emailSeparator : UIView = {
        let  cv = UIView()
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        return cv
    }()
    
    let passwordText : UITextField = {
        let et = UITextField()
        et.placeholder = "Password"
        et.isSecureTextEntry = true
        et.translatesAutoresizingMaskIntoConstraints = false
        return et
    }()
    
    lazy var imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "2")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
         imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = 5
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectImageView)))
        return imageView
    }()
    
    let segmentedControl : UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(r: 98, g: 94, b: 82)

        view.addSubview(inputsContainer)
        view.addSubview(loginButton)
        view.addSubview(imageView)
        view.addSubview(segmentedControl)
        
        setupContainerView()
        setupLoginButton()
        setupImageView()
        setupSegmentControl()
    }
    
    
    @objc func loginRegister(){
        if segmentedControl.selectedSegmentIndex == 0 {
            Login()
        } else {
            Register()
        }
    }
    @objc func Login(){
        guard let email = emailText.text, let password = passwordText.text else {
            print("Form is not valid")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                print(error)
                return
            }
            self.MessagesC?.navBarTitle()
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    
   @objc func handleLoginRegisterChange(){
    let title = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)
    loginButton.setTitle(title, for: .normal)
    inputsContainerHeightAnchor?.constant = segmentedControl.selectedSegmentIndex == 0 ? 100 : 150
    nameTextFieldHieghtAnchor?.isActive = false
    nameTextFieldHieghtAnchor = nameText.heightAnchor.constraint(equalTo: inputsContainer.heightAnchor, multiplier: segmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
    nameTextFieldHieghtAnchor?.isActive = true
    
    emailTextFieldHieghtAnchor?.isActive = false
    emailTextFieldHieghtAnchor = emailText.heightAnchor.constraint(equalTo: inputsContainer.heightAnchor, multiplier: segmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
    emailTextFieldHieghtAnchor?.isActive = true

    passwordTextFieldHieghtAnchor?.isActive = false
    passwordTextFieldHieghtAnchor = passwordText.heightAnchor.constraint(equalTo: inputsContainer.heightAnchor, multiplier: segmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
    passwordTextFieldHieghtAnchor?.isActive = true
    
    
    }
    func setupSegmentControl() {
        segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        segmentedControl.bottomAnchor.constraint(equalTo: inputsContainer.topAnchor, constant: -12).isActive = true
        segmentedControl.widthAnchor.constraint(equalTo: inputsContainer.widthAnchor).isActive = true
        segmentedControl.heightAnchor.constraint(equalToConstant: 36 ).isActive = true
    }
    func setupImageView(){
         imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: segmentedControl.topAnchor, constant: -12).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    var inputsContainerHeightAnchor : NSLayoutConstraint?
    var nameTextFieldHieghtAnchor : NSLayoutConstraint?
    var emailTextFieldHieghtAnchor : NSLayoutConstraint?
    var passwordTextFieldHieghtAnchor : NSLayoutConstraint?
    
    func setupContainerView(){
        inputsContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainer.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsContainerHeightAnchor =  inputsContainer.heightAnchor.constraint(equalToConstant: 150)
        inputsContainerHeightAnchor?.isActive = true
        
        inputsContainer.addSubview(nameText)
        inputsContainer.addSubview(nameSeparator)
        inputsContainer.addSubview(emailText)
        inputsContainer.addSubview(emailSeparator)
        inputsContainer.addSubview(passwordText)
        
        nameText.leftAnchor.constraint(equalTo: inputsContainer.leftAnchor, constant: 12).isActive = true
        nameText.topAnchor.constraint(equalTo: inputsContainer.topAnchor).isActive = true
        nameText.widthAnchor.constraint(equalTo: inputsContainer.widthAnchor).isActive = true
        nameTextFieldHieghtAnchor = nameText.heightAnchor.constraint(equalTo: inputsContainer.heightAnchor, multiplier: 1/3)
        nameTextFieldHieghtAnchor?.isActive = true
        nameSeparator.leftAnchor.constraint(equalTo: inputsContainer.leftAnchor).isActive = true
        nameSeparator.topAnchor.constraint(equalTo: nameText.bottomAnchor).isActive = true
        nameSeparator.widthAnchor.constraint(equalTo: inputsContainer.widthAnchor).isActive = true
        nameSeparator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        emailText.leftAnchor.constraint(equalTo: inputsContainer.leftAnchor, constant: 12).isActive = true
        emailText.topAnchor.constraint(equalTo: nameSeparator.bottomAnchor).isActive = true
        emailText.widthAnchor.constraint(equalTo: inputsContainer.widthAnchor).isActive = true
        emailTextFieldHieghtAnchor = emailText.heightAnchor.constraint(equalTo: inputsContainer.heightAnchor, multiplier: 1/3)
        emailTextFieldHieghtAnchor?.isActive = true
        emailSeparator.leftAnchor.constraint(equalTo: inputsContainer.leftAnchor).isActive = true
        emailSeparator.topAnchor.constraint(equalTo: emailText.bottomAnchor).isActive = true
        emailSeparator.widthAnchor.constraint(equalTo: inputsContainer.widthAnchor).isActive = true
        emailSeparator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        passwordText.leftAnchor.constraint(equalTo: inputsContainer.leftAnchor, constant: 12).isActive = true
        passwordText.topAnchor.constraint(equalTo: emailSeparator.bottomAnchor).isActive = true
        passwordText.widthAnchor.constraint(equalTo: inputsContainer.widthAnchor).isActive = true
        passwordTextFieldHieghtAnchor = passwordText.heightAnchor.constraint(equalTo: inputsContainer.heightAnchor, multiplier: 1/3)
        passwordTextFieldHieghtAnchor?.isActive = true
    }
    func setupLoginButton(){
        loginButton.topAnchor.constraint(equalTo: inputsContainer.bottomAnchor, constant: 12).isActive = true
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.widthAnchor.constraint(equalTo: inputsContainer.widthAnchor).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    //The preferred status bar style for the view controller
    override public  var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}


extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat){
    self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}
