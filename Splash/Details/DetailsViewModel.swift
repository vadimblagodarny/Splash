//
//  DetailsViewModel.swift
//  Splash
//
//  Created by Vadim Blagodarny on 07.09.2024.
//

import Foundation
import UIKit

private enum Constants {
    static let createdTitle = "Created"
    static let locationTitle = "Location"
    static let downloadsTitle = "Downloads"
    static let unknown = "Unknown"
    static let dateFormatString = "yyyy-MM-dd'T'HH:mm:ssZ"
}

protocol DetailsViewModelProtocol: AnyObject {
    var photo: UnsplashPhoto { get }
    var isFavorite: Bindable<Bool> { get }
    func fetchImage(completion: @escaping (UIImage?) -> Void)
    func formattedDate() -> String
    func locationText() -> String
    func downloadsText() -> String
    func toggleFavorite()
}

final class DetailsViewModel: DetailsViewModelProtocol {
    var photo: UnsplashPhoto
    var isFavorite: Bindable<Bool> = Bindable(false)
    
    private let networkManager: NetworkManager
    
    init(photo: UnsplashPhoto, networkManager: NetworkManager) {
        self.photo = photo
        self.networkManager = networkManager
        self.isFavorite.value = FavoritesManager.shared.isPhotoFavorite(photo.id)
    }
    
    func fetchImage(completion: @escaping (UIImage?) -> Void) {
        networkManager.fetchImage(from: photo.urls.regular) { result in
            switch result {
            case .success(let image):
                completion(image)
            case .failure(let error):
                print("Failed to fetch image: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormatString
        if let date = formatter.date(from: photo.created_at) {
            formatter.dateStyle = .medium
            return "\(Constants.createdTitle): \(formatter.string(from: date))"
        }
        return "\(Constants.createdTitle): \(Constants.unknown)"
    }
    
    func locationText() -> String {
        return "\(Constants.locationTitle): \(photo.user.location ?? "\(Constants.unknown)")"
    }
    
    func downloadsText() -> String {
        return "\(Constants.downloadsTitle): \(photo.downloads ?? .zero)"
    }
    
    func toggleFavorite() {
        if isFavorite.value {
            FavoritesManager.shared.removeFavoritePhotoID(photo.id)
        } else {
            FavoritesManager.shared.addFavoritePhotoID(photo.id)
        }
        isFavorite.value.toggle()
    }
}
