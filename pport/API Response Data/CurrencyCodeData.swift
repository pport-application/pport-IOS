//
//  CurrencyCodeData.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 24.03.2022.
//

import Foundation

struct CurrencyCodeData: Codable {
    var Code: String
    var Name: String
    var Country: String
    var Exchange: String
    var `Type`: String
    var ISIN: String?
}

