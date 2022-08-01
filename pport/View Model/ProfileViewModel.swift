//
//  ProfileViewModel.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 20.03.2022.
//

import Foundation
import Combine

class ProfileViewModel {
    
    private(set) var mode: ProfileMode = .view
    
    private(set) var updateUI = PassthroughSubject<Void, Never>()
    private(set) var logout = PassthroughSubject<Void, Never>()
    private(set) var showPopUp = CurrentValueSubject<PopUpCombine, Never>(PopUpCombine(title: "", body: ""))
    private(set) var setProfile = CurrentValueSubject<ProfileCombine, Never>(ProfileCombine(name: "", surname: "", email: ""))
    
    func change(mode to: ProfileMode) {
        self.mode = to
        self.updateUI.send()
    }
    
    func setProfileInfo() {
        guard let name = UserDefaultsManager.shared.get(forKey: "name") as? String,
              let surname = UserDefaultsManager.shared.get(forKey: "surname") as? String,
              let email = UserDefaultsManager.shared.get(forKey: "email") as? String,
              let _ = UserDefaultsManager.shared.get(forKey: "session"),
              let _ = UserDefaultsManager.shared.get(forKey: "user_id") else {
                  return
              }
        setProfile.send(ProfileCombine(name: name, surname: surname, email: email))
    }

    
    func fetchProfileInfo() {

        let user_id = UserDefaults.standard.string(forKey: "user_id") ?? ""
        let session = UserDefaults.standard.string(forKey: "session") ?? ""
        
        if user_id == "" || session == "" {
            self.logout.send()
            return
        }
        
        APIManager.shared.getProfile(user_id: user_id, session: session, onFailure: { title, body in
            DispatchQueue.main.async {
                self.showPopUp.send(PopUpCombine(title: title, body: body))
            }
        }, onSuccess: { data in
            UserDefaultsManager.shared.update(forKey: "name", value: data.body.name)
            UserDefaultsManager.shared.update(forKey: "surname", value: data.body.surname)
            UserDefaultsManager.shared.update(forKey: "email", value: data.body.email)
            
            DispatchQueue.main.async {
                self.setProfile.send(ProfileCombine(name: data.body.name, surname: data.body.surname, email: data.body.email))
            }
        })
    }
    
    func saveANDlogutBtnTapped() {
        switch mode {
        case .settings:
            let user_id = UserDefaultsManager.shared.get(forKey: "user_id") as! String
            let session = UserDefaultsManager.shared.get(forKey: "session") as! String

            APIManager.shared.logout(user_id: user_id, session: session, onFailure: { title, body in
                NSLog("Logout error.", "")
                NSLog(title + ", " + body, "")
            }, onSuccess: {
                NSLog("Logout success.", "")
                DispatchQueue.main.async {
                    UserDefaultsManager.shared.removeAll()
                    do {
                        try CoreDataManager.shared.remove(entity: "WatchListItem")
                    } catch let err {
                        NSLog(err.localizedDescription, "")
                    }
                    
                    self.logout.send()
                }
                
            })
        case .edit:
            self.change(mode: .view)
        case .view:
            NSLog("Button should not be visible.", "")
        }
    }
}
