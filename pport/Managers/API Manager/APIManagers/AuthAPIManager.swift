//
//  APIManager.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 31.01.2022.
//

import SwiftyJSON
import Foundation

class APIManager: NSObject {

    static let shared = APIManager()
    
    // MARK: Sign In
    func signIn(email: String, password: String, onFailure: @escaping (String, String)->Void, onSuccess: @escaping (SignInData)->Void) {
        let parameters: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        var jsonData: Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch _ {
            NSLog("APIManager.signIn parameters decode error", "")
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        
        APIManagerBase.shared.post(parameters: jsonData, endpoint: "/auth/sign_in", auth: nil, onFailure: { response_code, body in
            NSLog("APIManager.signIn response_code: \(response_code) body: \(body)", "")
            onFailure("Error", body)
        }, onSuccess: { data in
            let decoder = JSONDecoder()
            if let decodedData = try? decoder.decode(SignInData.self, from: data) {
                onSuccess(decodedData)
                return
            }
            NSLog("APIManager.signIn: unable to decode SignInData", "")
            onFailure("Ups!", "Something went wrong. Please try again later.")
        })
    }
    
    // MARK: Sign Out
    func signOut(session: String, token: String, onFailure: @escaping (String, String)->Void, onSuccess: @escaping ()->Void) {
        let parameters: [String: Any] = [
            "session": session
        ]
        
        var jsonData: Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch _ {
            NSLog("APIManager.signOut parameters decode error", "")
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        
        APIManagerBase.shared.post(parameters: jsonData, endpoint: "/auth/sign_out", auth: token, onFailure: { response_code, body in
            NSLog("APIManager.signOut response_code: \(response_code) body: \(body)", "")
            onFailure("Error", body)
        }, onSuccess: { _ in
            onSuccess()
        })
    }
    
    // MARK: Sign Up
    func signUp(name: String, surname: String, email: String, password1: String, password2: String, onFailure: @escaping (String, String)->Void, onSuccess: @escaping ()->Void) {
        
        let parameters: [String: Any] = [
            "name": name,
            "surname": surname,
            "email": email,
            "password": password1,
            "password_confirm": password2
        ]
        
        var jsonData: Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch _ {
            NSLog("APIManager.signUp parameters decode error", "")
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        
        APIManagerBase.shared.post(parameters: jsonData, endpoint: "/auth/sign_up", auth: nil, onFailure: { response_code, body in
            NSLog("APIManager.getPortfolio response_code: \(response_code) body: \(body)", "")
            onFailure("Error", body)
        }, onSuccess: { _ in
            onSuccess()
        })
    }
    
    // MARK: Send Reset Request
    func sendResetRequest(email: String, onFailure: @escaping (String, String)->Void, onSuccess: @escaping ()->Void) {
        let parameters: [String: Any] = [
            "email": email
        ]
        
        var jsonData: Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch _ {
            NSLog("APIManager.sendResetRequest parameters decode error", "")
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        
        APIManagerBase.shared.post(parameters: jsonData, endpoint: "/auth/reset_password", auth: nil, onFailure: { response_code, body in
            NSLog("APIManager.sendResetRequest response_code: \(response_code) body: \(body)", "")
            onFailure("Error", body)
        }, onSuccess: { _ in
            onSuccess()
        })
    }
    
    // MARK: Validate ResetCode
    func validateResetCode(email: String, reset_code: Int, onFailure: @escaping (String, String)->Void, onSuccess: @escaping ()->Void) {
        let parameters: [String: Any] = [
            "email": email,
            "reset_code": reset_code
        ]
        
        var jsonData: Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch _ {
            NSLog("APIManager.validateResetCode parameters decode error", "")
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        
        APIManagerBase.shared.post(parameters: jsonData, endpoint: "/auth/validate_reset_code", auth: nil, onFailure: { response_code, body in
            NSLog("APIManager.validateResetCode response_code: \(response_code) body: \(body)", "")
            onFailure("Error", body)
        }, onSuccess: { _ in
            onSuccess()
        })
    }
    
    // MARK: Change Password
    func changePassword(email: String, reset_code: Int, password1: String, password2: String, onFailure: @escaping (String, String)->Void, onSuccess: @escaping ()->Void) {
        let parameters: [String: Any] = [
            "email": email,
            "reset_code": reset_code,
            "new_password": password1,
            "new_password_confirm": password2
        ]
        
        var jsonData: Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch _ {
            NSLog("APIManager.changePassword parameters decode error", "")
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        
        APIManagerBase.shared.post(parameters: jsonData, endpoint: "/auth/change_password", auth: nil, onFailure: { response_code, body in
            NSLog("APIManager.changePassword response_code: \(response_code) body: \(body)", "")
            onFailure("Error", body)
        }, onSuccess: { _ in
            onSuccess()
        })
    }
    
    // MARK: Validate Session
    func validateSession(session: String, onFailure: @escaping (String, String)->Void, onSuccess: @escaping ()->Void) {
        let parameters: [String: Any] = [
            "session": session
        ]
        
        var jsonData: Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch _ {
            NSLog("APIManager.validateSession parameters decode error", "")
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        
        APIManagerBase.shared.post(parameters: jsonData, endpoint: "/auth/validate_session", auth: nil, onFailure: { response_code, body in
            NSLog("APIManager.validateSession response_code: \(response_code) body: \(body)", "")
            if response_code == 404 {
                onFailure("Ups!", "Something went wrong. Please try again later.")
                return
            }
            onFailure("Error", body)
        }, onSuccess: { _ in
            onSuccess()
        })
    }
    
    // MARK: Get Token
    func getToken(session: String, onFailure: @escaping (String, String)->Void, onSuccess: @escaping (TokenData)->Void) {
        let parameters: [String: Any] = [
            "session": session
        ]
        
        var jsonData: Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch _ {
            NSLog("APIManager.getToken parameters decode error", "")
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        
        APIManagerBase.shared.post(parameters: jsonData, endpoint: "/auth/get_token", auth: nil, onFailure: { response_code, body in
            NSLog("APIManager.getToken response_code: \(response_code) body: \(body)", "")
            onFailure("Error", body)
        }, onSuccess: { data in
            let decoder = JSONDecoder()
            if let decodedData = try? decoder.decode(TokenData.self, from: data) {
                onSuccess(decodedData)
                return
            }
            NSLog("APIManager.getToken: unable to decode TokenData", "")
            onFailure("Ups!", "Something went wrong. Please try again later.")
        })
    }
}
