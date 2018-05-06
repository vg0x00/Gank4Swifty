//
//  SearchViewController.swift
//  Gank4Swifty
//
//  Created by vg0x00 on 5/5/18.
//  Copyright © 2018 vg0x00. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    var items: [String] = ["nihao", "lisi", "wnagwu", "zhaohl"]
    var filteredItems: [String] = [String]()

    @IBOutlet weak var tableView: UITableView!

    lazy var searchViewController: UISearchController = {
        let searchViewController = UISearchController(searchResultsController: nil)
        searchViewController.searchResultsUpdater = self
        searchViewController.hidesNavigationBarDuringPresentation = false
        searchViewController.dimsBackgroundDuringPresentation = false
        return searchViewController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        let searchBar = searchViewController.searchBar
        // NOTE: set UISearchController cancel button title as a trick
        searchBar.setValue("返回", forKey: "_cancelButtonText")
        searchBar.placeholder = "搜索干货"
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        definesPresentationContext = true
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let filterTarget = searchViewController.searchBar.text else { return }
        filteredItems = items.filter { $0.contains(filterTarget) }
        tableView.reloadData()
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCellId", for: indexPath)
        cell.textLabel?.text = filteredItems[indexPath.row]
        return cell
    }
}
