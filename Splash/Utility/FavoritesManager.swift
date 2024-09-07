//
//  FavoritesManager.swift
//  Splash
//
//  Created by Vadim Blagodarny on 07.09.2024.
//

import Foundation

class FavoritesManager {
    static let shared = FavoritesManager()
    private let favoritesKey = "favoritePhotoIDs"
    
    func getFavoritePhotoIDs() -> [String] {
        return UserDefaults.standard.stringArray(forKey: favoritesKey) ?? []
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
        UserDefaults.standard.set(ids, forKey: favoritesKey)
    }
}
