//
//  SignUpViewController.swift
//  calbak-auth
//
//  Created by 허찬 on 2022/04/07.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SignUpViewController: UIViewController {
    var ref: DatabaseReference!   // Firebase 실시간 데이터베이스의 레퍼런스
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var pwConfirmTextFIeld: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func tappedNextButton(_ sender: UIButton) {
        // Firebase Auth - 이메일로 회원가입 기능 추가
        // Firebase Database - 추가 회원정보 저장 기능 추가
        // 비밀번호 - 비밀번호 확인 문자열 같은지 체크 필요
        // 가입 성공, 로그인하러 가기 페이지로 이동
        
        let email = emailTextField.text ?? ""
        let password = pwTextField.text ?? ""
                
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            guard authResult != nil, error == nil else {
                self.errorLabel.text = error?.localizedDescription
                return
            }
            
            if Auth.auth().currentUser != nil {
                self.showMoreInfoViewController()
            }
        }
    }
    
    private func showMoreInfoViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        guard let vc = storyboard.instantiateViewController(withIdentifier: "MoreInfoViewController") as? MoreInfoViewController else { return }
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
