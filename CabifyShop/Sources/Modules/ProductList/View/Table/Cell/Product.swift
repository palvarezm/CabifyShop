//
//  Product.swift
//  CabifyShop
//
//  Created by Paul Alvarez on 20/02/23.
//

import Foundation

struct Product {
    let id: UUID
    let code: String
    let name: String
    let originalPrice: String
    var discountedPrice: String
    var quantity: String
    var dealsInfo: DealsInfo? {
        guard let code = ProductCodes.allCases.filter({ $0.rawValue == code }).first  else { return nil }

        let title = "\(name) " + "product_list_deals_info_alert_title".localized
        let discountInfoArray = Deals.allCases.filter({ $0.codes.contains(code) }).map { $0.discountInfo }
        let dealsList = discountInfoArray.joined(separator: "\n")
        return DealsInfo(title: title, deals: dealsList)
    }

    struct DealsInfo {
        let title: String
        let deals: String
    }

    init(name: String, code: String, originalPrice: String) {
        self.id = UUID()
        self.code = code
        self.name = name
        self.originalPrice = originalPrice
        self.discountedPrice = originalPrice
        self.quantity = "0"
    }

    init(from productCart: ProductCart) {
        self.id = productCart.id
        self.code = productCart.code
        self.name = productCart.name
        self.originalPrice = productCart.originalPrice.formatAsStringPrice()
        self.discountedPrice = productCart.discountedPrice.formatAsStringPrice()
        self.quantity = String(productCart.quantity)
    }
}
