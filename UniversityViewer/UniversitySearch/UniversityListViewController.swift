//
//  UniversityListViewController.swift
//  UniversityViewer
//
//  Created by Luis Garcia on 11/18/21.
//

import UIKit
import Combine
import SwiftUI
import SnapKit
import UniversitySearch

class UniversityListViewController: UIViewController {
    // UI elements
    private(set) var navBarView: UIView!
    private(set) var button: UIButton!
    private(set) var tableView: UITableView!
    let searchBar = UISearchBar()
    private(set) var universityHostingController: UIHostingController<UniversitySwiftUIView>?

    // Data sources
    private(set) var tableViewHandler: UniversityTableViewHandler!
    
    // Combine variables
    let searchStringPublisher = PassthroughSubject<String, Never>()
    private(set) var cancellable: AnyCancellable?
    
    // Callbacks
    var onUniversityTap: ((University) -> Void)?

    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)
        sharedConfiguration()
        buildUIKit()
    }

    init(swiftUIView uniModel: UniversityViewModel) {
        super.init(nibName: nil, bundle: nil)
        sharedConfiguration()
        self.buildSwiftUI(uniModel: uniModel)
    }
    
    func sharedConfiguration() {
        self.view.backgroundColor = .white
        setupSearchBar()
    }

    private func setupSearchBar() {
        self.buildNavBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(searchBar)
        self.searchBar.delegate = self
        searchBar.snp.makeConstraints { view in
            view.top.equalTo(navBarView.snp.bottom)
            view.left.right.equalToSuperview()
            view.height.equalTo(50)
        }
    }
    
    func buildNavBar() {
        navBarView = UIView()
        navBarView.backgroundColor = .white
        navBarView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(navBarView)
        navBarView.snp.makeConstraints { (view) in
            view.left.right.top.equalToSuperview()
            view.height.equalTo(75)
        }
    }
    
    func buildSwiftUI(uniModel: UniversityViewModel) {
        let view = UniversitySwiftUIView(uniModel: uniModel) { [weak self] uni in
            self?.onUniversityTap?(uni)
        }
        let host = UIHostingController(rootView: view)
        self.universityHostingController = host

        host.view.translatesAutoresizingMaskIntoConstraints = false

        self.addViewControllerChild(host)
        host.view.snp.makeConstraints { view in
            view.top.equalTo(searchBar.snp.bottom)
            view.left.right.bottom.equalToSuperview()
        }
    }
    
    func buildUIKit() {
        self.tableViewHandler = UniversityTableViewHandler()
        self.tableViewHandler.onUniversityTap = { [weak self] uni in
            self?.onUniversityTap?(uni)
        }
        tableView = UITableView(self.view, .plain, [UniversityTableViewCell.cellIdentifier])
        tableView.backgroundColor = .white
        tableView.delegate = tableViewHandler
        tableView.dataSource = tableViewHandler

        tableView.snp.makeConstraints { (view) in
            view.top.equalTo(searchBar.snp.bottom)
            view.left.right.equalToSuperview()
            view.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func load(_ universities: [University]) {
        tableViewHandler.universities = universities
        tableView.reloadData()
    }
}

extension UniversityListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.cancellable = searchBar.publisher(for: \.text)
            .debounce(for: 0.3, scheduler: RunLoop.main).sink { subs in
                print(subs)
            } receiveValue: { [weak self] str in
                guard let searchString = str else { return }
                self?.searchStringPublisher.send(searchString)
        }
    }
}
