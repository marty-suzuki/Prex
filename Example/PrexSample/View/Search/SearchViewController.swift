//
//  SearchViewController.swift
//  PrexSample
//
//  Created by marty-suzuki on 2018/09/29.
//  Copyright © 2018 marty-suzuki. All rights reserved.
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        presenter.selectedIndexPath(nil)
    }

    private func refrectEditing(isEditing: Bool) {
        UIView.animate(withDuration: 0.3) {
            if isEditing {
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

    private func showDetail(repository: GitHub.Repository) {
        let vc = DetailViewController(repository: repository)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension SearchViewController: View {
    func refrect(change: ValueChange<SearchState>) {

        if let isEditing = change.valueIfChanged(for: \.isEditing) {
            refrectEditing(isEditing: isEditing)
        }

        if let new = change.valueIfChanged(for: \.repositories) {
            tableView.reloadData()

            if new.count > 0, let old = change.old?.repositories, old.count > 0 {
                let lastIndexPath = IndexPath(row: old.count - 1, section: 0)
                tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: false)
            }
        }

        if let repository = change.valueIfChanged(for: \.selectedRepository)?.value {
            showDetail(repository: repository)
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        presenter.setIsEditing(true)
        return true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        presenter.setIsEditing(false)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text, !text.isEmpty {
            presenter.clearRepositories()
            presenter.fetchRepositories(query: text)
            presenter.setIsEditing(false)
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
            presenter.fetchMoreRepositories()
        }
    }
}
