//
//  KeyChainManager.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 12.11.2022.
//

import Foundation
import Security
import UIKit

struct Session: Codable {
    let session: String
}

struct Token: Codable {
    let token: String
}

struct Credentials: Codable {
    let email: String
    let password: String
}

enum Service {
    case session
    case token
}

class KeyChainManager {
    
    static let shared = KeyChainManager()
    private let service_session = "pport-session"
    private let service_token = "pport-token"
    private let service_credentials = "pport-credentials"
    private let domain = "com.pport-akmami"
    
    // MARK: Generic Functions
    func save<T>(_ item: T, service: Service) where T : Codable {
        
        switch service {
        case .session:
            do {
                let data = try JSONEncoder().encode(item)
                save(data, service: service_session, domain: domain)
            } catch {
                NSLog("Fail to decode session for keychain(save): \(error)", "")
            }
        case .token:
            do {
                let data = try JSONEncoder().encode(item)
                save(data, service: service_token, domain: domain)
            } catch {
                NSLog("Fail to decode token for keychain(save): \(error)", "")
            }
        }
    }
    
    func read<T>(service: Service, type: T.Type) -> T? where T : Codable {
        
        switch service {
        case .session:
            guard let data = read(service: service_session, domain: domain) else {
                return nil
            }
            
            do {
                let item = try JSONDecoder().decode(type, from: data)
                return item
            } catch {
                NSLog("Fail to decode session for keychain(read): \(error)", "")
                return nil
            }
        case .token:
            guard let data = read(service: service_token, domain: domain) else {
                return nil
            }
            do {
                let item = try JSONDecoder().decode(type, from: data)
                return item
            } catch {
                NSLog("Fail to decode token for keychain(read): \(error)", "")
                return nil
            }
        }
    }
}

extension KeyChainManager {
    
    // MARK: - Private functions
    private func save(_ data: Data, service: String, domain: String) {
        
        let query = [
            kSecValueData: data,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: domain,
        ] as CFDictionary
        
        let status = SecItemAdd(query, nil)
        
        switch status {
        case errSecSuccess:
            break
        case errSecDuplicateItem:
            let query = [
                kSecAttrService: service,
                kSecAttrAccount: domain,
                kSecClass: kSecClassGenericPassword,
            ] as CFDictionary

            let attributesToUpdate = [kSecValueData: data] as CFDictionary
            
            SecItemUpdate(query, attributesToUpdate)
            break
        default:
            NSLog("Keychain error: \(status)", "")
            break
        }
    }

    private func read(service: String, domain: String) -> Data? {
        
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: domain,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true
        ] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        
        return (result as? Data)
    }
    
    // MARK: - Public functions
    func delete(service: String, domain: String) {
        
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: domain,
            kSecClass: kSecClassGenericPassword,
            ] as CFDictionary
        
        SecItemDelete(query)
    }
    
    func removeAll() {
        delete(service: service_token, domain: domain)
        delete(service: service_session, domain: domain)
        delete(service: service_credentials, domain: domain)
    }
}
