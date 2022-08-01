//
//  StringExtension.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 7.02.2022.
//

import Foundation

enum StringType: String {
    case password
    case email
}

extension String {
    
    func isValid(type: StringType) -> Bool {
        switch type {
        case .password:
            return validatePassword()
        case .email:
            return validateEmail()
        }
    }
    
    private func validatePassword() -> Bool {
        if self.count < 8 {
            NSLog("validatePassword, password is short.", "")
            return false
        }
        
        let capitalLetterRegEx  = ".*[A-Z]+.*"
        let texttest1 = NSPredicate(format:"SELF MATCHES %@", capitalLetterRegEx)
        if !texttest1.evaluate(with: self) {
            NSLog("validatePassword, no capital letter.", "")
            return false
        }
        
        let lowerLetterRegEx  = ".*[a-z]+.*"
        let texttest2 = NSPredicate(format:"SELF MATCHES %@", lowerLetterRegEx)
        if !texttest2.evaluate(with: self) {
            NSLog("No capital letter.", "")
            return false
        }

        let numberRegEx  = ".*[0-9]+.*"
        let texttest3 = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        if !texttest3.evaluate(with: self) {
            NSLog("No number.", "")
            return false
        }
        
        let specialCharacterRegEx  = ".*[!&^%$#@()/.-]+.*"
        let texttest4 = NSPredicate(format:"SELF MATCHES %@", specialCharacterRegEx)
        if !texttest4.evaluate(with: self) {
            NSLog("No special charecter.", "")
            return false
        }
        return true
    }
    
    private func validateEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        if !emailPred.evaluate(with: self) {
            NSLog("Invalid email \(self).", "")
            return false
        }
        return true
    }
    
    func isNumber() -> Bool {
        return Int(self) != nil
    }
    
    func toNumber() -> Int? {
        return Int(self)
    }
}
