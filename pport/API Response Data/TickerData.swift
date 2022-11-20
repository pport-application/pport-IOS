//
//  TickerData.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 2.03.2022.
//

import Foundation

struct TickerData: Codable {
    var Code: String
    var Name: String
    var Country: String
    var Exchange: String
    var Currency: String
    var `Type`: String
    var Isin: String?
}
