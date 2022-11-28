//
//  WatchlistAPIManager.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 6.11.2022.
//

import Foundation

extension APIManager {
    
    // MARK: Get Watchlist Data
    func getWatchlistData(token: String, session: String, onFailure: @escaping (String, String)->Void, onSuccess: @escaping ([WatchlistData])->Void) {
        let parameters = [
            "session": session
        ]
        
        var jsonData: Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch _ {
            NSLog("APIManager.getWatchlistData parameters decode error", "")
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        
        APIManagerBase.shared.post(parameters: jsonData, endpoint: "/watchlist/get_watchlist_data", auth: token, onFailure: { response_code, body in
            NSLog("APIManager.getWatchlistData response_code: \(response_code) body: \(body)", "")
            onFailure("Error", body)
        }, onSuccess: { data in
            let decoder = JSONDecoder()
            if let decodedData = try? decoder.decode([WatchlistData].self, from: data) {
                onSuccess(decodedData)
                return
            }
            NSLog("APIManager.getWatchlistData: unable to decode [WatchlistData]", "")
            onFailure("Ups!", "Something went wrong. Please try again later.")
        })
    }
    
    // MARK: Delete Watchlist Item
    func deleteWatchlistItem(token: String, session: String, ticker: String, onFailure: @escaping (String, String)->Void, onSuccess: @escaping ()->Void) {
        let parameters = [
            "session": session,
            "ticker": ticker
        ]
        
        var jsonData: Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch _ {
            NSLog("APIManager.deleteWatchlistItem parameters decode error", "")
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        
        APIManagerBase.shared.post(parameters: jsonData, endpoint: "/watchlist/delete_watchlist_item", auth: token, onFailure: { response_code, body in
            NSLog("APIManager.deleteWatchlistItem response_code: \(response_code) body: \(body)", "")
            onFailure("Error", body)
        }, onSuccess: { data in
            onSuccess()
        })
    }
    
    // MARK: Add Watchlist Item
    func addWatchlistItem(token: String, session: String, ticker: String, onFailure: @escaping (String, String)->Void, onSuccess: @escaping ()->Void) {
        let parameters = [
            "session": session,
            "ticker": ticker
        ]
        
        var jsonData: Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch _ {
            NSLog("APIManager.addWatchlistItem parameters decode error", "")
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        
        APIManagerBase.shared.post(parameters: jsonData, endpoint: "/watchlist/add_watchlist_item", auth: token, onFailure: { response_code, body in
            NSLog("APIManager.addWatchlistItem response_code: \(response_code) body: \(body)", "")
            onFailure("Error", body)
        }, onSuccess: { data in
            onSuccess()
        })
    }
}
