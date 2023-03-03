//
//  String+Extension.swift
//  CabifyShop
//
//  Created by Paul Alvarez on 20/02/23.
//

import Foundation

extension String {
    // MARK: - Language string assets
    var localized: String {
        return NSLocalizedString(self, comment: "\(self)_comment")
    }
    
    func localized(_ args: CVarArg...) -> String {
        return String(format: localized, args)
    }

    // MARK: - Formatter
    static let pricePrefix = "€ "

    func formatFromStringPrice() -> Double {
        let priceString = self.replacingOccurrences(of: String.pricePrefix, with: "")
        return Double(priceString) ?? 0.0
    }
}
