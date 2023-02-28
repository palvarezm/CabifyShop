//
//  EmptyTableView.swift
//  CabifyShop
//
//  Created by Paul Alvarez on 27/02/23.
//

import UIKit

class EmptyTableView: UIView {
    // MARK: - Properties
    lazy var emptyTableImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(systemName: "xmark.octagon")
        return view
    }()

    lazy var emptyTableLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = "There's no products for now"
        return view
    }()

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Configuration
    private func setup() {
        setupImage()
        setupLabel()
    }

    private func setupImage() {
        addSubview(emptyTableImage)
        NSLayoutConstraint.activate([
            emptyTableImage.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyTableImage.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private func setupLabel() {
        addSubview(emptyTableLabel)
        NSLayoutConstraint.activate([
            emptyTableLabel.topAnchor.constraint(equalTo: emptyTableImage.bottomAnchor),
            emptyTableLabel.centerXAnchor.constraint(equalTo: emptyTableImage.centerXAnchor)
        ])
    }
}
