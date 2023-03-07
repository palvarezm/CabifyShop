//
//  Deals.swift
//  CabifyShop
//
//  Created by Paul Alvarez on 20/02/23.
//

import Foundation

// MARK: - ProductCodes
enum ProductCodes: String, CaseIterable {
    case voucher = "VOUCHER"
    case tShirt = "TSHIRT"
    case mug = "MUG"
}

// MARK: - Deals
enum Deals: CaseIterable {
    case twoForOneVoucher
    case moreThanThreeTShirt

    static let codesWithDeals: [ProductCodes] = Array(Set(Deals.allCases.flatMap { $0.codes }))

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

    var quantityModifier: Int {
        switch self {
        case .twoForOneVoucher: return 1
        case .moreThanThreeTShirt: return 0
        }
    }

    var discountInfo: String {
        switch self {
        case .twoForOneVoucher: return "two_for_one_deal_info".localized
        case .moreThanThreeTShirt: return "more_than_three_tShirt_deal_info".localized
        }
    }
}
