//
//  CabifyShopTests.swift
//  CabifyShopTests
//
//  Created by Paul Alvarez on 20/02/23.
//

import XCTest
import Combine
@testable import CabifyShop

final class ProductListViewModelTests: XCTestCase {

    private var sut: ProductListViewModel!
    private var productService: ProductServiceMock!
    private var cart: Cart!

    private var viewControllerOutput = PassthroughSubject<ProductListViewModel.Input, Never>()
    private var viewModelOutput: AnyPublisher<ProductListViewModel.Output, Never>!
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        productService = ProductServiceMock()
        cart = Cart()
        sut = .init(productService: productService, cart: cart)
        viewModelOutput = sut.transform(input: viewControllerOutput.eraseToAnyPublisher())
    }

    override func tearDown() {
        super.tearDown()
        productService = nil
        cart = nil
        sut = nil
        viewModelOutput = nil
        viewControllerOutput = PassthroughSubject<ProductListViewModel.Input, Never>()
        cancellables = Set<AnyCancellable>()
    }

    func testServiceIsCalledWhenViewDidLoad() throws {
        // Given
        let expectation = XCTestExpectation(description: "Fetch has been called")

        // When
        viewModelOutput.sink { _ in }.store(in: &cancellables)
        productService.expectation = expectation
        viewControllerOutput.send(.viewDidLoad)

        //Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(productService.fetchCallCounter, 1)
    }

    func testFirstProductFromDefaultProductList() throws {
        // Given
        productService.mockedProductList = ProductListResponse(products: ProductResponseListMother.defaultProductResponseList)
        let updateProductListExpectation = XCTestExpectation(description: "Update products input was called")

        // Then
        viewModelOutput.sink { [weak self] event in
            switch event {
            case .updateList:
                XCTAssertEqual(self?.sut.productList.count, 3)
                XCTAssertEqual(self?.sut.productList.first?.name, "Cabify Voucher")
                XCTAssertEqual(self?.sut.productList.first?.code, ProductCodes.voucher.rawValue)
                XCTAssertEqual(self?.sut.productList.first?.originalPrice, 5.0.formatAsStringPrice())
                updateProductListExpectation.fulfill()
                break
            default:
                break
            }
        }.store(in: &cancellables)

        // When
        viewControllerOutput.send(.viewDidLoad)
        wait(for: [updateProductListExpectation], timeout: 1.0)
    }

    func testShowViewFromEmptyListGivenEmptyResponse() throws {
        // Given
        productService.mockedProductList = ProductListResponse(products: ProductResponseListMother.emptyProductResponseList)

        let emptyProductListExpectation = XCTestExpectation(description: "Set products input was called")

        // Then
        viewModelOutput.sink { [weak self] event in
            switch event {
            case .showViewForEmptyList:
                XCTAssertEqual(self?.sut.productList.count, 0)
                emptyProductListExpectation.fulfill()
                break
            default:
                break
            }
        }.store(in: &cancellables)

        // When
        viewControllerOutput.send(.viewDidLoad)
        wait(for: [emptyProductListExpectation], timeout: 1.0)
    }

    func testUpdateViewModelWhenProductWithoutDealsIsAddedToCart() {
        // Given
        let addedProduct = ProductMother.new

        // Then
        viewModelOutput.sink { [unowned self] event in
            if case .updateList = event {
                XCTAssertEqual(sut.totalQuantities, 1)
                XCTAssertEqual(sut.totalPrice, ProductMother.new.originalPrice.formatFromStringPrice())
                XCTAssertEqual(sut.cartDetails.isEmpty, false)
            }
        }.store(in: &cancellables)

        // When
        viewControllerOutput.send(.onProductCellEvent(event: .quantityDidChange(action: .add),
                                                      product: addedProduct))
    }

    func testUpdateViewModelWhenTwoForOneDealIsApplied() {
        // Given
        let addedProduct = ProductMother.voucher

        // Then
        viewModelOutput.sink { [unowned self] event in
            if case .updateList = event {
                XCTAssertEqual(sut.totalQuantities, 1 + Deals.twoForOneVoucher.quantityModifier)
                XCTAssertEqual(sut.totalPrice, addedProduct.originalPrice.formatFromStringPrice())
                XCTAssertEqual(sut.cartDetails.isEmpty, false)
            }
        }.store(in: &cancellables)

        // When
        viewControllerOutput.send(.onProductCellEvent(event: .quantityDidChange(action: .add),
                                                      product: addedProduct))
    }

    func testUpdateViewModelWhenTwoForOneDealIsRemoved() {
        // Given
        let product = ProductMother.voucher
        viewControllerOutput.send(.onProductCellEvent(event: .quantityDidChange(action: .add),
                                                      product: product))

        // Then
        viewModelOutput.sink { [weak self] event in
            if case .updateList = event {
                XCTAssertEqual(self?.sut.totalPrice, 0)
                XCTAssertEqual(self?.sut.totalQuantities, 0)
                XCTAssertEqual(self?.sut.cartDetails.isEmpty, true)
            }
        }.store(in: &cancellables)

        // When
        viewControllerOutput.send(.onProductCellEvent(event: .quantityDidChange(action: .decrease),
                                                      product: product))
    }

    func testUpdateViewModelWhenMoreThanThreeDealIsApplied() {
        // Given
        let addedProduct = ProductMother.tShirt
        let desiredQuantity = 3

        // Then
        viewModelOutput.sink { [weak self] event in
            if case .updateList = event {
                guard let cartProduct = self?.cart.products.first else {
                    XCTFail("self is nil")
                    return
                }

                XCTAssertEqual(self?.sut.totalQuantities, cartProduct.quantity)
                let totalPrice = cartProduct.discountedPrice * Double(cartProduct.quantity)
                XCTAssertEqual(self?.sut.totalPrice, totalPrice)
                XCTAssertEqual(self?.sut.cartDetails.isEmpty, false)
            }
        }.store(in: &cancellables)

        // When
        for _ in 1...desiredQuantity {
            viewControllerOutput.send(.onProductCellEvent(event: .quantityDidChange(action: .add),
                                                          product: addedProduct))
        }
    }

    func testUpdateViewModelWhenMoreThanThreeDealIsRemoved() {
        // Given
        let product = ProductMother.tShirt
        let desiredQuantity = 3
        for _ in 1...desiredQuantity {
            viewControllerOutput.send(.onProductCellEvent(event: .quantityDidChange(action: .add),
                                                          product: product))
        }

        // Then
        viewModelOutput.sink { [weak self] event in
            if case .updateList = event {
                guard let cartProduct = self?.cart.products.first else {
                    XCTFail("self is nil")
                    return
                }

                XCTAssertEqual(self?.sut.totalQuantities, desiredQuantity - 1)
                XCTAssertEqual(cartProduct.quantity, desiredQuantity - 1)
                let totalPrice = cartProduct.originalPrice * Double(cartProduct.quantity)
                XCTAssertEqual(self?.sut.totalPrice, totalPrice)
                XCTAssertEqual(self?.sut.cartDetails.isEmpty, false)
            }
        }.store(in: &cancellables)

        // When
        viewControllerOutput.send(.onProductCellEvent(event: .quantityDidChange(action: .decrease),
                                                      product: product))
    }

    func testCheckoutTextContainsCartValuesWhenProductsAreAdded() {
        // Given
        let voucherProduct = ProductMother.voucher
        let mugProduct = ProductMother.mug

        // When
        viewModelOutput.sink { _ in }.store(in: &cancellables)
        viewControllerOutput.send(.onProductCellEvent(event: .quantityDidChange(action: .add),
                                                      product: mugProduct))
        viewControllerOutput.send(.onProductCellEvent(event: .quantityDidChange(action: .add),
                                                      product: voucherProduct))

        // Then
        let cartDetails = sut.cartDetails
        XCTAssertTrue(cartDetails.contains(voucherProduct.name))
        XCTAssertTrue(cartDetails.contains(voucherProduct.quantity))
        XCTAssertTrue(cartDetails.contains(sut.cart.products[0].discountedPrice.formatAsStringPrice()))

        XCTAssertTrue(cartDetails.contains(mugProduct.name))
        XCTAssertTrue(cartDetails.contains(mugProduct.quantity))
        XCTAssertTrue(cartDetails.contains(sut.cart.products[1].originalPrice.formatAsStringPrice()))
    }
}

class ProductServiceMock: ProductService {
    var mockedProductList = ProductListResponse(products: [ProductResponse]())
    var fetchCallCounter = 0
    var expectation: XCTestExpectation?

    func getProductsFromAPI() async throws -> ProductListResponse {
        expectation?.fulfill()
        fetchCallCounter += 1
        return mockedProductList
    }
}
