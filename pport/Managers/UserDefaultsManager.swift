//
//  UserDefaultsManager.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 20.02.2022.
//

import Foundation

class UserDefaultsManager: NSObject {
    
    static let shared = UserDefaultsManager()
    
    func set(params: [String: Any]) {
        for param in params.keys {
            UserDefaults.standard.set(params[param], forKey: param)
        }
    }
    
    func get(forKey: String) -> Any? {
        return UserDefaults.standard.object(forKey: forKey)
    }
    
    func update(forKey: String, value: Any) {
        UserDefaults.standard.setValue(value, forKey: forKey)
    }
    
    func remove(forKey: String) {
        UserDefaults.standard.removeObject(forKey: forKey)
    }
    
    func removeAll() {
        UserDefaults.standard.removeObject(forKey: "session")
        UserDefaults.standard.removeObject(forKey: "email")
        UserDefaults.standard.removeObject(forKey: "name")
        UserDefaults.standard.removeObject(forKey: "surname")
        UserDefaults.standard.removeObject(forKey: "user_id")
        UserDefaults.standard.removeObject(forKey: "watchlist")
    }
}
