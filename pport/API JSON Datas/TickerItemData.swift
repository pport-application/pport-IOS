//
//  TickerItemData.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 4.03.2022.
//

import Foundation
import CoreText

struct TickerItemDataResponse: Codable {
    var statusCode: Int
    var data: [TickerItem]
}

struct TickerItem: Codable {
    var low: String
    var previousClose: String
    var close: String
    var change: String
    var change_p: String
    var code: String
    var open: String
    var timestamp: String
    var volume: String
    var high: String
}
