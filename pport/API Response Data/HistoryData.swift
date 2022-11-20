//
//  HistoryData.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 6.11.2022.
//

import Foundation

struct WalletHistoryData: Decodable {
    var from: String
    var amount: Float
    var currency: String
    var type: Int
    var balance: Float
    var timestamp: Int
}

struct PortfolioHistoryData: Decodable {
    var from: String
    var ticker: String
    var count: Float
    var revenue: Float
    var currency: String
    var type: Int
    var balance: Float
    var timestamp: Int64
}

enum HistoryData: Decodable {
    
    case wallet(WalletHistoryData)
    case portfolio(PortfolioHistoryData)
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case from = "from"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let singleContainer = try decoder.singleValueContainer()
        
        let from = try container.decode(String.self, forKey: .from)
        switch from {
        case "wallet":
            let wallet = try singleContainer.decode(WalletHistoryData.self)
            self = .wallet(wallet)
            return
        case "portfolio":
            let portfolio = try singleContainer.decode(PortfolioHistoryData.self)
            self = .portfolio(portfolio)
            return
        default:
            throw DecodingError.valueNotFound(Self.self, DecodingError.Context(codingPath: CodingKeys.allCases, debugDescription: "wallet/portfolio not found"))
        }
    }
}
