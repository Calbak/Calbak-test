//
//  LoginViewController.swift
//  calbak-auth
//
//  Created by 허찬 on 2022/04/07.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {
    var ref: DatabaseReference!
    // 'develop' 브랜치에서 개발 시작.
    // 'dev-chan' 브랜치에서 개발 시작.
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
    }
    
    @IBAction func tappedLoginButton(_ sender: UIButton) {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            guard authResult != nil, error == nil else {
                self.errorLabel.text = error?.localizedDescription
                return
            }
            
            let _ = self.ref.child(email).observeSingleEvent(of: .value) { snapshot in
                //
            }
            
        }
        
        // showMainPageViewController()
    }
    
    private func showMainPageViewController(user: User) {
        // 회원가입 성공했을 때에만 SignUpSuccessViewController를 띄우도록 수정해야 함. (스토리보드 Segue 쪽 수정 필요)
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let vc = storyboard.instantiateViewController(withIdentifier: "MainPageViewController")
        vc.modalPresentationStyle = .fullScreen
        
        navigationController?.show(vc, sender: nil)
    }
}
