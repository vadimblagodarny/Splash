//
//  FavoritePhotoCell.swift
//  Splash
//
//  Created by Vadim Blagodarny on 07.09.2024.
//

import UIKit

private enum Constants {
    static let buttonImage = UIImage(systemName: "xmark.circle.fill")
    static let buttonScaleFactor: CGFloat = 2.0
    static let buttonSize: CGFloat = 48.0
    static let buttonPadding: CGFloat = 8.0
    static let authorLabelPadding: CGFloat = 10
}

final class FavoritePhotoCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let authorLabel = UILabel()
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(Constants.buttonImage, for: .normal)
        button.transform = CGAffineTransform(scaleX: Constants.buttonScaleFactor,
                                             y: Constants.buttonScaleFactor)
        button.contentMode = .scaleAspectFill
        button.tintColor = .red
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    var deleteAction: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = GlobalConstants.Sizes.imageCornerRadius
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .systemGray5

        authorLabel.font = GlobalConstants.Fonts.medium
        authorLabel.textColor = .black
        authorLabel.textAlignment = .center
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(imageView)
        contentView.addSubview(authorLabel)
        contentView.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            authorLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor,
                                             constant: Constants.authorLabelPadding),
            authorLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor,
                                              constant: Constants.buttonPadding),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                   constant: -Constants.buttonPadding),
            deleteButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            deleteButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        authorLabel.text = nil
    }
    
    func configure(with photo: UnsplashPhoto, isEditing: Bool) {
        authorLabel.text = photo.user.name
        deleteButton.isHidden = !isEditing
        
        let networkManager = NetworkManager()
        networkManager.fetchImage(from: photo.urls.small) { [weak self] result in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self?.imageView.image = image
                }
            case .failure(let error):
                print("Failed to load image: \(error.localizedDescription)")
            }
        }
    }
    
    @objc private func deleteButtonTapped() {
            deleteAction?()
        }
}
