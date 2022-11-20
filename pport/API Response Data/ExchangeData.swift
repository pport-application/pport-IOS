//
//  ExchangeData.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 8.03.2022.
//

import Foundation

struct ExchangeData: Codable {
    var Name: String
    var Code: String
    var OperatingMIC: String?
    var Country: String
    var Currency: String
    var CountryISO2: String?
    var CountryISO3: String?
}

