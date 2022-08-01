//
//  NetworkManager.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 20.02.2022.
//

import Foundation
import Network

class NetworkManager: NSObject {
    static let shared: NetworkManager = NetworkManager()
    
    func check(isAvailable: @escaping () -> Void, notAvailable: @escaping () -> Void) {
        let monitor = NWPathMonitor()
        
        monitor.pathUpdateHandler = { pathUpdateHandler in
            if pathUpdateHandler.status == .satisfied {
                NSLog("Internet connection is on.", "")
                isAvailable()
            } else {
                NSLog("There's no internet connection.", "")
                notAvailable()
            }
            
        }
    }
}
