//
//  UserInfoManager.swift
//  calbak-auth-proto
//
//  Created by 허찬 on 2022/04/14.
//

import Foundation
import FirebaseDatabase

final class UserInfoManager {
    static let shared = UserInfoManager()
    private let database = Database.database().reference()

}

extension UserInfoManager {
    
    public func userExists(with email: String, completion: @escaping ((Bool) -> Void))  {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        // To check email is exist, find safeEmail in firebase database, and then check nil for snapshot.
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
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
    public func insertUser(with user: UserInfo, completion: @escaping (Bool) -> Void) {
        database.child(user.safeEmail).setValue([
            "uid": user.uid,
            "emailAddress": user.safeEmail,
            "username": user.username,
            "password": user.password,
            "phoneNumber": user.phoneNumber,
            "location": user.location,
            "profileImageURL": user.profileImageURL
        ]) { error, reference in
            guard error == nil else {
                print("failed to write to database")
                completion(false)
                return
            }
            completion(true)
        }
    }
}

struct UserInfo {
    let uid: String
    let emailAddress: String
    let username: String
    let password: String
    let phoneNumber: String
    let location: String?
    let profileImageURL: String?
    
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}
