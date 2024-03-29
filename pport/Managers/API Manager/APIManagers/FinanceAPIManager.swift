//
//  APIManager.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 6.11.2022.
//

import Foundation

extension APIManager {
    
    // MARK: Get Tickers
    func getTickers(token: String, session: String, exchange_code: String, onFailure: @escaping (String, String)->Void, onSuccess: @escaping ([TickerData])->Void) {
        let parameters: [String: Any] = [
            "session": session,
            "exchange_code": exchange_code
        ]

        var jsonData: Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch _ {
            NSLog("APIManager.getTickers parameters decode error", "")
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        
        APIManagerBase.shared.post(parameters: jsonData, endpoint: "/finance/get_tickers", auth: token, onFailure: { response_code, body in
            NSLog("APIManager.getTickers response_code: \(response_code) body: \(body)", "")
            onFailure("Error", body)
        }, onSuccess: { data in
            let decoder = JSONDecoder()
            if let decodedData = try? decoder.decode([TickerData].self, from: data) {
                onSuccess(decodedData)
                return
            }
            NSLog("APIManager.getTickers: unable to decode [TickerData]", "")
            onFailure("Ups!", "Something went wrong. Please try again later.")
        })
    }
    
    // MARK: Validate Ticker
    func validateTicker(token: String, session: String, ticker: String, exchange: String, onFailure: @escaping (String, String)->Void, onSuccess: @escaping (Int)->Void) {
        let parameters: [String: Any] = [
            "session": session,
            "ticker": ticker,
            "exchange": exchange
        ]

        var jsonData: Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch _ {
            NSLog("APIManager.validateTicker parameters decode error", "")
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        
        APIManagerBase.shared.post(parameters: jsonData, endpoint: "/finance/validate_ticker", auth: token, onFailure: { response_code, body in
            NSLog("APIManager.validateTicker response_code: \(response_code) body: \(body)", "")
            onFailure("Error", body)
        }, onSuccess: { data in
            let decoder = JSONDecoder()
            if let decodedData = try? decoder.decode(Int.self, from: data) {
                onSuccess(decodedData)
                return
            }
            NSLog("APIManager.validateTicker: unable to decode Int", "")
            onFailure("Ups!", "Something went wrong. Please try again later.")
        })
    }
    
    // MARK: Get Exchange Codes
    func getExchangeCodes(token: String, session: String, onFailure: @escaping (String, String)->Void, onSuccess: @escaping ([ExchangeData])->Void) {
        let parameters: [String: Any] = [
            "session": session
        ]

        var jsonData: Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch _ {
            NSLog("APIManager.getExchangeCodes parameters decode error", "")
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        
        APIManagerBase.shared.post(parameters: jsonData, endpoint: "/finance/get_exchange_codes", auth: token, onFailure: { response_code, body in
            NSLog("APIManager.getExchangeCodes response_code: \(response_code) body: \(body)", "")
            onFailure("Error", body)
        }, onSuccess: { data in
            let decoder = JSONDecoder()
            if let decodedData = try? decoder.decode([ExchangeData].self, from: data) {
                onSuccess(decodedData)
                return
            }
            NSLog("APIManager.getExchangeCodes: unable to decode [ExchangeData]", "")
            onFailure("Ups!", "Something went wrong. Please try again later.")
        })
    }
    
    // MARK: Get Currency Codes
    func getCurrencyCodes(token: String, session: String, onFailure: @escaping (String, String)->Void, onSuccess: @escaping ([CurrencyCodeData])->Void) {
        let parameters: [String: Any] = [
            "session": session
        ]

        var jsonData: Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch _ {
            NSLog("APIManager.getCurrencyCodes parameters decode error", "")
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        
        APIManagerBase.shared.post(parameters: jsonData, endpoint: "/finance/get_currency_codes", auth: token, onFailure: { response_code, body in
            NSLog("APIManager.getCurrencyCodes response_code: \(response_code) body: \(body)", "")
            onFailure("Error", body)
        }, onSuccess: { data in
            let decoder = JSONDecoder()
            if let decodedData = try? decoder.decode([CurrencyCodeData].self, from: data) {
                onSuccess(decodedData)
                return
            }
            NSLog("APIManager.getCurrencyCodes: unable to decode [CurrencyCodeData]", "")
            onFailure("Ups!", "Something went wrong. Please try again later.")
        })
    }
    
}
