//
//  ContactTVC.swift
//  ContactsApp
//
//  Created by David Vallas on 6/7/16.
//  Copyright © 2016 David Vallas. All rights reserved.
//

import UIKit
import Contacts

class ContactTVC: UITableViewController {
    
    var contacts: [[CNContact]] = []
    
    var sectionTitles: [String] = UILocalizedIndexedCollation.currentCollation().sectionTitles
    
    // MARK: View Lifecycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        getContacts()
    }
    
    // MARK: UITableViewControllerDelegate
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ContactCell", forIndexPath: indexPath) as! ContactCell
        
        cell.contact = contacts[indexPath.section][indexPath.row]
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    // MARK: UITableViewControllerDelegate - Sections
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return UILocalizedIndexedCollation.currentCollation().sectionTitles.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section < contacts.count {
            return contacts[section].count
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return UILocalizedIndexedCollation.currentCollation().sectionIndexTitles
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return UILocalizedIndexedCollation.currentCollation().sectionForSectionIndexTitleAtIndex(index)
    }
    
    // MARK: Navigation
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showContactDetail", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showContactDetail" {
            let cdVC = segue.destinationViewController as! ContactDetailVC
            if let indexPath = tableView.indexPathForSelectedRow {
                cdVC.contact = contacts[indexPath.section][indexPath.row]
            }
        }
    }
}


extension ContactTVC {
    
    /// checks for store authorization and gets list of all contacts
    func getContacts() {
        let store = CNContactStore()
        
        if CNContactStore.authorizationStatusForEntityType(.Contacts) == .NotDetermined {
            store.requestAccessForEntityType(.Contacts, completionHandler: { (authorized: Bool, error: NSError?) -> Void in
                if authorized {
                    self.retrieveContactsWithStore(store)
                }
            })
        } else if CNContactStore.authorizationStatusForEntityType(.Contacts) == .Authorized {
            self.retrieveContactsWithStore(store)
        }
    }
    
    /// get list of all contacts for a specific store
    func retrieveContactsWithStore(store: CNContactStore) {
        
        var contacts = [[CNContact]]()
        
        var indexedDictionary: [String:Int] = [:]
        
        // add sections for titles, and create an indexedDictionary to track indexes of titles
        var index = 0
        for title in sectionTitles {
            contacts.append([])
            indexedDictionary[title] = index
            index += 1
        }
    
        let keysToFetch = [CNContactThumbnailImageDataKey,
                           CNContactImageDataKey,
                           CNContactEmailAddressesKey,
                           CNContactPhoneNumbersKey,
                           CNContactFamilyNameKey,
                           CNContactGivenNameKey]
        let request = CNContactFetchRequest(keysToFetch: keysToFetch)
        request.sortOrder = .UserDefault
        
        do {
            try store.enumerateContactsWithFetchRequest(request) {
                (contact, stop) in
                // Array containing all unified contacts from contacts with phone numbers
                // Indexes with no family name will be shown in the # section
                if contact.phoneNumbers.count > 0 {
                    let firstLetter = contact.familyName.characters.first ?? "#"
                    let caps = String(firstLetter).capitalizedString
                    let index = indexedDictionary[caps]
                    if index != nil {
                        contacts[index!].append(contact)
                    }
                }
            }
        }
        catch {
            print("unable to fetch contacts")
        }
        
        self.contacts = contacts
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }
}

