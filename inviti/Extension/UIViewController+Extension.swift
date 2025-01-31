//
//  UIViewController+Extension.swift
//  inviti
//
//  Created by Hannah.C on 23.05.21.
//

import UIKit

extension UIViewController {
    
    func pop(numberOfTimes: Int) {
        
        guard let navigationController = navigationController else { return }
        
        let viewControllers = navigationController.viewControllers
        
        let index = numberOfTimes + 1
        
        if viewControllers.count >= index {
            
            navigationController.popToViewController(viewControllers[viewControllers.count - index], animated: true)
        }
    }

    static func confirmationAlert(title: String?, message: String?, cancelHandler: @escaping () -> Void, confirmHandler: @escaping () -> Void) -> UIAlertController {

       let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

       let confirmAction = UIAlertAction(title: (NSLocalizedString("alert_confrim" , comment: "Alert confirm.") as String), style: .destructive) { action in
            confirmHandler()

       }

       alertController.addAction(confirmAction)

       let cancelAction = UIAlertAction(title: (NSLocalizedString("alert_cancel" , comment: "Alert cancel.") as String), style: .cancel) { action in
            cancelHandler()
       }

       alertController.addAction(cancelAction)

       return alertController
    }
}
