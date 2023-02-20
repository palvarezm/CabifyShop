//
//  Deals.swift
//  CabifyShop
//
//  Created by Paul Alvarez on 20/02/23.
//

import Foundation

// MARK: - ProductCodes
enum ProductCodes: String {
    case voucher = "VOUCHER"
    case tShirt = "TSHIRT"
    case mug = "MUG"
}

// MARK: - Deals
enum Deals: CaseIterable {
    case twoForOneVoucher
    case moreThanThreeTShirt

    var codes: [ProductCodes] {
        switch self {
        case .twoForOneVoucher: return [.voucher]
        case .moreThanThreeTShirt: return [.tShirt]
        }
    }

    var discount: Double {
        switch self {
        case .twoForOneVoucher: return 0
        case .moreThanThreeTShirt: return 1.0
        }
    }

    var discountInfoTooltip: String? {
        switch self {
        case .twoForOneVoucher: return "2-for-1: Buy 2, get 1 free"
        case .moreThanThreeTShirt: return "Buy 3+, get € 1 discount"
        }
    }

    var quantityModifier: Int {
        switch self {
        case .twoForOneVoucher: return 1
        case .moreThanThreeTShirt: return 0
        }
    }
}
