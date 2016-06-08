//
//  ContactCell.swift
//  ContactsApp
//
//  Created by David Vallas on 6/7/16.
//  Copyright © 2016 David Vallas. All rights reserved.
//

import UIKit
import Contacts

class ContactCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    
    var contact: CNContact! { didSet { updateUI() } }
    
    private func updateUI() {
        
        // update name
        name.text = contact.givenName + " " + contact.familyName
    }
    
}
