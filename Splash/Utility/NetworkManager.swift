//
//  NetworkManager.swift
//  Splash
//
//  Created by Vadim Blagodarny on 07.09.2024.
//

import Alamofire

protocol NetworkManagerProtocol {
    func request<T: Decodable>(
        url: String,
        method: HTTPMethod,
        parameters: Parameters?,
        headers: HTTPHeaders?,
        completion: @escaping (Result<T, AFError>) -> Void
    )
    
    func fetchImage(from urlString: String, completion: @escaping (Result<UIImage, Error>) -> Void)
    func fetchPhoto(byID id: String, completion: @escaping (Result<UnsplashPhoto, Error>) -> Void)
}

class NetworkManager: NetworkManagerProtocol {
    private let session: Session
    
    init(session: Session = .default) {
        self.session = session
    }
    
    func request<T: Decodable>(
        url: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        completion: @escaping (Result<T, AFError>) -> Void
    ) {
        session.request(url, method: method, parameters: parameters, headers: headers)
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func fetchImage(from urlString: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        AF.request(urlString).responseData { response in
            switch response.result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    completion(.success(image))
                } else {
                    completion(.failure(NetworkError.invalidData))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchPhoto(byID id: String, completion: @escaping (Result<UnsplashPhoto, Error>) -> Void) {
        let urlString = "https://api.unsplash.com/photos/\(id)?client_id=sbEOclMPtGfq1goiFNrbsRqdW7QGu5jmuVWuBBbl5ag"
        
        AF.request(urlString).responseDecodable(of: UnsplashPhoto.self) { response in
            switch response.result {
            case .success(let photo):
                completion(.success(photo))
            case .failure(let error):
                completion(.failure(NetworkError.requestFailed(description: error.localizedDescription)))
            }
        }
    }
}
