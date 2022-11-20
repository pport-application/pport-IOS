//
//  PortfolioData.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 6.11.2022.
//

import Foundation


struct PortfolioData: Codable {
    var wallet: [String:Float]
    var portfolio: [Portfolio]
}

struct Portfolio: Codable {
    var ticker: String
    var count: Float
    var balance: Float
    var currency: String
}
