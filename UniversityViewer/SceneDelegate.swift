//
//  SceneDelegate.swift
//  UniversityViewer
//
//  Created by Luis Garcia on 11/18/21.
//

import UIKit
import UniversitySearch
import SharedAPI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
 
        let client = SharedAPI.URLSessionHTTPClient(session: .shared)
        let loader = UniversityLoader(client: client)
        let model = UniversityViewModel(loader)
        
        window.rootViewController = UniversityContainerViewController(viewModel: model)
        window.makeKeyAndVisible()

        self.window = window
    }
}

