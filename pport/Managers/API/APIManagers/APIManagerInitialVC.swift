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
    
    func singUp(name: String, surname: String, email: String, password: String, onFailure: @escaping (String, String)->Void, onSuccess: @escaping (JSON)->Void) {
        
        let parameters: [String: Any] = [
            "name": name,
            "surname": surname,
            "email": email,
            "password": password
        ]
        
        var jsonData: Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            NSLog(error.localizedDescription)
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        
        APIManagerBase.shared.post(parameters: jsonData, endpoint: "/signup/", onFailure: { title, body in
            onFailure(title, body)
        }, onSuccess: { data in
            do {
                let decodedJSON = try JSON(data: data, options: [])
                if decodedJSON["statusCode"] == 200 {
                    onSuccess(decodedJSON)
                    return
                } else if decodedJSON["statusCode"] == 400 {
                    // decoded["errorType"] = 123
                    onFailure( "Sorry", "This email is already been registered.")
                    return
                }
                NSLog("Unexpected error type with code" + decodedJSON["statusCode"].description)
                print(decodedJSON)
                onFailure("Ups!", "Something went wrong. Please try again later.")
                return
            } catch _ {
                NSLog("Unable to decode data")
                onFailure("Ups!", "Something went wrong. Please try again later.")
                return
            }
            
        })
    }
    
    func signIn(email: String, password: String, onFailure: @escaping (String, String)->Void, onSuccess: @escaping (LoginData)->Void) {
        let parameters: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        var jsonData: Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            NSLog(error.localizedDescription)
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        
        APIManagerBase.shared.post(parameters: jsonData, endpoint: "/signin/", onFailure: { title, body in
            onFailure(title, body)
        }, onSuccess: { data in
            do {
                let decodedJSON = try JSON(data: data, options: [])
                if decodedJSON["statusCode"] == 200 {
                    let decoder = JSONDecoder()
                    if let decodedData = try? decoder.decode(LoginData.self, from: data) {
                        onSuccess(decodedData)
                        return
                    }
                    NSLog("Unable to decode the Data")
                    onFailure("Ups!", "Something went wrong. Please try again later.")
                    return
                } else if decodedJSON["statusCode"] == 400 {
                    // decoded["errorType"] = 123
                    onFailure("Ups!", "Your email or password is incorrect")
                    return
                }
                NSLog("Unexpected error type with code" + decodedJSON["statusCode"].description)
                print(decodedJSON)
                onFailure("Ups!", "Something went wrong. Please try again later.")
                return
            } catch _ {
                NSLog("Unable to decode data")
                onFailure("Ups!", "Something went wrong. Please try again later.")
                return
            }
        })
    }
    
    func validate(email: String, reset_code: Int, onFailure: @escaping (String, String)->Void, onSuccess: @escaping ()->Void) {
        let parameters: [String: Any] = [
            "email": email,
            "reset_code": reset_code
        ]
        
        var jsonData: Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            NSLog(error.localizedDescription)
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        
        APIManagerBase.shared.post(parameters: jsonData, endpoint: "/validateresetcode/", onFailure: { title, body in
            onFailure(title, body)
        }, onSuccess: { data in
            do {
                let decodedJSON = try JSON(data: data, options: [])
                if decodedJSON["statusCode"] == 200 {
                    onSuccess()
                    return
                } else if decodedJSON["statusCode"] == 400 {
                    if decodedJSON["error"] == 123 {
                        onFailure("Sorry", "Invalid email")
                        return
                    } else if decodedJSON["error"] == 124 {
                        onFailure("Invalid Reset Code", "Please make sure that the reset code is correct")
                        return
                    }
                }
                NSLog("Unexpected error type with code" + decodedJSON["statusCode"].description)
                print(decodedJSON)
                onFailure("Ups!", "Something went wrong. Please try again later.")
                return
            } catch _ {
                NSLog("Unable to decode data")
                onFailure("Ups!", "Something went wrong. Please try again later.")
                return
            }
        })
    }
    
    func changePassword(email: String, reset_code: Int, password: String, onFailure: @escaping (String, String)->Void, onSuccess: @escaping ()->Void) {
        let parameters: [String: Any] = [
            "email": email,
            "reset_code": reset_code,
            "new_password": password
        ]
        
        var jsonData: Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            NSLog(error.localizedDescription)
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        
        APIManagerBase.shared.post(parameters: jsonData, endpoint: "/changepassword/", onFailure: { title, body in
            onFailure(title, body)
        }, onSuccess: { data in
            do {
                let decodedJSON = try JSON(data: data, options: [])
                if decodedJSON["statusCode"] == 200 {
                    onSuccess()
                    return
                } else if decodedJSON["statusCode"] == 400 {
                    if decodedJSON["error"] == 123 {
                        onFailure( "Sorry", "Invalid email or session")
                    } else if decodedJSON["error"] == 124 {
                        onFailure("Invalid Reguest", "This account did not request reset process. Please retry the process.")
                    } else if decodedJSON["error"] == 125 {
                        onFailure("Invalid Reset Code", "Please make sure that the reset code is correct")
                    }
                    return
                }
                NSLog("Unexpected error type with code" + decodedJSON["statusCode"].description)
                print(decodedJSON)
                onFailure("Ups!", "Something went wrong. Please try again later.")
                return
            } catch _ {
                NSLog("Unable to decode data")
                onFailure("Ups!", "Something went wrong. Please try again later.")
                return
            }
        })
    }
    
    func sendResetRequest(email: String, onFailure: @escaping (String, String)->Void, onSuccess: @escaping ()->Void) {
        let parameters: [String: Any] = [
            "email": email
        ]
        
        var jsonData: Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            NSLog(error.localizedDescription)
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        
        APIManagerBase.shared.post(parameters: jsonData, endpoint: "/sendresetpasswordrequest/", onFailure: { title, body in
            onFailure(title, body)
        }, onSuccess: { data in
            do {
                let decodedJSON = try JSON(data: data, options: [])
                if decodedJSON["statusCode"] == 200 {
                    onSuccess()
                    return
                } else if decodedJSON["statusCode"] == 400 {
                    if decodedJSON["errorType"] == 123 {
                        onFailure("Sorry", "Invalid email or session")
                        return
                    }
                }
                NSLog("Unexpected error type with code" + decodedJSON["statusCode"].description)
                print(decodedJSON)
                onFailure("Ups!", "Something went wrong. Please try again later.")
                return
            } catch _ {
                NSLog("Unable to decode data")
                onFailure("Ups!", "Something went wrong. Please try again later.")
                return
            }
        })
    }
}
