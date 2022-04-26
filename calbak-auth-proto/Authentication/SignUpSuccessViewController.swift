//
//  SignUpSuccessViewController.swift
//  calbak-auth
//
//  Created by 허찬 on 2022/04/07.
//

import UIKit
import FirebaseAuth

class SignUpSuccessViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    @IBAction func tappedMyProfileButton(_ sender: Any) {
        self.showMyProfileViewController()
    }
    
    private func showMyProfileViewController() {
        let storyboard = UIStoryboard(name: "MyProfile", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "MyProfileViewController") as? MyProfileViewController else { return }
        navigationController?.isNavigationBarHidden = true
        navigationController?.show(vc, sender: nil)
    }
}
