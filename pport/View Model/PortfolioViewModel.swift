//
//  PortfolioViewModel.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 20.03.2022.
//

import Foundation
import Combine

class PortfolioViewModel {
    
    var user_id: String?
    var session: String?
    var currencies: [CurrencyData]?
    
    init() {
        initUserData()
    }
    
    func initUserData() {
        self.user_id = UserDefaultsManager.shared.get(forKey: "user_id") as? String
        self.session = UserDefaultsManager.shared.get(forKey: "session") as? String
        
        NSLog("user_id \(user_id)", "")
        NSLog("session \(session)", "")
    }
    
    func initData() {
        guard let user_id = user_id, let session = session else {
            NSLog("No user_is or session", "")
            return
        }

        APIManager.shared.getAllCurrencies(user_id: user_id, session: session, onFailure: { title, body in
            NSLog("Unable to retrieve currencies", "")
        }, onSuccess: { data in
            self.currencies = data
        })
    }
}
