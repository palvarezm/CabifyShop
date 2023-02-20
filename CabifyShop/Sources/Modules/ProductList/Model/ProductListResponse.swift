//
//  ProductListResponse.swift
//  CabifyShop
//
//  Created by Paul Alvarez on 20/02/23.
//

import Foundation

struct ProductListResponse: Decodable {
    var products: [ProductResponse]
}

struct ProductResponse: Decodable {
    let code: String
    let name: String
    let price: Double
}
