//
//  ProductMother.swift
//  CabifyShopTests
//
//  Created by Paul Alvarez on 4/03/23.
//

@testable import CabifyShop

struct ProductMother {
    static let voucher = Product(name: "Cabify Voucher",
                                 code: ProductCodes.voucher.rawValue,
                                 originalPrice: 5.00.formatAsStringPrice())

    static let tShirt = Product(name: "Cabify T-Shirt",
                                code: ProductCodes.tShirt.rawValue,
                                originalPrice: 20.00.formatAsStringPrice())

    static let mug = Product(name: "Cabify Mug",
                             code: ProductCodes.mug.rawValue,
                             originalPrice: 7.50.formatAsStringPrice())

    static let new = Product(name: "Cabify New Product",
                             code: "NEW",
                             originalPrice: 2.00.formatAsStringPrice())
}
