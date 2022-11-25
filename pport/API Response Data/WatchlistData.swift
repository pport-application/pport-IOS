//
//  WatchlistData.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 4.03.2022.
//

import Foundation

struct WatchlistData: Codable {
    var code: String
    var timestamp: Int64?
    var gmtoffset: Float?
    var open: Float?
    var high: Float?
    var low: Float?
    var close: Float?
    var volume: Int64?
    var previousClose: Float?
    var change: Float?
    var change_p: Float?
    
    private enum WatchlistDataKeys: String, CodingKey {
        case code = "code"
        case timestamp = "timestamp"
        case gmtoffset = "gmtoffset"
        case open = "open"
        case high = "high"
        case low = "low"
        case close = "close"
        case volume = "volume"
        case previousClose = "previousClose"
        case change = "change"
        case change_p = "change_p"
    }
    
    init(code: String, timestamp: Int64?, gmtoffset: Float?, open: Float?, high: Float?, low: Float?,
         close: Float?, volume: Int64?, previousClose: Float?, change: Float?, change_p: Float) {
        self.code = code
        self.timestamp = timestamp
        self.gmtoffset = gmtoffset
        self.open = open
        self.high = high
        self.low = low
        self.close = close
        self.volume = volume
        self.previousClose = previousClose
        self.change = change
        self.change_p = change_p
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try container.decode(String.self, forKey: .code)
        do {
            self.timestamp = try container.decode(Int64.self, forKey: .timestamp)
        } catch DecodingError.typeMismatch {
            self.timestamp = nil
        }
        do {
            self.gmtoffset = try container.decode(Float.self, forKey: .gmtoffset)
        } catch DecodingError.typeMismatch {
            self.gmtoffset = nil
        }
        do {
            self.open = try container.decode(Float.self, forKey: .open)
        } catch DecodingError.typeMismatch {
            self.open = nil
        }
        do {
            self.high = try container.decode(Float.self, forKey: .high)
        } catch DecodingError.typeMismatch {
            self.high = nil
        }
        do {
            self.low = try container.decode(Float.self, forKey: .low)
        } catch DecodingError.typeMismatch {
            self.low = nil
        }
        do {
            self.close = try container.decode(Float.self, forKey: .close)
        } catch DecodingError.typeMismatch {
            self.close = nil
        }
        do {
            self.volume = try container.decode(Int64.self, forKey: .volume)
        } catch DecodingError.typeMismatch {
            self.volume = nil
        }
        do {
            self.previousClose = try container.decode(Float.self, forKey: .previousClose)
        } catch DecodingError.typeMismatch {
            self.previousClose = nil
        }
        do {
            self.change = try container.decode(Float.self, forKey: .change)
        } catch DecodingError.typeMismatch {
            self.change = nil
        }
        do {
            self.change_p = try container.decode(Float.self, forKey: .change_p)
        } catch DecodingError.typeMismatch {
            self.change_p = nil
        }
    }
}
