//
//  ContactDetailVC.swift
//  ContactsApp
//
//  Created by David Vallas on 6/7/16.
//  Copyright © 2016 David Vallas. All rights reserved.
//

import UIKit
import Contacts

class ContactDetailVC: UIViewController, UITextFieldDelegate {
    
    var contact: CNContact!
    
    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstName.delegate = self
        lastName.delegate = self
        phoneNumber.delegate = self
        updateUI()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        updateContact()
        return true
    }
    
    
    private func updateContact() {
        
        // create mutable contact
        let mutableContact = contact?.mutableCopy() as! CNMutableContact
        
        // update last and first name
        mutableContact.givenName = firstName.text ?? ""
        mutableContact.familyName = lastName.text ?? ""
        
        // remove current mobile phone number if it exists
        var index = 0
        for number in mutableContact.phoneNumbers {
            if number.label == CNLabelPhoneNumberMobile {
                mutableContact.phoneNumbers.removeAtIndex(index)
                break
            }
            index += 1
        }
        
        // update mobile number
        if phoneNumber.text?.characters.count > 0 {
            let number = CNPhoneNumber(stringValue: phoneNumber.text!)
            let mobileNumber = CNLabeledValue(label: CNLabelPhoneNumberMobile, value: number)
            mutableContact.phoneNumbers.append(mobileNumber)
        }
        
        // save updated contact to store
        let store = CNContactStore()
        let request = CNSaveRequest()
        request.updateContact(mutableContact)
        do {
            try store.executeSaveRequest(request)
        } catch let error {
            print("Unable to save contacts: \(error)")
        }
    }
    
    private func updateUI() {
        
        // set defaults
        contactImageView.image = UIImage(named: "icon_blankimage")
        firstName.text = nil
        lastName.text = nil
        phoneNumber.text = nil
        
        if let c = contact {
            
            // update contact image
            if let data = c.imageData {
                contactImageView.image = UIImage(data: data)
            }
            
            // update first name
            firstName.text = c.givenName
            
            // update last name
            lastName.text = c.familyName
            
            // update phone
            var phoneNumberText: String? = nil
            for number in c.phoneNumbers {
                if number.label == CNLabelPhoneNumberMobile {
                    phoneNumberText = ((number.value as! CNPhoneNumber).valueForKey("digits") as! String)
                    break
                }
            }
            
            phoneNumber.text = phoneNumberText
        }
        
        
       contactImageView.circled()
    }
    
}
