//
//  Extensions.swift
//  FirebaseChat
//
//  Created by Andrii Pyvovarov on 14.08.18.
//  Copyright © 2018 Andrii Pyvovarov. All rights reserved.
//

import UIKit
let imageC = NSCache<AnyObject, AnyObject>()

extension UIImageView{
    func loadImageUsingCashe(urlString : String){
        self.image = nil
        if let cachedImage = imageC.removeObject(forKey: urlString as AnyObject) as? UIImage{
            self.image = cachedImage
            return
        }
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                print(error)
                return
            }
            DispatchQueue.main.async {
                if let downloadedImage =  UIImage(data: data!){
                    imageC.setObject(downloadedImage, forKey: urlString as AnyObject)
                    self.image = downloadedImage
                }
                
                
            }
        }).resume()
    }
}
