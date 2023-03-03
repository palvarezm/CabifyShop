//
//  ProductListViewController.swift
//  CabifyShop
//
//  Created by Paul Alvarez on 20/02/23.
//

import UIKit
import Combine

class ProductListViewController: UIViewController {
    // MARK: - Properties
    lazy private var checkoutButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configuration = .bordered()
        view.configuration?.baseBackgroundColor = .primary
        view.configuration?.baseForegroundColor = .white
        view.configuration?.cornerStyle = .large
        view.configuration?.title = "Go to checkout"
        return view
    }()

    lazy private var productsTableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.dataSource = self
        return view
    }()

    lazy private var emptyTableView: UIView = {
        let view = EmptyTableView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private enum Constants {
        static let checkoutButtonTopMargin = 12.0
        static let tableTopMargin = 4.0
    }

    let viewModel = ProductListViewModel()

    private let output = PassthroughSubject<ProductListViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        observe()
        output.send(.viewDidLoad)
        setup()
    }

    // MARK: - Binding
    private func observe() {
        viewModel.transform(input: output.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] event in
            switch event {
            case .updateList:
                self.productsTableView.isHidden = false
                self.emptyTableView.isHidden = true
                self.productsTableView.reloadData()
            case .showViewForEmptyList:
                self.productsTableView.isHidden = true
                self.emptyTableView.isHidden = false
            case .showDeals(let product):
                self.showDealsAlert(for: product)
            }
            
        }.store(in: &cancellables)
    }

    // MARK: - Setup
    private func setup() {
        view.backgroundColor = .white
        setupCheckoutButton()
        setCheckoutButtonAction()
        setupTableView()
        setupEmptyTableView()
    }

    private func setupCheckoutButton() {
        view.addSubview(checkoutButton)
        NSLayoutConstraint.activate([
            checkoutButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: Constants.checkoutButtonTopMargin),
            checkoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupTableView() {
        view.addSubview(productsTableView)
        NSLayoutConstraint.activate([
            productsTableView.topAnchor.constraint(equalTo: checkoutButton.bottomAnchor, constant: Constants.tableTopMargin),
            productsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            productsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            productsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        productsTableView.register(ProductCell.self, forCellReuseIdentifier: String(describing: ProductCell.self))
    }

    private func setupEmptyTableView() {
        view.addSubview(emptyTableView)
        NSLayoutConstraint.activate([
            emptyTableView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Actions
    private func setCheckoutButtonAction() {
        checkoutButton.addTarget(self, action: #selector(showCheckoutAlert), for: .touchUpInside)
    }

    @objc private func showCheckoutAlert() {
        let alert = UIAlertController(title: "Checkout",
                                      message: viewModel.cartDetails,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Buy for \(viewModel.totalPrice.formatAsStringPrice())",
                                      style: .default,
                                      handler: nil))
        alert.show(self, sender: nil)
        self.present(alert, animated: true, completion: nil)
    }

    private func showDealsAlert(for product: Product) {
        let alert = UIAlertController(title: product.dealsInfo?.title,
                                      message: product.dealsInfo?.deals,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok",
                                      style: .default,
                                      handler: nil))
        alert.show(self, sender: nil)
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ProductListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.productList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ProductCell.self), for: indexPath) as? ProductCell else { return UITableViewCell() }

        let product = viewModel.productList[indexPath.item]
        cell.configure(with: product)
        cell.eventPublisher.sink { [weak self] event in
            self?.output.send(.onProductCellEvent(event: event, product: product))
        }.store(in: &cell.cancellables)
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Number of items: \(viewModel.totalQuantities)"
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        "Total price: \(viewModel.totalPrice)"
    }
}

