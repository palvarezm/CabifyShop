//
//  AddToCartView.swift
//  CabifyShop
//
//  Created by Paul Alvarez on 20/02/23.
//

import UIKit
import Combine

enum ProductQuantityAction {
    case add
    case decrease
}

typealias OnQuantityChangedClosure = (ProductQuantityAction) -> (Void)

class AddToCartView: UIView {
    // MARK: - Properties
    lazy private var totalContainerStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.distribution = .fillProportionally
        view.isLayoutMarginsRelativeArrangement = true
        view.directionalLayoutMargins = NSDirectionalEdgeInsets(top: Constants.totalContainerPadding,
                                                                leading: 0,
                                                                bottom: Constants.totalContainerPadding,
                                                                trailing: 0)
        return view
    }()

    lazy private var addToCartButton: UIButton = {
        let view = UIButton()
        view.configuration = .bordered()
        view.configuration?.image = UIImage(systemName: "cart")
        view.configuration?.baseForegroundColor = .white
        view.configuration?.baseBackgroundColor = .primary
        view.configuration?.cornerStyle = .large
        return view
    }()

    lazy private var itemCounterStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = Constants.itemCounterSpacing
        view.isHidden = true
        return view
    }()

    lazy private var upButton: UIButton = {
        let view = UIButton()
        view.tintColor = .primary
        view.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        return view
    }()

    lazy private var unitCounterLabel: UILabel = {
        let view = UILabel()
        view.text = "0"
        view.textAlignment = .center
        return view
    }()

    lazy private var downButton: UIButton = {
        let view = UIButton()
        view.tintColor = .primary
        view.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
        return view
    }()

    private enum Constants {
        static let itemCounterSpacing = 10.0
        static let totalContainerPadding = 10.0
    }

    var onQuantityChangedClosure: OnQuantityChangedClosure?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Setup
    private func setup() {
        setupView()
    }

    private func setupView() {
        setupTotalContainerStackView()
        setupItemCounterStackView()
        setupAddToCartButtonAction()
        setupUpButtonAction()
        setupDownButtonAction()
    }

    private func setupTotalContainerStackView() {
        addSubview(totalContainerStackView)
        NSLayoutConstraint.activate([
            totalContainerStackView.topAnchor.constraint(equalTo: topAnchor),
            totalContainerStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            totalContainerStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            totalContainerStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        totalContainerStackView.addArrangedSubview(addToCartButton)
    }

    private func setupItemCounterStackView() {
        addSubview(itemCounterStackView)
        NSLayoutConstraint.activate([
            itemCounterStackView.topAnchor.constraint(equalTo: topAnchor),
            itemCounterStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            itemCounterStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            itemCounterStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        itemCounterStackView.addArrangedSubview(downButton)
        itemCounterStackView.addArrangedSubview(unitCounterLabel)
        itemCounterStackView.addArrangedSubview(upButton)
    }

    // MARK: - Configuration
    func setQuantity(quantity: String) {
        unitCounterLabel.text = quantity
        addToCartButton.isHidden = quantity != "0"
        itemCounterStackView.isHidden = quantity == "0"
    }

    // MARK: - Actions
    private func setupAddToCartButtonAction() {
        addToCartButton.addTarget(self, action: #selector(onTapAddToCartButton), for: .touchUpInside)
    }

    private func setupUpButtonAction() {
        upButton.addTarget(self, action: #selector(upButtonTapped), for: .touchUpInside)
    }

    private func setupDownButtonAction() {
        downButton.addTarget(self, action: #selector(downButtonTapped), for: .touchUpInside)
    }

    @objc private func onTapAddToCartButton() {
        onQuantityChangedClosure?(.add)
    }

    @objc private func upButtonTapped() {
        onQuantityChangedClosure?(.add)
    }

    @objc private func downButtonTapped() {
        onQuantityChangedClosure?(.decrease)
    }
}
