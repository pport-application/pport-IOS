//
//  UserAPIManager.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 6.11.2022.
//

import Foundation

import SwiftyJSON
import Foundation

extension APIManager {
    
    // MARK: Delete user
    func deleteUser(token: String, session: String, password: String, onFailure: @escaping (String, String)->Void, onSuccess: @escaping ()->Void) {
        let parameters: [String: Any] = [
            "session": session,
            "password": password
        ]
        
        var jsonData: Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch _ {
            NSLog("APIManager.deleteUser parameters decode error", "")
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        
        APIManagerBase.shared.post(parameters: jsonData, endpoint: "/user/delete_user", auth: token, onFailure: { response_code, body in
            NSLog("APIManager.deleteUser response_code: \(response_code) body: \(body)", "")
            onFailure("Error", body)
        }, onSuccess: { data in
            onSuccess()
        })
    }
    
    // MARK: Get User Info
    func getUserInfo(token: String, session: String, onFailure: @escaping (String, String)->Void, onSuccess: @escaping (UserInfoData)->Void) {
        let parameters: [String: Any] = [
            "session": session
        ]
        
        var jsonData: Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch _ {
            NSLog("APIManager.getUserInfo parameters decode error", "")
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        
        APIManagerBase.shared.post(parameters: jsonData, endpoint: "/user/get_user_info", auth: token, onFailure: { response_code, body in
            NSLog("APIManager.getUserInfo response_code: \(response_code) body: \(body)", "")
            onFailure("Error", body)
        }, onSuccess: { data in
            let decoder = JSONDecoder()
            if let decodedData = try? decoder.decode(UserInfoData.self, from: data) {
                onSuccess(decodedData)
                return
            }
            NSLog("APIManager.getUserInfo: unable to decode UserInfoData", "")
            onFailure("Ups!", "Something went wrong. Please try again later.")
        })
    }
    
    // MARK: Update User Info
    func updateUserInfo(token: String, session: String, name: String, surname: String, onFailure: @escaping (String, String)->Void, onSuccess: @escaping ()->Void) {
        let parameters: [String: Any] = [
            "session": session,
            "name": name,
            "surname": surname
        ]
        
        var jsonData: Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch _ {
            NSLog("APIManager.updateUserInfo parameters decode error", "")
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        
        APIManagerBase.shared.post(parameters: jsonData, endpoint: "/user/update_user_info", auth: token, onFailure: { response_code, body in
            NSLog("APIManager.updateUserInfo response_code: \(response_code) body: \(body)", "")
            onFailure("Error", body)
        }, onSuccess: { data in
            onSuccess()
        })
    }
    
    // MARK: Update Password
    func updatePassword(token: String, session: String, old_password: String, new_password: String, new_password_confirm: String, onFailure: @escaping (String, String)->Void, onSuccess: @escaping ()->Void) {
        let parameters: [String: Any] = [
            "session": session,
            "old_password": old_password,
            "new_password": new_password,
            "new_password_confirm": new_password_confirm
        ]
        
        var jsonData: Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch _ {
            NSLog("APIManager.updatePassword parameters decode error", "")
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        
        APIManagerBase.shared.post(parameters: jsonData, endpoint: "/user/update_password", auth: token, onFailure: { response_code, body in
            NSLog("APIManager.updatePassword response_code: \(response_code) body: \(body)", "")
            onFailure("Error", body)
        }, onSuccess: { data in
            onSuccess()
        })
    }

}
