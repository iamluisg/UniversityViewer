//
//  UITableViewExtensions.swift
//  UniversityViewer
//
//  Created by Luis Garcia on 11/18/21.
//

import UIKit

public extension UITableView {

    convenience init(_ superview: UIView, _ style: UITableView.Style, _ identifiers: [String]) {

        self.init(frame: .zero, style: style)

        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false

        self.backgroundColor = .clear
        self.separatorStyle = .singleLine

        self.sectionHeaderHeight = UITableView.automaticDimension
        self.estimatedSectionHeaderHeight = 0

        self.sectionFooterHeight = UITableView.automaticDimension
        self.estimatedSectionFooterHeight = 0

        for identifier in identifiers {
            if let projectName = Bundle.main.infoDictionary!["CFBundleExecutable"] as? String {
                let namespace = projectName.replacingOccurrences(of: "-", with: "_")
                if let anyClass: AnyClass = NSClassFromString("\(namespace).\(identifier)") {
                    self.register(anyClass, forCellReuseIdentifier: identifier)
                }
            }
        }
        superview.addSubview(self)
    }
}
