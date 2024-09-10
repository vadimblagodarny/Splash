//
//  PhotoCell.swift
//  Splash
//
//  Created by Vadim Blagodarny on 07.09.2024.
//

import UIKit
import Alamofire

final class PhotoCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = GlobalConstants.Sizes.imageCornerRadius
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .systemGray5
        return imageView
    }()
    
    private var currentImageRequest: DataRequest?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        currentImageRequest?.cancel()
        currentImageRequest = nil
    }
    
    func configure(with photo: UnsplashPhoto) {
        currentImageRequest?.cancel()
        let networkManager = NetworkManager()
        
        currentImageRequest = networkManager.fetchImage(from: photo.urls.small) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    self.imageView.image = image
                case .failure(let error):
                    print("Failed to load image: \(error.localizedDescription)")
                }
            }
        }
    }
}
