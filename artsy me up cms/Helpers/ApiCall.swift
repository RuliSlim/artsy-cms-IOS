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
    var data: (Login?, UploadProduct?)?
    var type: TypeModel
    var header: String?
    
    init(method: String, endPoint: String, data: (Login?, UploadProduct?)?, type: TypeModel, header: String?) {
        self.method = method
        self.endPoint = endPoint
        self.data = data
        self.type = type
        self.header = header
    }
    
    func getData(completion: @escaping (Result<(User?, [Product]?, Product?, CustomErrApi?), Error>) -> Void) {
        guard let url = URL(string: baseUrl + endPoint) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(header, forHTTPHeaderField: "access_token")
        
        if let body = data {
            if data!.0 != nil {
                guard let jsonData = try? JSONEncoder().encode(body.0) else {
                    print("Error: Trying to convert model to JSON data")
                    return
                }
                request.httpBody = jsonData
            } else {
                guard let jsonData = try? JSONEncoder().encode(body.1) else {
                    print("Error: Trying to convert model to JSON data")
                    return
                }
                request.httpBody = jsonData
            }
            
            request.setValue("application/json", forHTTPHeaderField: "Content-Type") // the request is JSON
            request.setValue("application/json", forHTTPHeaderField: "Accept") // the response expected to be
        }
                
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, err) in
            if let err = err {
                print(err, "err di apical")
                completion(.failure(err))
                return
            }
            
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 500...599:
                    do {
                        let err = try JSONDecoder().decode(CustomErrApi.self, from: data!)
                        completion(.success((nil, nil, nil, err)))
                    } catch let jsonErr {
                        completion(.failure(jsonErr))
                    }
                    return
                default:
                    break
                }
            }
            
            switch self.type {
            case .user:
                do {
                    let user: User = try JSONDecoder().decode(User.self, from: data!)
                    completion(.success((user, nil, nil, nil)))
                } catch let jsonError {
                    print(jsonError, "err dijson")
                    completion(.failure(jsonError))
                }
            case .products:
                do {
                    let products: [Product] = try JSONDecoder().decode([Product].self, from: data!)
                    completion(.success((nil, products, nil, nil)))
                } catch let jsonError {
                    completion(.failure(jsonError))
                }
            case .product:
                do {
                    let product: Product = try JSONDecoder().decode(Product.self, from: data!)
                    completion(.success((nil, nil, product, nil)))
                } catch let jsonError {
                    completion(.failure(jsonError))
                }
            case .edit:
                completion(.success((nil, nil, nil, nil)))
            }
        }
        .resume()
    }
}
