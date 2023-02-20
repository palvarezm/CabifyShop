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
    lazy private var productsTableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.dataSource = self
        return view
    }()

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
        viewModel.transform(input: output.eraseToAnyPublisher()).sink { [unowned self] event in
            switch event {
            case .updateList:
                self.productsTableView.reloadData()
            }
        }.store(in: &cancellables)
    }

    // MARK: - Configuration
    private func setup() {
        view.backgroundColor = .white
        setupTableView()
    }

    private func setupTableView() {
        view.addSubview(productsTableView)
        NSLayoutConstraint.activate([
            productsTableView.topAnchor.constraint(equalTo: view.topAnchor),
            productsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            productsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            productsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        productsTableView.register(ProductCell.self, forCellReuseIdentifier: String(describing: ProductCell.self))
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

