//
//  FavoritesTabViewModel.swift
//  Splash
//
//  Created by Vadim Blagodarny on 07.09.2024.
//

import Foundation

protocol FavoritesTabViewModelProtocol: AnyObject {
    var favoritePhotos: Bindable<[UnsplashPhoto]> { get }
    func fetchFavoritePhotos()
}

final class FavoritesTabViewModel: FavoritesTabViewModelProtocol {
    var favoritePhotos: Bindable<[UnsplashPhoto]> = Bindable([])
    private let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
        fetchFavoritePhotos()
    }
    
    func fetchFavoritePhotos() {
        let favoritePhotoIDs = FavoritesManager.shared.getFavoritePhotoIDs()
        
        let dispatchGroup = DispatchGroup()
        var photos: [UnsplashPhoto] = []
        
        for id in favoritePhotoIDs {
            dispatchGroup.enter()
            networkManager.fetchPhoto(byID: id) { result in
                switch result {
                case .success(let photo):
                    photos.append(photo)
                case .failure(let error):
                    print("Failed to fetch photo: \(error.localizedDescription)")
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.favoritePhotos.value = photos
        }
    }
}
