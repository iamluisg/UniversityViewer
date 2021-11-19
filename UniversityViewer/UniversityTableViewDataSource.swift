//
//  UniversityTableViewDataSource.swift
//  UniversityViewer
//
//  Created by Luis Garcia on 11/18/21.
//

import UIKit
import UniversitySearch

class UniversityTableViewHandler: NSObject, UITableViewDelegate, UITableViewDataSource {

    var universities: [University] = []

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return universities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = universities[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: UniversityTableViewCell.cellIdentifier) as! UniversityTableViewCell
        cell.loadView(item)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UniversityTableViewCell.height
    }
}


class UniversityTableViewCell: UITableViewCell {
    static let cellIdentifier = "UniversityTableViewCell"
    static let height: CGFloat = 120

    // MARK: - Elements
    var lblTitle: UILabel!
    var webPage: UILabel!
    var country: UILabel!
    var state: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initView() {
        selectionStyle = .none
        backgroundView = nil
        backgroundColor = .white

        lblTitle = UILabel()
        lblTitle.textColor = UIColor.black
        lblTitle.font = UIFont.systemFont(ofSize: 13)
        lblTitle.textAlignment = .left
        self.contentView.addSubview(lblTitle)

        lblTitle.snp.makeConstraints { (view) in
            view.left.equalToSuperview().offset(15)
            view.right.equalToSuperview().inset(15)
            view.top.equalToSuperview().offset(5)
        }

        webPage = UILabel()
        webPage.textColor = UIColor.black
        webPage.font = UIFont.systemFont(ofSize: 13)
        webPage.textAlignment = .left
        self.contentView.addSubview(webPage)

        webPage.snp.makeConstraints { (view) in
            view.left.equalToSuperview().offset(15)
            view.right.equalToSuperview().inset(15)
            view.top.equalTo(lblTitle.snp.bottom).offset(5)
        }

        country = UILabel()
        country.textColor = UIColor.black
        country.font = UIFont.systemFont(ofSize: 13)
        country.textAlignment = .left
        self.contentView.addSubview(country)

        country.snp.makeConstraints { (view) in
            view.left.equalToSuperview().offset(15)
            view.right.equalToSuperview().inset(15)
            view.top.equalTo(webPage.snp.bottom).offset(5)
        }

        state = UILabel()
        state.textColor = UIColor.black
        state.font = UIFont.systemFont(ofSize: 13)
        state.textAlignment = .left
        self.contentView.addSubview(state)

        state.snp.makeConstraints { (view) in
            view.left.equalToSuperview().offset(15)
            view.right.equalToSuperview().inset(15)
            view.top.equalTo(country.snp.bottom).offset(5)
        }

    }

    func loadView(_ university: University) {
        lblTitle.text = university.name
        webPage.text = university.webPages[0]
        country.text = university.country
        state.text = university.stateProvince

    }
}
