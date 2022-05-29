//
//  MyProfileViewController.swift
//  calbak-auth-proto
//
//  Created by 허찬 on 2022/04/17.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class MyProfileViewController: UIViewController {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var user: User?
    var userDetail: UserDetail?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // user 정보 초기화
        user = Auth.auth().currentUser
        userDetail = UserDetailManager.shared.userDetail
        
        // UI 초기화
        profileImageView.layer.cornerRadius = 60
        self.configureView()
    }
    
    @IBAction func tappedEditProfileButton(_ sender: UIButton) {
        if self.user != nil {
            showEditProfileViewController()
        }
    }
    
    private func configureView() {
        guard let user = self.user,
              let userDetail = self.userDetail else { return }
              
    
        if let profileImageURL = userDetail.profileImageURL,
           let url = URL(string: profileImageURL) {
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    self.profileImageView.image = UIImage(data: data!)
                    
                    if let username = user.displayName {
                        self.usernameLabel.text = "\(username)"
                    }
                    
                    if let description = userDetail.description {
                        self.descriptionLabel.text = "\(description)"
                    } else {
                        self.descriptionLabel.text = "자기소개를 작성해 보세요!"
                    }
                }
            }
        }
        
        /*
        if let profileImageURL = UserDefaults.standard.string(forKey: "profile_image_url"),
            let url = URL(string: profileImageURL) {
            do {
                let data = try Data(contentsOf: url)
                profileImageView.image = UIImage(data: data)
            } catch let error {
                print(error.localizedDescription)
                return
            }
        }
        */
    }
     
    private func showEditProfileViewController() {
        let storyboard = UIStoryboard(name: "EditProfile", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "EditProfileViewController") as? EditProfileViewController else { return }
        navigationController?.isNavigationBarHidden = false
        navigationController?.pushViewController(vc, animated: true)
    }
}
