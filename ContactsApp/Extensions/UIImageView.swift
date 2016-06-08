//
//  UIImageView.swift
//  ContactsApp
//
//  Created by David Vallas on 6/8/16.
//  Copyright © 2016 David Vallas. All rights reserved.
//

import UIKit

extension UIImageView {
    
    /// creates a circled image of image in imageView's rect
    func circled() {
        
        self.layer.cornerRadius = self.frame.height / 2.0
        self.clipsToBounds = true
    }
    
}
