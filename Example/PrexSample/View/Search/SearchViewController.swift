//
//  SearchViewController.swift
//  PrexSample
//
//  Created by marty-suzuki on 2018/09/29.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import Prex
import UIKit

final class SearchViewController: UIViewController {

    private(set) lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = self
        return searchBar
    }()

    @IBOutlet private(set) weak var tableView: UITableView! {
        didSet {
            tableView.register(SearchCell.nib, forCellReuseIdentifier: SearchCell.identifier)
            tableView.dataSource = self
            tableView.delegate = self
        }
    }

    private(set) lazy var presenter = Presenter(view: self,
                                                state: SearchState(),
                                                mutation: SearchMutation())

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.titleView = searchBar
    }

    private func refrectEditing() {
        UIView.animate(withDuration: 0.3) {
            if self.presenter.state.isEditing {
                self.view.backgroundColor = .black
                self.tableView.isUserInteractionEnabled = false
                self.tableView.alpha = 0.5
                self.searchBar.setShowsCancelButton(true, animated: true)
            } else {
                self.searchBar.resignFirstResponder()
                self.view.backgroundColor = .white
                self.tableView.isUserInteractionEnabled = true
                self.tableView.alpha = 1
                self.searchBar.setShowsCancelButton(false, animated: true)
            }
        }
    }
}

extension SearchViewController: View {
    func refrect(change: ValueChange<SearchState>) {

        if change.valueIfChanged(for: \.isEditing) != nil {
            refrectEditing()
        }

        let repositories = change.new.repositories
        let repositoriesCount = repositories.count
        if let oldRepositories = change.old?.repositories,
            repositories.last?.id != oldRepositories.last?.id,
            repositoriesCount != oldRepositories.count {

            tableView.reloadData()

            if oldRepositories.count > 0 {
                let lastIndexPath = IndexPath(row: oldRepositories.count - 1, section: 0)
                tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: false)
            }
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        presenter.actionCreator.dispatch(action: .setIsEditing(true))
        return true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        presenter.actionCreator.dispatch(action: .setIsEditing(false))
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text, !text.isEmpty {
            presenter.actionCreator.dispatch(action: .clearRepositories)
            presenter.actionCreator.searchRepositories(query: text)
            presenter.actionCreator.dispatch(action: .setIsEditing(false))
        }
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.state.repositories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchCell.identifier, for: indexPath)

        if let cell = cell as? SearchCell {
            let repository = presenter.state.repositories[indexPath.row]
            cell.configure(with: repository)
        }

        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        presenter.selectedIndexPath(indexPath)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentSize.height - scrollView.bounds.size.height) <= scrollView.contentOffset.y {
            presenter.fetchMore()
        }
    }
}
