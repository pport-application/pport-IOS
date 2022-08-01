//
//  APIManagerBase.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 30.01.2022.
//

import UIKit
import SwiftyJSON

class APIManagerBase: NSObject {
    
    private let baseURL = "https://43ivjzct7e.execute-api.eu-central-1.amazonaws.com/prod"
    static let shared = APIManagerBase()
    
    func post(parameters: Data?, endpoint: String, onFailure: @escaping (String, String)->Void, onSuccess: @escaping (Data)->Void) {
        guard let url = URL(string: baseURL+endpoint) else {
            NSLog("Invalid URL.")
            onFailure("Ups!", "Something went wrong. Please try again later.")
            return
        }
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if parameters != nil {
            request.httpBody = parameters
        }
        
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error -> Void in
            
            if error != nil {
                NSLog("Error from server.")
                NSLog(error!.localizedDescription)
                onFailure("Ups!", "Something went wrong. Please try again later.")
                return
            }
         
            guard let data = data else {
                NSLog("URLSessionDataTask data - Unable to retrieve data")
                onFailure("Ups!", "Something went wrong. Please try again later.")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    NSLog("Error with status code " + String(httpResponse.statusCode))
                    NSLog(response.debugDescription)
                    onFailure("Ups!", "Something went wrong. Please try again later.")
                    return
                }
            }
            onSuccess(data)
            return
        })
        task.resume()
    }
    
    func get(endpoint: String, onFailure: @escaping (String)->Void, onSuccess: @escaping (Data)->Void) {
        guard let url = URL(string: baseURL+endpoint) else {
            print("Invalid URL")
            return
        }
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error -> Void in
            if error != nil {
                onFailure("URLSessionDataTask error - " + error!.localizedDescription)
                return
            }
         
            guard let data = data else {
                onFailure("URLSessionDataTask data - Unable to retrieve data")
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    onFailure(response.debugDescription)
                    return
                }
            }
            onSuccess(data)
            return
        })
        task.resume()
    }
}
