//
//  DummyItem.swift
//  artsy me up cms
//
//  Created by Ruli on 21/06/20.
//

import UIKit

var items: [Item] = [
    Item(title: "Luden", price: 1300000, stock: 40, description: "FAG Ludens", photo: UIImage(named: "ludens")!),
    Item(title: "Stylet", price: 1105000, stock: 40, description: "FAG Stylet", photo: UIImage(named: "stylet")!),
    Item(title: "Rufus", price: 700000, stock: 20, description: "FAG Rufus", photo: UIImage(named: "rufus")!),
    Item(title: "Jinrai", price: 1250000, stock: 30, description: "FAG Jinrai", photo: UIImage(named: "jinrai")!),
    Item(title: "Ater", price: 1000000, stock: 40, description: "FAG Ater", photo: UIImage(named: "ater")!),
    Item(title: "Baihu", price: 1050000, stock: 40, description: "FAG Baihu", photo: UIImage(named: "baihu")!),
    Item(title: "Gaogaigar", price: 1300000, stock: 40, description: "FAG Gaogaigar", photo: UIImage(named: "gaogaigar")!),
    Item(title: "Xf-3", price: 1300000, stock: 40, description: "FAG Xf-3", photo: UIImage(named: "xf-3")!),
    Item(title: "Zelfikar", price: 1300000, stock: 40, description: "FAG Zelfikar", photo: UIImage(named: "zelfikar")!),
    Item(title: "Miku", price: 1300000, stock: 40, description: "FAG Miku", photo: UIImage(named: "miku")!),
    Item(title: "Gourai", price: 1300000, stock: 40, description: "FAG Gourai", photo: UIImage(named: "gourai")!)
]

class ApiCall {
    let baseUrl: String = "https://cms-commerce.herokuapp.com/"
    var realUrl: String = ""
    
    //    var url: URL = ""
    
    //    func getTest(method: String, endPoint: String) {
    //        print(baseUrl, method, endPoint)
    //
    //    }
    var newUrl: String {
        get {
            return realUrl
        }
        set (endPoint) {
            realUrl = self.baseUrl + endPoint
        }
    }
    
    func getData(method: String, endPoint: String, completion: @escaping (Result<[Product], Error>) -> Void) {
//        let baseUrl: String = "https://cms-commerce.herokuapp.com/"
        guard let url = URL(string: self.baseUrl + endPoint) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            if let err = err {
                completion(.failure(err))
                return
            }
            //     succes
            do {
                let products: [Product] = try JSONDecoder().decode([Product].self, from: data!)
                completion(.success(products))
            } catch let jsonError {
                completion(.failure(jsonError))
            }
        }
        .resume()
    }
}


/*
 fileprivate func getData(method: String, endPoint: String, completion: @escaping (Result<[Product], Error>) -> ()) {
 let baseUrl: String = "https://cms-commerce.herokuapp.com/"
 guard let url = URL(string: baseUrl + endPoint) else { return }
 
 URLSession.shared.dataTask(with: url) { (data, response, err) in
 if let err = err {
 completion(.failure(err))
 return
 }
 
 //            succes
 do {
 let products: [Product] = try JSONDecoder().decode([Product].self, from: data!)
 completion(.success(products))
 } catch let jsonError {
 completion(.failure(jsonError))
 }
 }
 .resume()
 }
 
 */
