//
//  RandomTabViewModel.swift
//  Splash
//
//  Created by Vadim Blagodarny on 07.09.2024.
//

import Foundation
import Alamofire

protocol RandomTabViewModelProtocol: AnyObject {
    var photos: Bindable<[UnsplashPhoto]> { get }
    var error: Bindable<String?> { get }
    func fetchRandomPhotos()
    func searchPhotos(query: String)
}

final class RandomTabViewModel: RandomTabViewModelProtocol {
    var photos: Bindable<[UnsplashPhoto]> = Bindable([])
    var error: Bindable<String?> = Bindable(nil)
    private let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    func fetchRandomPhotos() {
            let url = "https://api.unsplash.com/photos/random"
            let parameters: Parameters = ["count": 50]
            let headers: HTTPHeaders = ["Authorization": "Client-ID sbEOclMPtGfq1goiFNrbsRqdW7QGu5jmuVWuBBbl5ag"]
            
            networkManager.request(url: url, method: .get, parameters: parameters, headers: headers) { [weak self] (result: Result<[UnsplashPhoto], AFError>) in
                switch result {
                case .success(let photos):
                    self?.photos.value = photos
                case .failure(let error):
                    self?.error.value = error.localizedDescription
                }
            }
        }
    
    func searchPhotos(query: String) {
            guard !query.isEmpty else {
                photos.value = []
                return
            }
            
            let url = "https://api.unsplash.com/search/photos"
            let parameters: Parameters = ["query": query, "per_page": 30]
            let headers: HTTPHeaders = ["Authorization": "Client-ID sbEOclMPtGfq1goiFNrbsRqdW7QGu5jmuVWuBBbl5ag"]
            
            networkManager.request(url: url, method: .get, parameters: parameters, headers: headers) { [weak self] (result: Result<PhotoSearchResult, AFError>) in
                switch result {
                case .success(let searchResult):
                    self?.photos.value = searchResult.results
                case .failure(let error):
                    self?.error.value = error.localizedDescription
                }
            }
        }
}
