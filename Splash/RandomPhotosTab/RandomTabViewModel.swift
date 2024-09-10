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
    var currentQuery: String? { get }
    func fetchRandomPhotos(reset: Bool)
    func searchPhotos(query: String, reset: Bool)
}

final class RandomTabViewModel: RandomTabViewModelProtocol {
    var photos: Bindable<[UnsplashPhoto]> = Bindable([])
    var error: Bindable<String?> = Bindable(nil)
    private let networkManager: NetworkManagerProtocol
    private var currentPage = 1
    private var isFetching = false
    private var hasMoreData = true
    var currentQuery: String?
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    func fetchRandomPhotos(reset: Bool = false) {
        guard !isFetching && hasMoreData else { return }
        if reset {
            resetPagination()
        }
        
        isFetching = true
        
        let url = GlobalConstants.Endpoints.randomURL
        let parameters: Parameters = ["count": 30, "page": currentPage]
        let headers: HTTPHeaders = ["Authorization": "Client-ID \(GlobalConstants.Security.accessKey)"]
        
        networkManager.request(url: url, method: .get, parameters: parameters, headers: headers) { [weak self] (result: Result<[UnsplashPhoto], AFError>) in
            guard let self = self else { return }
            self.isFetching = false
            
            switch result {
            case .success(let photos):
                if photos.isEmpty {
                    self.hasMoreData = false
                } else {
                    if reset {
                        self.photos.value = photos
                    } else {
                        self.photos.value.append(contentsOf: photos)
                    }
                    self.currentPage += 1
                }
            case .failure(let error):
                self.error.value = error.localizedDescription
            }
        }
    }
    
    func searchPhotos(query: String, reset: Bool = false) {
        guard !query.isEmpty, !isFetching && hasMoreData else { return }
        if reset {
            resetPagination()
            currentQuery = query
        }
        
        isFetching = true
        let url = GlobalConstants.Endpoints.searchURL
        let parameters: Parameters = ["query": query, "per_page": 30, "page": currentPage]
        let headers: HTTPHeaders = ["Authorization": "Client-ID \(GlobalConstants.Security.accessKey)"]
        
        networkManager.request(url: url, method: .get, parameters: parameters, headers: headers) { [weak self] (result: Result<PhotoSearchResult, AFError>) in
            guard let self = self else { return }
            self.isFetching = false
            
            switch result {
            case .success(let searchResult):
                if searchResult.results.isEmpty {
                    self.hasMoreData = false
                } else {
                    if reset {
                        self.photos.value = searchResult.results
                    } else {
                        self.photos.value.append(contentsOf: searchResult.results)
                    }
                    self.currentPage += 1
                }
            case .failure(let error):
                self.error.value = error.localizedDescription
            }
        }
    }
    
    private func resetPagination() {
        currentPage = 1
        hasMoreData = true
        isFetching = false
        photos.value = []
    }
}
