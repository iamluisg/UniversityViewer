//
//  UniversityContainerViewController.swift
//  UniversityViewer
//
//  Created by Luis Garcia on 11/18/21.
//

import UIKit
import Combine
//import UniversitySearch

#warning("Is it overkill to have a container view controller here and have view creation happen in a different view controller?")
// This can then become the place where composition of all individual UI components for this page is done.
class UniversityContainerViewController: UIViewController {

    // Child View Controllers
    var uniListViewController: UniversityListViewController! {
        didSet {
            self.disposables.insert (
                uniListViewController.searchStringPublisher.sink(receiveValue: { search in
                    self.universityViewModel.fetchUnis(search)
                })
            )
        }
    }

    // Any Cancellables
    var disposables: Set<AnyCancellable> = []
    
    // Misc variables
    var usingSwiftUI: Bool = true
    
    // Passed in variables
    var universityViewModel: UniversityViewModel

    // MARK: - Initializers
    init(viewModel: UniversityViewModel) {
        self.universityViewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.build()
        
        disposables.insert(universityViewModel.$universities.sink { [weak self] unis in
            if self?.usingSwiftUI == false {
                self?.uniListViewController.load(unis)
            }
        })
        universityViewModel.fetchUnis("san")
    }
    
    func build() {
        if usingSwiftUI {
            self.buildSwiftUIVersion()
        } else {
            self.buildUIKitVersion()
        }
    }

    private func buildSwiftUIVersion() {
        self.uniListViewController = UniversityListViewController(swiftUIView: self.universityViewModel)
        self.addViewControllerChild(uniListViewController)
        uniListViewController.view.snp.makeConstraints { view in
            view.top.left.right.bottom.equalToSuperview()
        }
        uniListViewController.onUniversityTap = { [weak self] uni in
            if let uniURL = URL(string: uni.webPages.first ?? "") {
                let webViewController = WebviewViewController(uniURL)
                self?.show(webViewController, sender: self)
            }
//            self?.navigateToUniversity(uni)
        }
    }

    private func buildUIKitVersion() {
        self.uniListViewController = UniversityListViewController()
        self.addViewControllerChild(self.uniListViewController)
        self.uniListViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.uniListViewController.view.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
        self.uniListViewController.onUniversityTap = { [weak self] uni in
            if let uniURL = URL(string: uni.webPages.first ?? "") {
                let webViewController = WebviewViewController(uniURL)
                self?.show(webViewController, sender: self)
            }
//            self?.navigateToUniversity(uni)
        }
    }
    
    #warning("I would prefer to use this function instead of duplicating code within the onUniversityTap completion blocks but it requires me to import the UniversitySearch module to have access to the University model. How do I keep from having to import UniversitySearch module in so many places?")
//    private func navigateToUniversity(_ university: University) {
//        if let uniURL = URL(string: university.webPages.first ?? "") {
//            let webViewController = WebviewViewController(uniURL)
//            self.show(webViewController, sender: self)
//        }
//    }
    
    @objc func reload() {
//        self.universityViewModel.fetchUnis(nil)
    }
}
