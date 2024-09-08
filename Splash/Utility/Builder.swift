//
//  Builder.swift
//  Splash
//
//  Created by Vadim Blagodarny on 07.09.2024.
//

import UIKit

private enum Constants {
    static let randomTabVCimage = "photo.fill.on.rectangle.fill"
    static let favoritesTabVCimage = "star.square.on.square.fill"
}

class Builder {
    func createTabs() -> UITabBarController {
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [createRandomTabVC(), createFavoritesTabVC()]
        return tabBarController
    }
    
    func createDetailsVC(photo: UnsplashPhoto) -> UIViewController {
        let networkManager = NetworkManager()
        let viewModel = DetailsViewModel(photo: photo, networkManager: networkManager)
        let viewController = DetailsViewController(viewModel: viewModel)
        return viewController
    }

    private func createRandomTabVC() -> UIViewController {
        let networkManager = NetworkManager()
        let viewModel = RandomTabViewModel(networkManager: networkManager)
        let viewController = RandomTabViewController(viewModel: viewModel)
        viewController.tabBarItem.image = UIImage(systemName: Constants.randomTabVCimage)
        let navController = UINavigationController()
        navController.viewControllers = [viewController]
        return navController
    }
    
    private func createFavoritesTabVC() -> UIViewController {
        let networkManager = NetworkManager()
        let viewModel = FavoritesTabViewModel(networkManager: networkManager)
        let viewController = FavoritesTabViewController(viewModel: viewModel)
        viewController.tabBarItem.image = UIImage(systemName: Constants.favoritesTabVCimage)
        let navController = UINavigationController()
        navController.viewControllers = [viewController]
        return navController
    }
    
}
