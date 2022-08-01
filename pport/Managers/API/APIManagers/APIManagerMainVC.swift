//
//  APIManager.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 1.03.2022.
//

import Foundation
import SwiftyJSON

extension APIManager {
    
    func validate(user_id: String, session: String, onFailure: @escaping (String, String)->Void, onSuccess: @escaping ()->Void) {
        let parameters: [String: Any] = [
            "user_id": user_id,
            "session": session
        ]
        
        var jsonData: Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            NSLog(error.localizedDescription)
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        
        APIManagerBase.shared.post(parameters: jsonData, endpoint: "/validatesession/", onFailure: { title, body in
            onFailure(title, body)
        }, onSuccess: { data in
            do {
                let decodedJSON = try JSON(data: data, options: [])
                if decodedJSON["statusCode"] == 200 {
                    onSuccess()
                    return
                } else if decodedJSON["statusCode"] == 400 {
                    // decoded["errorType"] = 123
                    onFailure("Invalid email or session", "Error")
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
    
    func getProfile(user_id: String, session: String, onFailure: @escaping (String, String)->Void, onSuccess: @escaping (ProfileData)->Void) {
        let parameters: [String: Any] = [
            "user_id": user_id,
            "session": session
        ]
        
        var jsonData: Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            NSLog(error.localizedDescription)
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        
        APIManagerBase.shared.post(parameters: jsonData, endpoint: "/getprofileinfo/", onFailure: { title, body in
            onFailure(title, body)
        }, onSuccess: { data in
            do {
                let decodedJSON = try JSON(data: data, options: [])
                if decodedJSON["statusCode"] == 200 {
                    let decoder = JSONDecoder()
                    if let decodedData = try? decoder.decode(ProfileData.self, from: data) {
                        onSuccess(decodedData)
                        return
                    }
                    onFailure("Unable to decode the Data", "Error")
                    return
                } else if decodedJSON["statusCode"] == 400 {
                    // decoded["errorType"] = 123
                    onFailure( "Sorry", "Your email or password is incorrect")
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
    
    func logout(user_id: String, session: String, onFailure: @escaping (String, String)->Void, onSuccess: @escaping ()->Void) {
        let parameters: [String: Any] = [
            "user_id": user_id,
            "session": session
        ]
        
        var jsonData: Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            NSLog(error.localizedDescription)
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        
        APIManagerBase.shared.post(parameters: jsonData, endpoint: "/signout/", onFailure: { title, body in
            onFailure(title, body)
        }, onSuccess: { data in
            do {
                let decodedJSON = try JSON(data: data, options: [])
                if decodedJSON["statusCode"] == 200 {
                    onSuccess()
                    return
                } else if decodedJSON["statusCode"] == 400 {
                    // decoded["errorType"] = 123
                    onFailure("Sorry", "Invalid email or session")
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
    
    func getExchanges(onFailure: @escaping (String, String)->Void, onSuccess: @escaping ([ExchangeData])->Void) {
        APIManagerBase.shared.post(parameters: nil, endpoint: "/getallexchangecodes/", onFailure: { title, body in
            onFailure(title, body)
        }, onSuccess: { data in
            do {
                let decodedJSON = try JSON(data: data, options: [])
                if decodedJSON["statusCode"] == 200 {
                    let decoder = JSONDecoder()
                    if let decodedData = try? decoder.decode(ExchangeDataResponse.self, from: data) {
                        onSuccess(decodedData.data)
                        return
                    }
                    onFailure("Unable to decode the Data", "Error")
                    return
                } else if decodedJSON["statusCode"] == 400 {
                    onFailure( "Ups!", "Something went wrong. Please try again later.")
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
    
    func getStockNames(exchangeCode: String, onFailure: @escaping (String, String)->Void, onSuccess: @escaping ([SearchData])->Void) {
        let parameters: [String: Any] = ["exchange_code": exchangeCode]

        var jsonData: Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            NSLog(error.localizedDescription)
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        
        APIManagerBase.shared.post(parameters: jsonData, endpoint: "/getalltickers/", onFailure: { title, body in
            onFailure(title, body)
        }, onSuccess: { data in
            do {
                let decodedJSON = try JSON(data: data, options: [])
                if decodedJSON["statusCode"] == 200 {
                    let decoder = JSONDecoder()
                    if let decodedData = try? decoder.decode(SearchDataResponse.self, from: data) {
                        onSuccess(decodedData.data)
                        return
                    }
                    onFailure("Unable to decode the Data", "Error")
                    return
                } else if decodedJSON["statusCode"] == 400 {
                    onFailure( "Ups!", "Something went wrong. Please try again later.")
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
    
    func getWatchlistData(user_id: String, session: String, onFailure: @escaping (String, String)->Void, onSuccess: @escaping ([TickerItem])->Void) {
        let parameters = ["user_id": user_id, "session": session]
        
        var jsonData: Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            NSLog(error.localizedDescription)
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        
        APIManagerBase.shared.post(parameters: jsonData, endpoint: "/getwatchlisttickersdata/", onFailure: { title, body in
            onFailure(title, body)
        }, onSuccess: { data in
            do {
                let decodedJSON = try JSON(data: data, options: [])
                if decodedJSON["statusCode"] == 200 {
                    let decoder = JSONDecoder()
                    if let decodedData = try? decoder.decode(TickerItemDataResponse.self, from: data) {
                        onSuccess(decodedData.data)
                        return
                    }
                    print(decodedJSON)
                    NSLog("getWatchlistData, Unable to decode data", "")
                    onFailure("Ups!", "Something went wrong. Please try again later.")
                    return
                } else if decodedJSON["statusCode"] == 400 {
                    onFailure( "Ups!", "Something went wrong. Please try again later.")
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
    
    func addItemToWatchlist(user_id: String, session: String, item_name: String, onFailure: @escaping (String, String)->Void, onSuccess: @escaping ()->Void) {
        let parameters: [String: Any] = [
            "user_id": user_id,
            "session": session,
            "item_name": item_name
        ]
        
        var jsonData: Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            NSLog(error.localizedDescription)
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        
        APIManagerBase.shared.post(parameters: jsonData, endpoint: "/addwatchlistitem/", onFailure: { title, body in
            onFailure(title, body)
        }, onSuccess: { data in
            do {
                let decodedJSON = try JSON(data: data, options: [])
                if decodedJSON["statusCode"] == 200 {
                    onSuccess()
                    return
                } else if decodedJSON["statusCode"] == 400 {
                    onFailure( "Ups!", "Something went wrong. Please try again later.")
                    print(decodedJSON)
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
    
    func removeItemFromWatchlist(user_id: String, session: String, item_name: String, onFailure: @escaping (String, String)->Void, onSuccess: @escaping ()->Void) {
        let parameters: [String: Any] = [
            "user_id": user_id,
            "session": session,
            "item_name": item_name
        ]
        
        var jsonData: Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            NSLog(error.localizedDescription)
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        
        APIManagerBase.shared.post(parameters: jsonData, endpoint: "/deletewatchlistitem/", onFailure: { title, body in
            onFailure(title, body)
        }, onSuccess: { data in
            do {
                let decodedJSON = try JSON(data: data, options: [])
                if decodedJSON["statusCode"] == 200 {
                    onSuccess()
                    return
                } else if decodedJSON["statusCode"] == 400 {
                    onFailure( "Ups!", "Something went wrong. Please try again later.")
                    print(decodedJSON)
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
    
    func getAllCurrencies(user_id: String, session: String, onFailure: @escaping (String, String)->Void, onSuccess: @escaping ([CurrencyData])->Void) {
        let parameters: [String: Any] = [
            "user_id": user_id,
            "session": session
        ]
        
        var jsonData: Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            NSLog(error.localizedDescription)
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        
        APIManagerBase.shared.post(parameters: jsonData, endpoint: "/getallcurrencycodes/", onFailure: { title, body in
            onFailure(title, body)
        }, onSuccess: { data in
            do {
                let decodedJSON = try JSON(data: data, options: [])
                if decodedJSON["statusCode"] == 200 {
                    let decoder = JSONDecoder()
                    if let decodedData = try? decoder.decode(CurrencyDataResponse.self, from: data) {
                        onSuccess(decodedData.data)
                        return
                    }
                    print(decodedJSON)
                    NSLog("getWatchlistData, Unable to decode data", "")
                    onFailure("Ups!", "Something went wrong. Please try again later.")
                    return
                } else if decodedJSON["statusCode"] == 400 {
                    onFailure( "Ups!", "Something went wrong. Please try again later.")
                    print(decodedJSON)
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
}
