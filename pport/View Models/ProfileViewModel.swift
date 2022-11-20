//
//  ProfileViewModel.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 20.03.2022.
//

import Foundation
import Combine

class ProfileViewModel {
    
    private var token: String?
    private var session: String?
    
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
              let token = KeyChainManager.shared.read(service: .token, type: Token.self),
              let session = KeyChainManager.shared.read(service: .session, type: Session.self) else {
            return
              }
        self.token = token.token
        self.session = session.session
        setProfile.send(ProfileCombine(name: name, surname: surname, email: email))
    }

    
    func fetchProfileInfo() {
        
        guard let session = session, let token = token else {
            return
        }
        
        APIManager.shared.getUserInfo(token: token, session: session, onFailure: { title, body in
            DispatchQueue.main.async {
                self.showPopUp.send(PopUpCombine(title: title, body: body))
            }
        }, onSuccess: { data in
            UserDefaultsManager.shared.update(forKey: "name", value: data.name)
            UserDefaultsManager.shared.update(forKey: "surname", value: data.surname)
            UserDefaultsManager.shared.update(forKey: "email", value: data.email)
            
            DispatchQueue.main.async {
                self.setProfile.send(ProfileCombine(name: data.name, surname: data.surname, email: data.email))
            }
        })
    }
    
    func saveANDlogutBtnTapped() {
        switch mode {
        case .settings:
            guard let session = session, let token = token else {
                return
            }
            
            APIManager.shared.signOut(session: session, token: token, onFailure: { title, body in
                // TODO: popup
            }, onSuccess: {
                DispatchQueue.main.async {
                    UserDefaultsManager.shared.removeAll()
                    do {
                        try CoreDataManager.shared.remove(entity: .watchlist)
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
