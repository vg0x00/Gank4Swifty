//
//  CategoryPageViewController.swift
//  Gank4Swifty
//
//  Created by vg0x00 on 5/12/18.
//  Copyright © 2018 vg0x00. All rights reserved.
//

import UIKit

class CategoryPageViewController: UIViewController {
    var pageType: String = "all"
    var pageNumber: Int = 1
    let pageCount: Int = 20
    let pageCellId = "pageCellId"
    var isLoadingMore = false
    var currentTask: URLSessionTask?
    var isReloading: Bool = false
    var refreshControl: RefreshControlAdaptable?

    var items = [ModelPresentable]() {
        didSet {
            print("items count: \(items.count)")
            tableView.reloadData()
        }
    }
    var selectedItem: ModelPresentable?
    var observer: NSObjectProtocol?
    var dataInitialized = false

    @IBOutlet var apiManager: APIManager! {
        didSet {
            apiManager.delegate = self
        }
    }

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(UINib(nibName: "HomeTabelViewCell", bundle: nil), forCellReuseIdentifier: pageCellId)
            tableView.addHeaderRefreshControl(delegate: self)
            tableView.addFooterRefreshControl(delegate: self)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        observer = NotificationCenter.default.addObserver(forName: Notification.Name.categoryPageIndexChanged, object: nil, queue: .main) { (notification) in
            guard let target = notification.object as? CategoryViewController else { return }
            if target.targetPageType == self.pageType {
                self.initData()
            }
        }
    }

    deinit {
        guard let observer = observer else { return }
        NotificationCenter.default.removeObserver(observer)
    }

    func initData() {
        if !dataInitialized {
            dataInitialized = true
            fetchPageInfo()
        }
    }

    func fetchPageInfo() {
        guard let queryUrl = "http://gank.io/api/data/\(pageType)/\(pageCount)/\(pageNumber)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: queryUrl) else { return }
        showHUD()
        currentTask = apiManager.dataTask(withRequest: URLRequest(url: url))
    }

    func reloadPageInfo() {
        items.removeAll()
        pageNumber = 1
        isReloading = true
        guard let queryUrl = "http://gank.io/api/data/\(pageType)/\(pageCount)/\(pageNumber)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: queryUrl) else { return }
        currentTask = apiManager.dataTask(withRequest: URLRequest(url: url))
    }

    func loadMorePageInfo() {
        isLoadingMore = true
        guard let queryUrl = "http://gank.io/api/data/\(pageType)/\(pageCount)/\(pageNumber)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: queryUrl) else { return }
        currentTask = apiManager.dataTask(withRequest: URLRequest(url: url))
    }
}

extension CategoryPageViewController: APIManagerDelegate {
    func apiManagerOnFailure(withError error: String) {
        print("api error: \(error)")
        if !isReloading {
            updateHUD(with: .processingFail)
        } else {
            showHUD(.processingFail)
            refreshControl?.stopRefreshing()
        }
        dataInitialized = false
        isReloading = false
    }

    func apiManagerOnSuccess(withData data: Data) {
        let jsonDecoder = JSONDecoder()
        guard let resultContainer = try? jsonDecoder.decode(NormalModelContainer.self, from: data) else {
            print("json decode error")
            if !isLoadingMore {
                updateHUD(with: .processingFail)
            } else {
                showHUD(.processingFail)
                refreshControl?.stopRefreshing()
            }
            return
        }
        let results = resultContainer.results
        if !isLoadingMore && !isReloading {
            hideHUD()
        } else {
            refreshControl?.stopRefreshing()
        }
        items.append(contentsOf: results.map { DataModelItem(withModel: $0) })
        pageNumber = pageNumber + 1
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPageDetial" {
            let target = segue.destination as! DetailViewController
            target.modelItem = selectedItem
        }
    }
}

extension CategoryPageViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: pageCellId, for: indexPath) as! HomeTabelViewCell
        let model = items[indexPath.row]
        cell.config(withModelPresentable: model)
        return cell
    }
}

extension CategoryPageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedItem = items[indexPath.row]
        performSegue(withIdentifier: "showPageDetial", sender: self)
    }
}

extension CategoryPageViewController: RefreshControlDelegate {
    func refreshControlDidRefresh(sender: RefreshControlAdaptable) {
        switch sender.type {
        case .header:
            print("header refreshing...")
            self.refreshControl = sender
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                DispatchQueue.main.async {
                    self.reloadPageInfo()
                }
            }
        case .footer:
            print("footer refreshing...")
            self.refreshControl = sender
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                DispatchQueue.main.async {
                    self.loadMorePageInfo()
                }
            }
        }
    }
}
