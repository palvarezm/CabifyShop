//
//  Cart.swift
//  CabifyShop
//
//  Created by Paul Alvarez on 20/02/23.
//

import Foundation

// MARK: - ProductCart
struct ProductCart {
    let id: UUID
    let code: String
    let name: String
    let originalPrice: Double
    var discount: Double = 0
    var discountedPrice: Double {
        originalPrice - discount
    }
    var quantity: Int = 0
    var totalPrice: Double {
        discountedPrice * Double(quantity)
    }

    init(from product: Product) {
        self.id = product.id
        self.code = product.code
        self.name = product.name
        self.originalPrice = Double(product.originalPrice.formatFromFormattedPrice())
    }
}

// MARK: - Cart
class Cart {
    var products: [ProductCart]
    var totalPrice: Double {
        products.map { $0.totalPrice }.reduce(0, +)
    }
    var totalDiscount: Double {
        products.map { $0.discount }.reduce(0, +)
    }
    var totalPriceWithDiscounts: Double {
        totalPrice - totalDiscount
    }

    init(products: [ProductCart] = []) {
        self.products = products
    }

    private func handleDeals(for action: ProductQuantityAction, on product: ProductCart) -> ProductCart {
        var newProduct = product
        var totalDiscount = 0.0
        Deals.allCases.forEach { deals in
            switch deals {
            case .twoForOneVoucher:
                guard deals.codes.map({ $0.rawValue }).contains(product.code) else { break }

                let quantityModifier = action == .add
                                        ? deals.quantityModifier
                                        : -deals.quantityModifier
                newProduct.quantity += quantityModifier
                totalDiscount += product.quantity == 0 ? 0 : product.originalPrice / 2
            case .moreThanThreeTShirt:
                guard deals.codes.map({ $0.rawValue }).contains(product.code) else { break }

                if product.quantity >= 3 {
                    totalDiscount += deals.discount
                }
            }
        }
        newProduct.discount = totalDiscount
        
        return newProduct
    }

    func handleAction(on product: Product, for action: ProductQuantityAction) {
        if action == .add {
            let index = products.firstIndex(where: { $0.code == product.code })
            if index == nil {
                products.append(ProductCart(from: product))
            }
            let safeIndex = index ?? products.count - 1
            products[safeIndex].quantity += 1
            products[safeIndex] = handleDeals(for: action, on: products[safeIndex])
        } else if action == .decrease,
                  let index = products.firstIndex(where: { $0.code == product.code }) {
            products[index].quantity -= 1
            products[index] = handleDeals(for: action, on: products[index])
            if products[index].quantity <= 0 {
                products.remove(at: index)
            }
        }
    }
}
