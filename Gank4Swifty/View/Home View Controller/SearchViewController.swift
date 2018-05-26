//
//  SearchViewController.swift
//  Gank4Swifty
//
//  Created by vg0x00 on 5/5/18.
//  Copyright © 2018 vg0x00. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    var items = [ModelPresentable]() {
        didSet {
            tableView.reloadData()
        }
    }

    var currentPage: Int = 1
    var currentTask: URLSessionTask?
    var selectedItem: ModelPresentable?
    var isLoadingMore = false

    @IBOutlet var apiManager: APIManager! {
        didSet {
            apiManager.delegate = self
        }
    }

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(UINib(nibName: "HomeTabelViewCell", bundle: nil), forCellReuseIdentifier: "searchTableViewCellId")
        }
    }

    lazy var searchViewController: UISearchController? = {
        let searchViewController = UISearchController(searchResultsController: nil)
        searchViewController.hidesNavigationBarDuringPresentation = false
        searchViewController.dimsBackgroundDuringPresentation = false
        return searchViewController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let searchBar = searchViewController?.searchBar else { return }

        // NOTE: set UISearchController cancel button title as a trick
        searchBar.setValue("返回", forKey: "_cancelButtonText")

        searchBar.placeholder = "搜索干货"
        searchBar.sizeToFit()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let modelItem = selectedItem else { return }
        if segue.identifier == "showDetailFromSearch" {
            let targetController = segue.destination as! DetailViewController
            targetController.modelItem = modelItem
        }
    }
}

extension SearchViewController: APIManagerDelegate {
    func apiManagerOnFailure(withError error: String) {
        updateHUD(with: .processingFail)
        print("error")
    }

    func apiManagerOnSuccess(withData data: Data) {
        let jsonDecoder = JSONDecoder()
        guard let resultContainer = try? jsonDecoder.decode(NormalModelContainer.self, from: data) else {
            updateHUD(with: .processingFail)
            print("json decode error")
            return
        }
        let results = resultContainer.results
        guard results.count != 0  else {
            // TODO show no search result data indicator
            print("no search results")
            if !isLoadingMore {
                items.removeAll()
            }
            showHUD(.noMoreData)
            return
        }

        let filteredResult = results.filter { $0.type != "Android" }
        items.append(contentsOf: filteredResult.map { DataModelItem(withModel: $0) })
        hideHUD()
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let queryString = searchViewController?.searchBar.text,
        let urlStr = "http://gank.io/api/search/query/\(queryString)/category/all/count/20/page/\(currentPage)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: urlStr) else {
                showHUD(.warnning)
                return
        }
        showHUD()
        currentTask = apiManager.dataTask(withRequest: URLRequest(url: url))
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchViewController?.searchResultsUpdater = nil
        self.searchViewController?.searchBar.delegate = nil
        self.searchViewController?.delegate = nil
        self.searchViewController = nil
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchTableViewCellId", for: indexPath) as! HomeTabelViewCell
        let model = items[indexPath.row]
        cell.config(withModelPresentable: model)
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedItem = items[indexPath.row]
        performSegue(withIdentifier: "showDetailFromSearch", sender: self)
    }
}
