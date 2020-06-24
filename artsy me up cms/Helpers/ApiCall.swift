//
//  ApiCall.swift
//  artsy me up cms
//
//  Created by Ruli on 24/06/20.
//

import UIKit

class ApiCall {
    let baseUrl: String = "https://cms-commerce.herokuapp.com/"
    var method: String
    var endPoint: String
    var data: String?
    var type: TypeModel
    var header: String?
    
    init(method: String, endPoint: String, data: String?, type: TypeModel, header: String?) {
        self.method = method
        self.endPoint = endPoint
        self.data = data
        self.type = type
        self.header = header
    }
    
    func getData(completion: @escaping (Result<(User?, [Product]?, Product?), Error>) -> Void) {
        guard let url = URL(string: baseUrl + endPoint) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(header, forHTTPHeaderField: "access_token")
        
        if let body = data {
            let postString = body
            request.httpBody = postString.data(using: .utf8)
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, err) in
            if let err = err {
                completion(.failure(err))
                return
            }
            //     succes
            switch self.type {
            case .user:
                do {
                    let user: User = try JSONDecoder().decode(User.self, from: data!)
                    completion(.success((user, nil, nil)))
                } catch let jsonError {
                    completion(.failure(jsonError))
                }
            case .products:
                do {
                    let products: [Product] = try JSONDecoder().decode([Product].self, from: data!)
                    completion(.success((nil, products, nil)))
                } catch let jsonError {
                    completion(.failure(jsonError))
                }
            case .product:
                do {
                    let product: Product = try JSONDecoder().decode(Product.self, from: data!)
                    completion(.success((nil, nil, product)))
                } catch let jsonError {
                    completion(.failure(jsonError))
                }
            }
        }
        .resume()
    }
}
