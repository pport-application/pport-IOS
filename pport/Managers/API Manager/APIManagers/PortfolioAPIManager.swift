//
//  APIManager.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 1.03.2022.
//

import Foundation
import SwiftyJSON

extension APIManager {
    
    // MARK: Deposit Currency
    func depositCurrency(token: String, session: String, currency: String, amount: Float, timestamp: TimeInterval, onFailure: @escaping (String, String)->Void, onSuccess: @escaping ()->Void) {
        let parameters: [String: Any] = [
            "session": session,
            "currency": currency,
            "amount": amount,
            "timestamp": timestamp
        ]
        
        var jsonData: Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch _ {
            NSLog("APIManager.depositCurrency parameters decode error", "")
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        
        APIManagerBase.shared.post(parameters: jsonData, endpoint: "/portfolio/deposit_currency", auth: token, onFailure: { response_code, body in
            NSLog("APIManager.depositCurrency response_code: \(response_code) body: \(body)", "")
            onFailure("Error", body)
        }, onSuccess: { _ in
            onSuccess()
        })
    }
    
    // MARK: Withdraw Currency
    func withdrawCurrency(token: String, session: String, currency: String, amount: Float, timestamp: TimeInterval, onFailure: @escaping (String, String)->Void, onSuccess: @escaping ()->Void) {
        let parameters: [String: Any] = [
            "session": session,
            "currency": currency,
            "amount": amount,
            "timestamp": timestamp
        ]
        
        var jsonData: Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch _ {
            NSLog("APIManager.withdrawCurrency parameters decode error", "")
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        
        APIManagerBase.shared.post(parameters: jsonData, endpoint: "/portfolio/withdraw_currency", auth: token, onFailure: { response_code, body in
            NSLog("APIManager.withdrawCurrency response_code: \(response_code) body: \(body)", "")
            onFailure("Error", body)
        }, onSuccess: { _ in
            onSuccess()
        })
    }
    
    // MARK: Get History
    func getHistory(token: String, session: String, onFailure: @escaping (String, String)->Void, onSuccess: @escaping ([HistoryData])->Void) {
        let parameters: [String: Any] = [
            "session": session
        ]
        
        var jsonData: Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch _ {
            NSLog("APIManager.getHistory parameters decode error", "")
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        
        APIManagerBase.shared.post(parameters: jsonData, endpoint: "/portfolio/get_history", auth: token, onFailure: { response_code, body in
            NSLog("APIManager.getHistory response_code: \(response_code) body: \(body)", "")
            onFailure("Error", body)
        }, onSuccess: { data in
            let decoder = JSONDecoder()
            if let decodedData = try? decoder.decode([HistoryData].self, from: data) {
                onSuccess(decodedData)
                return
            }
            NSLog("APIManager.getHistory: unable to decode HistoryData", "")
            onFailure("Ups!", "Something went wrong. Please try again later.")
        })
    }
    
    // MARK: Deposit Ticker
    func depositTicker(token: String, session: String, ticker: String, count: Float, charge: Float, currency: String, timestamp: TimeInterval, onFailure: @escaping (String, String)->Void, onSuccess: @escaping ()->Void) {
        let parameters: [String: Any] = [
            "session": session,
            "ticker": ticker,
            "count": count,
            "charge": charge,
            "currency": currency,
            "timestamp": timestamp
        ]
        
        var jsonData: Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch _ {
            NSLog("APIManager.depositTicker parameters decode error", "")
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        
        APIManagerBase.shared.post(parameters: jsonData, endpoint: "/portfolio/deposit_ticker", auth: token, onFailure: { response_code, body in
            NSLog("APIManager.depositTicker response_code: \(response_code) body: \(body)", "")
            onFailure("Error", body)
        }, onSuccess: { _ in
            onSuccess()
        })
    }
    
    // MARK: Withdraw Ticker
    func withdrawTicker(token: String, session: String, ticker: String, count: Float, charge: Float, currency: String, timestamp: TimeInterval, onFailure: @escaping (String, String)->Void, onSuccess: @escaping ()->Void) {
        let parameters: [String: Any] = [
            "session": session,
            "ticker": ticker,
            "count": count,
            "charge": charge,
            "currency": currency,
            "timestamp": timestamp
        ]
        
        var jsonData: Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch _ {
            NSLog("APIManager.withdrawTicker parameters decode error", "")
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        
        APIManagerBase.shared.post(parameters: jsonData, endpoint: "/portfolio/withdraw_ticker", auth: token, onFailure: { response_code, body in
            NSLog("APIManager.withdrawTicker response_code: \(response_code) body: \(body)", "")
            onFailure("Error", body)
        }, onSuccess: { _ in
            onSuccess()
        })
    }
    
    // MARK: Get Portfolio
    func getPortfolio(token: String, session: String, onFailure: @escaping (String, String)->Void, onSuccess: @escaping (PortfolioData)->Void) {
        let parameters: [String: Any] = [
            "session": session
        ]
        
        var jsonData: Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch _ {
            NSLog("APIManager.getPortfolio parameters decode error", "")
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        
        APIManagerBase.shared.post(parameters: jsonData, endpoint: "/portfolio/get_portfolio", auth: token, onFailure: { response_code, body in
            NSLog("APIManager.getPortfolio response_code: \(response_code) body: \(body)", "")
            onFailure("Error", body)
        }, onSuccess: { data in
            let decoder = JSONDecoder()
            if let decodedData = try? decoder.decode(PortfolioData.self, from: data) {
                onSuccess(decodedData)
                return
            }
            NSLog("APIManager.getPortfolio: unable to decode PortfolioData", "")
            onFailure("Ups!", "Something went wrong. Please try again later.")
        })
    }
    
}
