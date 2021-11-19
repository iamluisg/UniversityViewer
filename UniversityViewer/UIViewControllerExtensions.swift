//
//  UIViewControllerExtensions.swift
//  UniversityViewer
//
//  Created by Luis Garcia on 11/18/21.
//

import UIKit

// MARK: - Add view controller child extension
extension UIViewController {
    func addViewControllerChild(_ controller: UIViewController) {
        controller.willMove(toParent: self)
        self.addChild(controller)
        self.view.addSubview(controller.view)
        controller.didMove(toParent: self)
    }
}
