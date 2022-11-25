//
//  APIManagerBase.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 30.01.2022.
//

import UIKit
import SwiftyJSON

class APIManagerBase: NSObject {
    
    private let baseURL = "http://3.66.183.245/api/v1"
    static let shared = APIManagerBase()
    
    func post(parameters: Data?, endpoint: String, auth: String?, onFailure: @escaping (Int, String)->Void, onSuccess: @escaping (Data)->Void) {
        guard let url = URL(string: baseURL+endpoint) else {
            NSLog("Invalid URL.")
            onFailure(100, "Something went wrong. Please try again later.")
            return
        }
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if parameters != nil {
            request.httpBody = parameters
        }
        if auth != nil {
            request.addValue("Token "+auth!, forHTTPHeaderField: "Authorization")
        }
        
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error -> Void in
         
            guard let data = data else {
                NSLog("URLSessionDataTask data - Unable to retrieve data", "")
                onFailure(100, "Something went wrong. Please try again later.")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    onSuccess(data)
                } else if httpResponse.statusCode == 401 {
                    DispatchQueue.main.async {
                        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.returnWelcomePageViewController()
                    }
                } else {
                    if error != nil {
                        NSLog("Error from server with code: \(httpResponse.statusCode), error: \(error!)", "")
                        onFailure(httpResponse.statusCode, "Something went wrong. Please try again later.")
                        return
                    } else {
                        let decoder = JSONDecoder()
                        if let decodedData = try? decoder.decode(ErrorData.self, from: data) {
                            onFailure(httpResponse.statusCode, decodedData.error)
                            return
                        }
                        NSLog("Error from server with code: \(httpResponse.statusCode), error is nill", "")
                        onFailure(httpResponse.statusCode, "Something went wrong. Please try again later.")
                        return
                    }
                }
            }
        })
        task.resume()
    }
    
    func get(endpoint: String, auth: String?, onFailure: @escaping (Int, String)->Void, onSuccess: @escaping (Data)->Void) {
        guard let url = URL(string: baseURL+endpoint) else {
            NSLog("Invalid URL.")
            onFailure(100, "Something went wrong. Please try again later.")
            return
        }
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if auth != nil {
            request.addValue("Token "+auth!, forHTTPHeaderField: "Authorization")
        }
        
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error -> Void in
            if error != nil {
                onFailure(100, "URLSessionDataTask error - " + error!.localizedDescription)
                return
            }
         
            guard let data = data else {
                onFailure(101, "URLSessionDataTask data - Unable to retrieve data")
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    onFailure(httpResponse.statusCode, response.debugDescription)
                    return
                }
            }
            onSuccess(data)
            return
        })
        task.resume()
    }
}
