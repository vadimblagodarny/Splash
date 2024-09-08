//
//  CustomAlert.swift
//  Splash
//
//  Created by Vadim Blagodarny on 08.09.2024.
//

import UIKit

final class CustomAlert: UIAlertController {
    static func showErrorAlert(on viewController: UIViewController,
                               message: String,
                               retryHandler: (() -> Void)? = nil) {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okAction)
            
            if let retryHandler = retryHandler {
                let retryAction = UIAlertAction(title: "Retry", style: .default) { _ in
                    retryHandler()
                }
                alert.addAction(retryAction)
            }
            
            viewController.present(alert, animated: true, completion: nil)
        }
}
