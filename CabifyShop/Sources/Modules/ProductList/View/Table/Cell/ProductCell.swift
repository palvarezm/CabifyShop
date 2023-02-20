//
//  ProductCell.swift
//  CabifyShop
//
//  Created by Paul Alvarez on 20/02/23.
//

import UIKit
import Combine

enum ProductCellEvent {
    case quantityDidChange(action: ProductQuantityAction)
}

class ProductCell: UITableViewCell {
    // MARK: - Properties
    lazy private var productInfoStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.distribution = .fillProportionally
        view.axis = .vertical
        return view
    }()

    lazy private var nameLabel: UILabel = {
        var view = UILabel()
        return view
    }()

    lazy private var priceStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = Constants.priceStackViewSpacing
        view.distribution = .fillEqually
        return view
    }()

    lazy private var originalPriceLabel: UILabel = {
        var view = UILabel()
        view.font = view.font.withSize(Constants.priceLabelFontSize)
        return view
    }()

    lazy private var discountedPriceLabel: UILabel = {
        var view = UILabel()
        view.font = view.font.withSize(Constants.priceLabelFontSize)
        return view
    }()

    lazy private var addToCartView: AddToCartView = {
        let view = AddToCartView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.onQuantityChangedClosure = { [weak self] action in
            self?.eventSubject.send(.quantityDidChange(action: action))
        }
        return view
    }()

    enum Constants {
        static let priceLabelFontSize = 14.0
        static let standardPadding = 16.0
        static let priceStackViewSpacing = 4.0
    }

    private var product: Product?
    private let eventSubject = PassthroughSubject<ProductCellEvent, Never>()
    var eventPublisher: AnyPublisher<ProductCellEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
    var cancellables = Set<AnyCancellable>()

    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables = Set<AnyCancellable>()
    }

    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        selectionStyle = .none
        contentView.isUserInteractionEnabled = true
        setupProductInfoStackView()
        setupPriceStackView()
        setupAddToCartView()
    }

    private func setupProductInfoStackView() {
        addSubview(productInfoStackView)
        NSLayoutConstraint.activate([
            productInfoStackView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.standardPadding),
            productInfoStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.standardPadding),
            productInfoStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.standardPadding)
        ])
        productInfoStackView.addArrangedSubview(nameLabel)
        productInfoStackView.addArrangedSubview(priceStackView)
    }

    private func setupPriceStackView() {
        priceStackView.addArrangedSubview(originalPriceLabel)
        priceStackView.addArrangedSubview(discountedPriceLabel)
    }

    private func setupAddToCartView() {
        addSubview(addToCartView)
        NSLayoutConstraint.activate([
            addToCartView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.standardPadding),
            addToCartView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    // MARK: - Configuration
    func configure(with product: Product) {
        self.product = product
        nameLabel.text = product.name
        let originalPriceLabelColor: UIColor = product.discountedPrice != product.originalPrice
                                                ? .red
                                                : .black
        originalPriceLabel.text = product.originalPrice
        originalPriceLabel.textColor = originalPriceLabelColor
        discountedPriceLabel.text = product.discountedPrice
        discountedPriceLabel.isHidden = product.discountedPrice == product.originalPrice
        addToCartView.setQuantity(quantity: product.quantity)
    }
}
