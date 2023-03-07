//
//  ProductsService.swift
//  CabifyShop
//
//  Created by Paul Alvarez on 27/02/23.
//

import Foundation

protocol ProductService {
    func getProductsFromAPI() async throws -> ProductListResponse
}

class ProductsServiceImp: ProductService {
    let baseURL = "https://gist.githubusercontent.com/palcalde/6c19259bd32dd6aafa327fa557859c2f/raw/ba51779474a150ee4367cda4f4ffacdcca479887"

    func getProductsFromAPI() async throws -> ProductListResponse {
        let productsPath = "/Products.json"
        let productsURL = URL(string: baseURL + productsPath)!

        let (data, _) = try await URLSession.shared.data(from: productsURL)

        let decodedData = try JSONDecoder().decode(ProductListResponse.self, from: data)
        return decodedData
    }
}
