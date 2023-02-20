//
//  ProductListViewModel.swift
//  CabifyShop
//
//  Created by Paul Alvarez on 20/02/23.
//

import Foundation
import Combine

class ProductListViewModel {
    enum Input {
        case viewDidLoad
        case onProductCellEvent(event: ProductCellEvent, product: Product)
    }

    enum Output {
        case updateList
    }

    private let output = PassthroughSubject<ProductListViewModel.Output, Never>()
    private var cancellables = Set<AnyCancellable>()

    var productList = [Product]()
    private var cart = Cart()

    var totalQuantities: Int {
        cart.products.map{ $0.quantity }.reduce(0, +)
    }

    var totalPrice: Double {
        cart.products.map{ $0.totalPrice }.reduce(0, +)
    }

    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [unowned self] event in
            switch event {
            case .viewDidLoad:
                getProductList()
                DispatchQueue.main.async {
                    output.send(.updateList)
                }
                break
            case .onProductCellEvent(let event, let product):
                switch event {
                case .quantityDidChange(let action):
                    cart.handleAction(on: product, for: action)
                    handleActionOnProductList(on: product)
                    DispatchQueue.main.async {
                        output.send(.updateList)
                    }
                break
                }
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }

    private func handleActionOnProductList(on product: Product) {
        guard let index = productList.firstIndex(where: { $0.code == product.code }) else { return }

        if let cartProduct = cart.products.first(where: { $0.code == product.code }) {
            productList[index] = Product(from: cartProduct)
        } else {
            // TODO: Fix not having cartProduct's discountedPrice before removing it
            productList[index].discountedPrice = productList[index].originalPrice
            productList[index].quantity = "0"
        }
    }

    private func getProductList() {
        let productListResponse = Bundle.main.decode(ProductListResponse.self, from: "Products.json")
        productListResponse.products.forEach { [weak self] product in
            self?.productList.append(Product(name: product.name,
                                             code: product.code,
                                             originalPrice: product.price.formatAsStringPrice()))
        }
    }
}
