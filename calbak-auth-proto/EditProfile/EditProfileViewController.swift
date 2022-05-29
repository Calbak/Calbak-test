//
//  EditProfileViewController.swift
//  Calbak
//
//  Created by 김인영 on 2022/04/08.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class EditProfileViewController: UIViewController {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    
    var ref: DatabaseReference!
    var user: User?
    var userDetail: UserDetail?
    
    let alert = UIAlertController(title: "올릴 방식을 선택하세요", message: "사진 찍기 또는 앨범에서 선택", preferredStyle: .actionSheet)
    let imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagePickerController.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        profileImageView.layer.cornerRadius = 60
        
        // Database 레퍼런스 설정
        ref = Database.database().reference()
        
        // user 정보 초기화
        user = Auth.auth().currentUser
        userDetail = UserDetailManager.shared.userDetail
        
        // 기존 유저 정보 값을 받아와서 텍스트 필드에 넣어두기
        self.configureView()
        
        self.addGestureRecognizer()
        self.configureAlertEvent()
    }
    
    @IBAction func tappedChangeButton(_ sender: UIButton) {
        guard var userDetail = self.userDetail else { return }
        let safeEmail = userDetail.safeEmail
        
        guard let image = self.profileImageView.image,
              let imageData = image.pngData() else { return }
        let imageFileName = userDetail.profileImageFileName
        
        StorageManager.shared.uploadProfilePicture(with: imageData, fileName: imageFileName) { result in
            switch result {
                case .success(let profileImageURL):
                    UserDefaults.standard.set(profileImageURL, forKey: "profile_image_url")
                    let changeRequest = self.user?.createProfileChangeRequest()
                    changeRequest?.photoURL =  URL(string: profileImageURL)
                    changeRequest?.commitChanges() { error in
                        if let error = error {
                            print(error)
                            return
                        }
                    }
                case .failure(let error):
                    print("Storage manager error: \(error)")
            }
        }
        
        
        let username = usernameTextField.text ?? ""
        let description = descriptionTextField.text ?? ""
        let phoneNumber = phoneNumberTextField.text ?? ""
        let location = locationTextField.text ?? ""
        
        if username != "" {
            userDetail.username = username
            ref.child("\(safeEmail)/username").setValue(username)
        }
        if description != "" {
            userDetail.description = description
            ref.child("\(safeEmail)/description").setValue(description)
        }
        if phoneNumber != "" {
            userDetail.phoneNumber = phoneNumber
            ref.child("\(safeEmail)/phoneNumber").setValue(phoneNumber)
        }
        if location != "" {
            userDetail.location = location
            ref.child("\(safeEmail)/location").setValue(location)
        }
        
        UserDetailManager.shared.updateUserDetail(with: userDetail)
        
        let alert = UIAlertController(title: "회원정보 수정 완료", message: "회원정보가 수정되었습니다.", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "확인", style: .default, handler: { _ in 
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(confirm)
        present(alert, animated: true, completion: nil)
    }
    
    private func configureView() {
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
        
        
        /*
        if user?.profileImageURL != "" {
            guard let imageURL = user?.profileImageURL,
                  let url = URL(string: imageURL) else { return }
            
            do {
                let data = try Data(contentsOf: url)
                profileImageView.image = UIImage(data: data)
            } catch let error {
                print(error.localizedDescription)
                return
            }
        }
        */
        
        usernameTextField.text = userDetail?.username
        descriptionTextField.text = userDetail?.description ?? ""
        phoneNumberTextField.text = userDetail?.phoneNumber
        locationTextField.text = userDetail?.location ?? ""
    }
    
    @IBAction func tappedNavBarBackButton(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
}


// 여기부터 프로필 이미지 다루는 부분
extension EditProfileViewController {
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

extension EditProfileViewController: UIPopoverPresentationControllerDelegate {
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

extension EditProfileViewController: UIImagePickerControllerDelegate,
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
