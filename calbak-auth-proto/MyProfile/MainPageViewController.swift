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
    
    var userDetail: UserDetail?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let username = userDetail?.username else { return }
        guard let email = userDetail?.safeEmail else { return }
        guard let phoneNumber = userDetail?.phoneNumber else { return }
        guard let location = userDetail?.location else { return }
        
        usernameLabel.text = "\(username)님"
        emailLabel.text = "\(email)"
        phoneNumberLabel.text = "\(phoneNumber)"
        locationLabel.text = "\(location)"
    }
}
