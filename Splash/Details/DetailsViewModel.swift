//
//  DetailsViewModel.swift
//  Splash
//
//  Created by Vadim Blagodarny on 07.09.2024.
//

import Foundation
import UIKit

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
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = formatter.date(from: photo.created_at) {
            formatter.dateStyle = .medium
            return "Created: \(formatter.string(from: date))"
        }
        return "Created: Unknown"
    }
    
    func locationText() -> String {
        return "Location: \(photo.user.location ?? "Unknown")"
    }
    
    func downloadsText() -> String {
        return "Downloads: \(photo.downloads ?? 0)"
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
