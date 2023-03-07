//
//  ProductListMother.swift
//  CabifyShopTests
//
//  Created by Paul Alvarez on 4/03/23.
//

import Foundation
@testable import CabifyShop

struct ProductResponseListMother {
    static let defaultProductResponseList: [ProductResponse] = [
        ProductResponse(code: ProductCodes.voucher.rawValue, name: "Cabify Voucher", price: 5.0),
        ProductResponse(code: ProductCodes.tShirt.rawValue, name: "Cabify T-Shirt", price: 20.0),
        ProductResponse(code: ProductCodes.mug.rawValue, name: "Cabify Cofee Mug", price: 7.5)
    ]

    static let emptyProductResponseList = [ProductResponse]()
    
    static let voucherProductResponseList = [ProductResponse(code: ProductCodes.voucher.rawValue,
                                                             name: "Cabify Voucher",
                                                             price: 5.0)]

    static let tShirtProductResponseList = [ProductResponse(code: ProductCodes.tShirt.rawValue,
                                                         name: "Cabify T-Shirt",
                                                         price: 2.0)]

    static let mugProductResponseList = [ProductResponse(code: ProductCodes.mug.rawValue,
                                                         name: "Cabify Cofee Mug",
                                                         price: 7.5)]

    static let newProductResponseList = [ProductResponse(code: "NEW",
                                                         name: "Cabify New Product",
                                                         price: 2.0)]
}
