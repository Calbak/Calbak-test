//
//  LoginViewController.swift
//  calbak-auth
//
//  Created by 허찬 on 2022/04/07.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn

class LoginViewController: UIViewController {
    var ref: DatabaseReference!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Google 로그인을 띄울 뷰 컨트롤러가 LoginVC라는 것을 알려주기
        // GIDSignIn.sharedInstance.presentingViewController = self
    }
    
    @IBAction func tappedLoginButton(_ sender: UIButton) {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            guard authResult != nil, error == nil else {
                self.errorLabel.text = error?.localizedDescription
                return
            }
            
            UserDetailManager.shared.fetchUserDetail(with: safeEmail) { success in
                if !success {
                    // 에러 메시지 알럿 추가하기
                    return
                }
            }
            
            if UserDetailManager.shared.userDetail != nil {
                self.showMyProfileViewController()
            }
        }
    }
    
    @IBAction func tappedGoogleSignInButton(_ sender: UIButton) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [weak self] user, error in
            if let error = error {
                self?.errorLabel.text = error.localizedDescription
                return
            }

            guard let authentication = user?.authentication,
                  let idToken = authentication.idToken else { return }
            
            // credential이란? Google Access Token을 부여받은 것이다!
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            
            // Google에서 전달된 Token들로 Firebase에서 로그인을 시도한다.
            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorLabel.text = error.localizedDescription
                    return
                }
                
                // 로그인했을 때 유저 정보 받아오는 코드 추가로 필요함.
                // ++ Google로 로그인 했을 때도 유저 정보 추가 설정해주는 기능이 필요할 듯.
                //    -> 근데 이걸 할 거면 이메일로 회원가입 할 때랑 합쳐버리는게 나을거같은데 ...
                // 내일 이 부분 얘기해보기
                
                self.showMyProfileViewController()
            }
        }
    }
    
    private func showMyProfileViewController() {
        let storyboard = UIStoryboard(name: "MyProfile", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "MyProfileViewController") as? MyProfileViewController else { return }
        navigationController?.isNavigationBarHidden = true
        navigationController?.show(vc, sender: nil)
    }
}

