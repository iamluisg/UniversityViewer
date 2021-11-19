//
//  WebviewViewController.swift
//  UniversityViewer
//
//  Created by Luis Garcia on 11/18/21.
//

import UIKit
import WebKit

class WebviewViewController: UIViewController {

    init(_ url: URL) {
        super.init(nibName: nil, bundle: nil)
        self.configureWebview(url)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func configureWebview(_ url: URL) {
        let wkWebView = WKWebView(frame: view.frame)
        self.view.addSubview(wkWebView)
        wkWebView.load(URLRequest(url: url))
    }
}
