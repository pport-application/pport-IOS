//
//  CurrencyData.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 24.03.2022.
//

import Foundation

struct CurrencyDataResponse: Codable {
    var statusCode: Int
    var data: [CurrencyData]
}

struct CurrencyData: Codable {
    var Code: String
    var Name: String
    var Country: String
    var Exchange: String
    var Currency: String
    var `Type`: String
    var Isin: String?
}

