//
//  ArrayExtension.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 8.03.2022.
//

import Foundation

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
