//
//  ExchangeData.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 8.03.2022.
//

import Foundation

struct ExchangeDataResponse: Codable {
    var statusCode: Int
    var data: [ExchangeData]
}

struct ExchangeData: Codable {
    var Name: String
    var Code: String
    var OperatingMIC: String?
    var Country: String
    var Currency: String
}

