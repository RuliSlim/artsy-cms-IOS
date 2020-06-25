//
//  Models.swift
//  artsy me up cms
//
//  Created by Ruli on 21/06/20.
//

import UIKit

struct Product: Decodable, Identifiable {
    var id: Int
    var name: String
    var image: URL
    var price: String
    var stock: Int
    var createdAt: String
    var updatedAt: String
}

struct User: Decodable {
    var access_token: String?
    var role: String?
}

struct Login: Codable {
    let email: String
    let password: String
}

struct UploadProduct: Codable {
    let name: String
    let image: String
    let price: Int
    let stock: Int
}

enum TypeModel {
    case user
    case products
    case product
    case edit
}
