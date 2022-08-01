//
//  LoginData.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 10.02.2022.
//

import Foundation

struct LoginData: Codable {
    var statusCode: Int
    var body: LoginBody
}

struct LoginBody: Codable {
    var user_id: String
    var session: String
    var name: String
    var surname: String
    var email: String
}
