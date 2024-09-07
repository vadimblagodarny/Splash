//
//  FavoritePhotoCell.swift
//  Splash
//
//  Created by Vadim Blagodarny on 07.09.2024.
//

import UIKit

final class FavoritePhotoCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let authorLabel = UILabel()
    
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
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .systemGray5

        authorLabel.font = UIFont.systemFont(ofSize: 14)
        authorLabel.textColor = .black
        authorLabel.textAlignment = .center
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(imageView)
        contentView.addSubview(authorLabel)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            authorLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            authorLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    override func prepareForReuse() {
        imageView.image = nil
        authorLabel.text = nil
    }
    
    func configure(with photo: UnsplashPhoto) {
        authorLabel.text = photo.user.name
        
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
}
