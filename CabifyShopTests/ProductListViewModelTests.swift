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
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        productService = ProductServiceMock()
        cart = Cart()
        sut = .init(productService: productService, cart: cart)
        super.setUp()
    }

    override func tearDown() {
        sut = nil
        productService = nil
        super.tearDown()
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testServiceIsCalledWhenViewDidLoad() throws {
        // Given
        let viewModelOutput = sut.transform(input: viewControllerOutput.eraseToAnyPublisher())
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
        let viewModelOutput = sut.transform(input: viewControllerOutput.eraseToAnyPublisher())
        
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
        let viewModelOutput = sut.transform(input: viewControllerOutput.eraseToAnyPublisher())
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
        let viewModelOutput = sut.transform(input: viewControllerOutput.eraseToAnyPublisher())
        let addedProduct = ProductMother.new

        // Then
        viewModelOutput.sink { [weak self] event in
            if case .updateList = event {
                XCTAssertEqual(self?.sut.totalQuantities, 1)
                XCTAssertEqual(self?.sut.totalPrice, ProductMother.new.originalPrice.formatFromStringPrice())
                XCTAssertEqual(self?.sut.cartDetails.isEmpty, false)
            }
        }.store(in: &cancellables)

        // When
        viewControllerOutput.send(.onProductCellEvent(event: .quantityDidChange(action: .add),
                                                      product: addedProduct))
    }

    func testUpdateViewModelWhenTwoForOneDealIsApplied() {
        // Given
        let viewModelOutput = sut.transform(input: viewControllerOutput.eraseToAnyPublisher())
        let addedProduct = ProductMother.voucher

        // Then
        viewModelOutput.sink { [weak self] event in
            if case .updateList = event {
                XCTAssertEqual(self?.sut.totalQuantities, 1 + Deals.twoForOneVoucher.quantityModifier)
                XCTAssertEqual(self?.sut.totalPrice, addedProduct.originalPrice.formatFromStringPrice())
                XCTAssertEqual(self?.sut.cartDetails.isEmpty, false)
            }
        }.store(in: &cancellables)

        // When
        viewControllerOutput.send(.onProductCellEvent(event: .quantityDidChange(action: .add),
                                                      product: addedProduct))
    }

    func testUpdateViewModelWhenTwoForOneDealIsRemoved() {
        // Given
        let viewModelOutput = sut.transform(input: viewControllerOutput.eraseToAnyPublisher())
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
        let viewModelOutput = sut.transform(input: viewControllerOutput.eraseToAnyPublisher())
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
        let viewModelOutput = sut.transform(input: viewControllerOutput.eraseToAnyPublisher())
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
