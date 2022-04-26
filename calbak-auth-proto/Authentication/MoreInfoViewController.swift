//
//  MoreInfoViewController.swift
//  calbak-auth-proto
//
//  Created by 허찬 on 2022/04/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class MoreInfoViewController: UIViewController {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    var user: User?
    var safeEmail: String?
    var profileImageURL: String?
    
    let alert = UIAlertController(title: "올릴 방식을 선택하세요", message: "사진 찍기 또는 앨범에서 선택", preferredStyle: .actionSheet)
    let imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagePickerController.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 유저 설정
        user = Auth.auth().currentUser
        if let email = user?.email {
            safeEmail = email.replacingOccurrences(of: ".", with: "-")
            safeEmail = safeEmail?.replacingOccurrences(of: "@", with: "-")
        }
        
        // 프로필 사진 받기 위한 설정
        profileImageView.layer.cornerRadius = 60
        self.addGestureRecognizer()
        self.configureAlertEvent()
    }
    
    @IBAction func tappedSignUpButton(_ sender: UIButton) {
        guard let user = self.user,
              let safeEmail = self.safeEmail else { return }
        
        let username = usernameTextField.text ?? ""
        let description = descriptionTextField.text ?? nil
        let phoneNumber = phoneNumberTextField.text ?? ""
        let location = locationTextField.text ?? nil
        
        // image view에서 이미지 데이터 추출
        guard let image = self.profileImageView.image,
              let imageData = image.pngData() else { return }
        let imageFileName = "\(safeEmail)_profile_image.png"
        
        StorageManager.shared.uploadProfilePicture(with: imageData, fileName: imageFileName) { result in
            switch result {
                case .success(let profileImageURL):
                    UserDefaults.standard.set(profileImageURL, forKey: "profile_image_url")
                    self.profileImageURL = profileImageURL
                case .failure(let error):
                    self.errorLabel.text = "Storage manager error: \(error)"
            }
        }
        
        guard let profileImageURL = profileImageURL else { return }
        let userDetail = UserDetail(
            emailAddress: user.email ?? "",
            username: username,
            description: description,
            phoneNumber: phoneNumber,
            location: location,
            profileImageURL: profileImageURL
        )
        
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = username
        changeRequest.commitChanges() { error in
            if let error = error {
                self.errorLabel.text = error.localizedDescription
                return
            }
            
            UserDetailManager.shared.insertUser(with: userDetail) { success in
                if success {
                    self.showSignUpSuccessViewController()
                } else {
                    self.errorLabel.text = "회원가입에 실패했습니다. 다시 시도해 주세요"
                    return
                }
            }
        }
    }
    
    private func showSignUpSuccessViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "SignUpSuccessViewController")
        navigationController?.pushViewController(vc, animated: true)
    }
}



// 여기부터 프로필 이미지 다루는 부분
extension MoreInfoViewController {
    func configureAlertEvent() {
        let photoLibraryAlertAction = UIAlertAction(title: "사진 앨범", style: .default) { (action) in
            self.openAlbum() // 아래에서 설명 예정.
        }
        
        let cameraAlertAction = UIAlertAction(title: "카메라", style: .default) {(action) in
            self.openCamera() // 아래에서 설명 예정.
        }
        
        let cancelAlertAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(photoLibraryAlertAction)
        alert.addAction(cameraAlertAction)
        alert.addAction(cancelAlertAction)
        guard let alertControllerPopoverPresentationController = alert.popoverPresentationController else {return}
        prepareForPopoverPresentation(alertControllerPopoverPresentationController)
    }
}

extension MoreInfoViewController: UIPopoverPresentationControllerDelegate {
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        if let popoverPresentationController =
      self.alert.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect
            = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverPresentationController.permittedArrowDirections = []
        }
    }
}

extension MoreInfoViewController: UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    func openAlbum() {
        self.imagePickerController.sourceType = .photoLibrary
        present(self.imagePickerController, animated: false, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImageView?.image = image
        } else {
            print("error detected in didFinishPickinMediaWithInfo method")
        }
        
        dismiss(animated: true, completion: nil) // 반드시 dismiss 하기.
    }
    
    func openCamera() {
        if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
            self.imagePickerController.sourceType = .camera
            present(self.imagePickerController, animated: false, completion: nil)
        } else {
            print ("Camera's not available as for now.")
        }
    }
    
    @objc func tappedUIImageView(_ gesture: UITapGestureRecognizer) {
        self.present(self.alert, animated: true, completion: nil)
    }
    
    func addGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tappedUIImageView(_:)))
        self.profileImageView.addGestureRecognizer(tapGestureRecognizer)
        self.profileImageView.isUserInteractionEnabled = true
    }
}
