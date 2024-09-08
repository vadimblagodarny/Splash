//
//  DetailsViewController.swift
//  Splash
//
//  Created by Vadim Blagodarny on 07.09.2024.
//

import UIKit

private enum Constants {
    static let authorTitle = "Author"
    static let favoritesRemoveText = "Remove from Favorites"
    static let favoritesAddText = "Add to Favorites"
    static let stackViewSpacing: CGFloat = 10
}

final class DetailsViewController: UIViewController {
    private let stackView = UIStackView()
    private let photoImageView = UIImageView()
    private let authorLabel = UILabel()
    private let dateLabel = UILabel()
    private let locationLabel = UILabel()
    private let downloadsLabel = UILabel()
    private let favoriteButton = UIButton(type: .system)

    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()

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
        view.addSubview(activityIndicator)

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
        authorLabel.font = GlobalConstants.Fonts.large
        authorLabel.textColor = .black
        dateLabel.font = GlobalConstants.Fonts.medium
        dateLabel.textColor = .darkGray
        locationLabel.font = GlobalConstants.Fonts.medium
        locationLabel.textColor = .darkGray
        downloadsLabel.font = GlobalConstants.Fonts.medium
        downloadsLabel.textColor = .darkGray
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        
        stackView.axis = .vertical
        stackView.spacing = Constants.stackViewSpacing
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                               constant: GlobalConstants.Sizes.screenPadding),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                constant: -GlobalConstants.Sizes.screenPadding),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                           constant: GlobalConstants.Sizes.screenPadding),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                              constant: -GlobalConstants.Sizes.screenPadding),
            activityIndicator.centerXAnchor.constraint(equalTo: photoImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: photoImageView.centerYAnchor)
        ])
    }
    
    private func configureView() {
        authorLabel.text = "\(Constants.authorTitle): \(viewModel.photo.user.name)"
        dateLabel.text = viewModel.formattedDate()
        locationLabel.text = viewModel.locationText()
        downloadsLabel.text = viewModel.downloadsText()
        activityIndicator.startAnimating()

        viewModel.fetchImage { [weak self] image in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.photoImageView.image = image
            }
        }
    }
    
    private func updateFavoriteButton(isFavorite: Bool) {
        favoriteButton.setTitle(isFavorite ? Constants.favoritesRemoveText : Constants.favoritesAddText, for: .normal)
        favoriteButton.setTitleColor(isFavorite ? .red : .tintColor, for: .normal)
    }

    @objc private func favoriteButtonTapped() {
        viewModel.toggleFavorite()
    }    
}
