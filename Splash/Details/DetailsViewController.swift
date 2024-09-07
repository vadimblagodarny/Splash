//
//  DetailsViewController.swift
//  Splash
//
//  Created by Vadim Blagodarny on 07.09.2024.
//

import UIKit

final class DetailsViewController: UIViewController {
    private let stackView = UIStackView()
    private let photoImageView = UIImageView()
    private let authorLabel = UILabel()
    private let dateLabel = UILabel()
    private let locationLabel = UILabel()
    private let downloadsLabel = UILabel()
    private let favoriteButton = UIButton(type: .system)
    private let viewModel: DetailsViewModelProtocol
    
    init(viewModel: DetailsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        setupBindings()
        addViews()
        setupViews()
        setupConstraints()
        configureView()
    }
    
    private func setupBindings() {
        viewModel.isFavorite.bind { [weak self] isFavorite in
            self?.updateFavoriteButton(isFavorite: isFavorite)
        }
    }
    
    private func addViews() {
        view.addSubview(stackView)
        
        [photoImageView,
         authorLabel,
         dateLabel,
         locationLabel,
         downloadsLabel,
         favoriteButton]
            .forEach { view in
                stackView.addArrangedSubview(view)
            }
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        photoImageView.contentMode = .scaleAspectFit
        authorLabel.font = UIFont.systemFont(ofSize: 16)
        authorLabel.textColor = .black
        dateLabel.font = UIFont.systemFont(ofSize: 14)
        dateLabel.textColor = .darkGray
        locationLabel.font = UIFont.systemFont(ofSize: 14)
        locationLabel.textColor = .darkGray
        downloadsLabel.font = UIFont.systemFont(ofSize: 14)
        downloadsLabel.textColor = .darkGray
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func configureView() {
        authorLabel.text = "Author: \(viewModel.photo.user.name)"
        dateLabel.text = viewModel.formattedDate()
        locationLabel.text = viewModel.locationText()
        downloadsLabel.text = viewModel.downloadsText()
        
        viewModel.fetchImage { [weak self] image in
            DispatchQueue.main.async {
                self?.photoImageView.image = image
            }
        }
    }
    
    @objc private func favoriteButtonTapped() {
        viewModel.toggleFavorite()
    }
    
    private func updateFavoriteButton(isFavorite: Bool) {
        favoriteButton.setTitle(isFavorite ? "Remove from Favorites" : "Add to Favorites", for: .normal)
    }
}
