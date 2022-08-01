//
//  ProfileData.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 11.02.2022.
//

import Foundation

struct ProfileData: Codable {
    var statusCode: Int
    var body: ProfileBody
}

struct ProfileBody: Codable {
    var name: String
    var surname: String
    var email: String
}
