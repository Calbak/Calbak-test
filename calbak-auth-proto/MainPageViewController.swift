//
//  MainPageViewController.swift
//  calbak-auth-proto
//
//  Created by 허찬 on 2022/04/14.
//

import UIKit

class MainPageViewController: UIViewController {
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    var user: UserInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

}
