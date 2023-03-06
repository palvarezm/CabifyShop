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
        view.configuration?.title = "product_list_go_to_checkout".localized
        return view
    }()

    lazy private var productsTableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.dataSource = self
        view.isHidden = true
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
        showLoading()
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
                productsTableView.isHidden = false
                emptyTableView.isHidden = true
                productsTableView.reloadData()
                hideLoading()
            case .showViewForEmptyList:
                hideLoading()
                productsTableView.isHidden = true
                emptyTableView.isHidden = false
            case .showDeals(let product):
                showDealsAlert(for: product)
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
        let alert = UIAlertController(title: "product_list_checkout_alert_title".localized,
                                      message: viewModel.cartDetails,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "product_list_checkout_alert_accept_action".localized + " \(viewModel.totalPrice.formatAsStringPrice())",
                                      style: .default,
                                      handler: nil))
        alert.show(self, sender: nil)
        self.present(alert, animated: true, completion: nil)
    }

    private func showDealsAlert(for product: Product) {
        let alert = UIAlertController(title: product.dealsInfo?.title,
                                      message: product.dealsInfo?.deals,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "product_list_deals_info_alert_accept_action".localized,
                                      style: .default,
                                      handler: nil))
        alert.show(self, sender: nil)
        self.present(alert, animated: true, completion: nil)
    }

    private func showLoading() {
        LoadingIndicatorView.show(self.view, loadingText: "product_list_loading_indicator_view_text".localized)
    }

    private func hideLoading() {
        LoadingIndicatorView.hide()
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
        "product_list_table_header".localized + " \(viewModel.totalQuantities)"
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        "product_list_table_footer".localized + " \(viewModel.totalPrice)"
    }
}

