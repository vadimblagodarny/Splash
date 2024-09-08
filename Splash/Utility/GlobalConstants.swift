//
//  GlobalConstants.swift
//  Splash
//
//  Created by Vadim Blagodarny on 07.09.2024.
//

import UIKit

enum GlobalConstants {
    enum Security {
        static let accessKey = "sbEOclMPtGfq1goiFNrbsRqdW7QGu5jmuVWuBBbl5ag"
    }
    
    enum Endpoints {
        static let searchURL = "https://api.unsplash.com/search/photos"
        static let randomURL = "https://api.unsplash.com/photos/random"
        static let onePhotoURL = "https://api.unsplash.com/photos"
    }

    enum Sizes {
        static let screenPadding: CGFloat = 20
        static let imageCornerRadius: CGFloat = 8
    }
    
    enum Fonts {
        static let medium = UIFont.systemFont(ofSize: 14)
        static let large = UIFont.systemFont(ofSize: 16)
    }
}
