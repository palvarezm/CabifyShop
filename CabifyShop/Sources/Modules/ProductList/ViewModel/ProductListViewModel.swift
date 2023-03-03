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
        case showViewForEmptyList
        case showDeals(product: Product)
    }

    private let output = PassthroughSubject<ProductListViewModel.Output, Never>()
    private var cancellables = Set<AnyCancellable>()

    var productService: ProductService
    var productList = [Product]()
    private var cart = Cart()

    var totalQuantities: Int {
        cart.products.map{ $0.quantity }.reduce(0, +)
    }

    var totalPrice: Double {
        cart.totalPrice
    }

    var cartDetails: String {
        var cartProducts = [String]()
        cart.products.forEach { cartProducts.append("\($0.name)(\($0.quantity)) -> \($0.totalPrice.formatAsStringPrice())") }
        return cartProducts.joined(separator: "\n")
    }

    init(productService: ProductService = ProductsServiceImp()) {
        self.productService = productService
    }

    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [unowned self] event in
            switch event {
            case .viewDidLoad:
                Task {
                    await updateViewFromService()
                }
                break
            case .onProductCellEvent(let event, let product):
                switch event {
                case .quantityDidChange(let action):
                    cart.handleAction(on: product, for: action)
                    handleActionOnProductList(on: product)
                    output.send(.updateList)
                break
                case .tooltipTapped:
                    output.send(.showDeals(product: product))
                }
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }

    private func handleActionOnProductList(on product: Product) {
        guard let index = productList.firstIndex(where: { $0.code == product.code }) else { return }

        // Find the product on the cart
        if let cartProduct = cart.products.first(where: { $0.code == product.code }) {
            productList[index] = Product(from: cartProduct)
        } else {
            // If product isn't found on cart, its deleted and we need to revert it to its original state
            productList[index].discountedPrice = productList[index].originalPrice
            productList[index].quantity = "0"
        }
    }

    private func updateViewFromService() async {
        do {
            let productListResponse = try await productService.getProductsFromAPI()
            productListResponse.products.forEach {
                productList.append(Product(name: $0.name,
                                           code: $0.code,
                                           originalPrice: $0.price.formatAsStringPrice()))
            }
            let outputValue: Output = productListResponse.products.isEmpty
                                    ? .showViewForEmptyList
                                    : .updateList
                output.send(outputValue)
        } catch {
                output.send(.showViewForEmptyList)
        }
    }
}
