//
//  NetworkManager.swift
//  Splash
//
//  Created by Vadim Blagodarny on 07.09.2024.
//

import Alamofire
import AlamofireImage

protocol NetworkManagerProtocol {
    func request<T: Decodable>(
        url: String,
        method: HTTPMethod,
        parameters: Parameters?,
        headers: HTTPHeaders?,
        completion: @escaping (Result<T, AFError>) -> Void
    )
    
    func fetchImage(from urlString: String, completion: @escaping (Result<UIImage, Error>) -> Void) -> DataRequest?
    func fetchPhoto(from urlString: String, byID id: String, completion: @escaping (Result<UnsplashPhoto, Error>) -> Void)
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
        
    func fetchImage(from urlString: String, completion: @escaping (Result<UIImage, Error>) -> Void) -> DataRequest? {
            guard let imageUrl = URL(string: urlString) else {
                completion(.failure(NetworkError.invalidURL))
                return nil
            }
            
            let request = AF.request(imageUrl).responseImage { response in
                switch response.result {
                case .success(let image):
                    completion(.success(image))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        
            return request
        }
    
    func fetchPhoto(from urlString: String, byID id: String, completion: @escaping (Result<UnsplashPhoto, Error>) -> Void) {
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
