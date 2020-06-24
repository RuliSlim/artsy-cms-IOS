//
//  Models.swift
//  artsy me up cms
//
//  Created by Ruli on 21/06/20.
//

import UIKit

struct Item {
    var title: String
    var price: Int
    var stock: Int
    var description: String
    var photo: UIImage
}

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

struct LoginUserInfo {
    var email: String
    var password: String
}

enum TypeModel {
    case user
    case products
    case product
}
