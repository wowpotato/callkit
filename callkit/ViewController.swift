//
//  ViewController.swift
//  callkit
//
//  Created by mykim on 2023/04/05.
//

import UIKit
import CallKit
import Contacts
import Messages

final class ViewController: UIViewController {

    @IBOutlet weak var progressbar: UIActivityIndicatorView!
    @IBOutlet weak var viewLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
    @IBAction func onTouchAdd(_ sender: UIButton) {
        guard let text = textField.text else { return }
        guard let userDefaults = UserDefaults(suiteName: "group.com.mys.apptest") else { return }
        userDefaults.set(text, forKey: "pattern")
        userDefaults.set(true, forKey: "add")
    
        self.reloadExtension()
    }
    
    @IBAction func onTouchRemove(_ sender: UIButton) {
        guard let text = textField.text else { return }
        guard let userDefaults = UserDefaults(suiteName: "group.com.mys.apptest") else { return }
        userDefaults.set(text, forKey: "pattern")
        userDefaults.set(false, forKey: "add")
        
        self.reloadExtension()
    }
    
    func reloadExtension() {
        progressbar.startAnimating()
        CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: "com.myslab.callkit.SampleCallkitManager") { [weak self] error in
            
            print("reloadExtension completion")
            
            DispatchQueue.main.async {
                self?.progressbar.stopAnimating()
            }
            
            if let error {
                print("error = \(error)")
            } else {
                print("success!")
            }
        }
    }
    
    @IBAction func onTouchMessageBlock(_ sender: UIButton) {
        // 이건 아직 확인 안해봄 ㅋ
        guard let text = textField.text else { return }
        
        let contactStore = CNContactStore()
        let keysToFetch = [CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        let predicate = CNContact.predicateForContacts(matchingName: text)
        var contacts = [CNContact]()
        
        do {
            contacts = try contactStore.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
        } catch {
            print("Failed to fetch contacts with error: \(error.localizedDescription)")
        }
        
        if let contact = contacts.first {
            let store = CNContactStore()
            let saveRequest = CNSaveRequest()
            let blockContact = contact.mutableCopy() as! CNMutableContact
            blockContact.phoneNumbers = []
            let phoneNumber = CNLabeledValue(label: CNLabelPhoneNumberMain, value: CNPhoneNumber(stringValue: text))
            blockContact.phoneNumbers.append(phoneNumber)
            saveRequest.update(blockContact)
            
            do {
                try store.execute(saveRequest)
            } catch {
                print("Failed to block contact with error: \(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func onTouchMessageRemove(_ sender: UIButton) {
       
    }
    
}
