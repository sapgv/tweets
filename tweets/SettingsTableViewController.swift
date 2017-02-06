//
//  SettingsTableViewController.swift
//  tweets
//
//  Created by Гриша on 05.02.17.
//  Copyright © 2017 ru.sapgv. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var showAvatarSwitch: UISwitch!
    @IBOutlet weak var requestLabel: UILabel!
    
    @IBAction func actionSwitchAvatar(_ sender: Any) {
    
        let showAvatar = showAvatarSwitch.isOn
        let defaults = UserDefaults.standard
        defaults.set(showAvatar, forKey: "showAvatar")
        defaults.synchronize()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        let defaults = UserDefaults.standard
        
        let showAvatar = defaults.bool(forKey: "showAvatar")
        if showAvatar {
            showAvatarSwitch.isOn = true
        }
        else {
            showAvatarSwitch.isOn = false
        }
        
        let request = defaults.string(forKey: "lastRequest")
        requestLabel.text = request
        
    }

    @IBAction func actionDone(_ sender: Any) {
        
        presentingViewController?.dismiss(animated: true, completion: nil)
        
    }
    

}
