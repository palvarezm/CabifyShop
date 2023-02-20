//
//  Double+Extension.swift
//  CabifyShop
//
//  Created by Paul Alvarez on 20/02/23.
//

import Foundation

extension Double {
    func formatAsStringPrice() -> String {
        return String.pricePrefix + String(format: "%.2f", self)
    }
}
