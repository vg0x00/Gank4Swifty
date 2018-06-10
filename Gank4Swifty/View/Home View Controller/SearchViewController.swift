//
//  SearchViewController.swift
//  Gank4Swifty
//
//  Created by vg0x00 on 5/5/18.
//  Copyright © 2018 vg0x00. All rights reserved.
//

import UIKit
import SafariServices

class SearchViewController: UIViewController {
    var items = [ModelPresentable]() {
        didSet {
            tableView.reloadData()
        }
    }
    @IBOutlet weak var emptyHolderView: UIView!
    let searchItems = ["autolayout", "tableview", "json", "iOS", "MVC", "Mac OS", "Swift"]
    @IBAction func searchButtonTapped(_ sender: IBDesignableButton) {
        guard let searchBar = searchViewController?.searchBar else { return }
        searchBar.text = searchItems[sender.tag]
        searchBarTextDidEndEditing(searchBar)
    }

    @IBOutlet weak var noSearchResultTextLabel: UILabel!
    @IBOutlet weak var noSearchResultView: UIView!
    var currentPage: Int = 1
    var currentTask: URLSessionTask?
    var isLoadingMore = false
    var queryText = ""

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
            self.noSearchResultView.isHidden = false
            self.noSearchResultTextLabel.text = "未找到关于\"\(queryText)\"的搜索结果"
            hideHUD()
            return
        }

        let filteredResult = results.filter { $0.type != "Android" }
        items.removeAll()
        items.append(contentsOf: filteredResult.map { DataModelItem(withModel: $0) })
        hideHUD()
        emptyHolderView.isHidden = true
        searchViewController?.searchBar.resignFirstResponder()
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchHandler(searchBar)
        tableView.separatorStyle = .singleLine
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchHandler(searchBar)
    }

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        items.removeAll()
        tableView.separatorStyle = .none
        return true
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.emptyHolderView.isHidden = searchText.isEmpty ? false : true
        self.noSearchResultView.isHidden = true
    }

    func searchHandler(_ searchBar: UISearchBar) {
        self.noSearchResultView.isHidden = true

        guard let queryString = searchViewController?.searchBar.text,
            let urlStr = "https://gank.io/api/search/query/\(queryString)/category/all/count/20/page/\(currentPage)"
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: urlStr) else {
                showHUD(.warnning)
                return
        }
        queryText = queryString
        showHUD()
//        currentTask = apiManager.dataTask(withRequest: URLRequest(url: url))
        currentTask = apiManager.dataTask(withURL: url, onFailure: { (error) in
            DispatchQueue.main.async {
                self.updateHUD(with: .processingFail)
            }
        }, onSuccess: { (data) in
            DispatchQueue.main.async {
                self.apiManagerOnSuccess(withData: data)
            }
        })
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
        guard let url = items[indexPath.row].url else { return }

        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
    }
}
