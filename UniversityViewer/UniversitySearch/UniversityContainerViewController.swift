//
//  UniversityContainerViewController.swift
//  UniversityViewer
//
//  Created by Luis Garcia on 11/18/21.
//

import UIKit
import Combine
import UniversitySearch

class UniversityContainerViewController: UIViewController {

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
        
        disposables.insert(universityViewModel.$universities.sink { [weak self] unis in
            if self?.usingSwiftUI == false {
                
            }
        })
        
        disposables.insert(universityViewModel.buttonPressedSubject.sink(receiveValue: { [weak self] tapped in
//            self?.handleButtonPressed(tapped)
        }))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc func reload() {
        self.universityViewModel.fetchUnis(nil)
    }
}
