//
//  FavoritesTabViewModel.swift
//  Splash
//
//  Created by Vadim Blagodarny on 07.09.2024.
//

import Foundation

protocol FavoritesTabViewModelProtocol: AnyObject {
    var favoritePhotos: Bindable<[UnsplashPhoto]> { get }
    var error: Bindable<String?> { get }
    func fetchFavoritePhotos()
}

final class FavoritesTabViewModel: FavoritesTabViewModelProtocol {
    var favoritePhotos: Bindable<[UnsplashPhoto]> = Bindable([])
    var error: Bindable<String?> = Bindable(nil)
    private let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    func fetchFavoritePhotos() {
        let endpoint = GlobalConstants.Endpoints.onePhotoURL
        let favoritePhotoIDs = FavoritesManager.shared.getFavoritePhotoIDs()
        
        let dispatchGroup = DispatchGroup()
        var photos: [UnsplashPhoto] = []
                
        for id in favoritePhotoIDs {
            let urlString = "\(endpoint)/\(id)?client_id=\(GlobalConstants.Security.accessKey)"

            dispatchGroup.enter()
            networkManager.fetchPhoto(from: urlString, byID: id) { [weak self] result in
                switch result {
                case .success(let photo):
                    photos.append(photo)
                case .failure(let error):
                    self?.error.value = error.localizedDescription
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.favoritePhotos.value = photos
        }
    }
}
