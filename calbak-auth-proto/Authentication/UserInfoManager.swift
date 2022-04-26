//
//  UserInfoManager.swift
//  calbak-auth-proto
//
//  Created by 허찬 on 2022/04/14.
//

import Foundation
import FirebaseDatabase

final class UserDetailManager {
    static let shared = UserDetailManager()
    private let ref = Database.database().reference()
    var userDetail: UserDetail?
}

extension UserDetailManager {
    public func userExists(with email: String, completion: @escaping ((Bool) -> Void))  {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        // To check email is exist, find safeEmail in firebase database, and then check nil for snapshot.
        ref.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            // if snapshot is nil, then completion closure argument will be allocated "false"
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            
            // completion closure argument will be allocated "true"
            completion(true)
        }
    }
    
    // 회원가입 시에 호출할 메서드.
    // Firebase Database에 유저의 정보를 입력한다.
    public func insertUser(with userDetail: UserDetail, completion: @escaping (Bool) -> Void) {
        ref.child(userDetail.safeEmail).setValue([
            "emailAddress": userDetail.safeEmail,
            "username": userDetail.username,
            "description": userDetail.description,
            "phoneNumber": userDetail.phoneNumber,
            "location": userDetail.location,
            "profileImageURL": userDetail.profileImageURL
        ]) { error, reference in
            guard error == nil else {
                print("failed to write to database")
                completion(false)
                return
            }
            
            self.userDetail = userDetail
            completion(true)
        }
    }
    
    // Firebase 데이터베이스에서 유저 정보를 검색해서 받아올 때 사용할 메서드
    public func fetchUserDetail(with safeEmail: String, completion: @escaping (Bool) -> Void) {
        ref.child(safeEmail).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            
            guard let value = snapshot.value as? NSDictionary else {
                completion(false)
                return
            }
            
            let userDetail = UserDetail(
                emailAddress: value["emailAddress"] as? String ?? "",
                username: value["username"] as? String ?? "",
                description: value["description"] as? String ?? "",
                phoneNumber: value["phoneNumber"] as? String ?? "",
                location: value["location"] as? String ?? "",
                profileImageURL: value["profileImageURL"] as? String ?? ""
            )
            
            self.updateUserDetail(with: userDetail)
        }
        
        completion(true)
    }
    
    public func updateUserDetail(with updatedUser: UserDetail) {
        self.userDetail = updatedUser
    }
    
    public func getSafeEmail(with emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}

struct UserDetail {
    var emailAddress: String
    var username: String
    var description: String?
    var phoneNumber: String
    var location: String?
    var profileImageURL: String?
    
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        return safeEmail
    }
    
    var profileImageFileName : String {
        return "\(safeEmail)_profile_image.png"
    }
}
