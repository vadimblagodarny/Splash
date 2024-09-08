//
//  Model.swift
//  Splash
//
//  Created by Vadim Blagodarny on 07.09.2024.
//

struct UnsplashPhoto: Decodable {
    let id: String
    let created_at: String
    let downloads: Int?
    let user: User
    let urls: PhotoURLs
}

struct PhotoURLs: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

struct PhotoSearchResult: Decodable {
    let results: [UnsplashPhoto]
}

struct User: Decodable {
    let name: String
    let location: String?
}
