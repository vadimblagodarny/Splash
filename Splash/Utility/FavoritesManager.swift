//
//  FavoritesManager.swift
//  Splash
//
//  Created by Vadim Blagodarny on 07.09.2024.
//

import Foundation

private enum Constants {
    static let favoritesKey = "favoritePhotoIDs"
}

class FavoritesManager {
    static let shared = FavoritesManager()
    
    func getFavoritePhotoIDs() -> [String] {
        return UserDefaults.standard.stringArray(forKey: Constants.favoritesKey) ?? []
    }
    
    func addFavoritePhotoID(_ id: String) {
        var favorites = getFavoritePhotoIDs()
        guard !favorites.contains(id) else { return }
        favorites.append(id)
        saveFavoritePhotoIDs(favorites)
    }
    
    func removeFavoritePhotoID(_ id: String) {
        var favorites = getFavoritePhotoIDs()
        favorites.removeAll { $0 == id }
        saveFavoritePhotoIDs(favorites)
    }
    
    func isPhotoFavorite(_ id: String) -> Bool {
        return getFavoritePhotoIDs().contains(id)
    }
    
    private func saveFavoritePhotoIDs(_ ids: [String]) {
        UserDefaults.standard.set(ids, forKey: Constants.favoritesKey)
    }
}
