//
//  SignInData.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 10.02.2022.
//

import Foundation

struct SignInData: Codable {
    var name: String
    var surname: String
    var email: String
    var session: String
    var watchlist: [String]
    var token: String
}
