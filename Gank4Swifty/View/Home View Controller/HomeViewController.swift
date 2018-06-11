//
//  ViewController.swift
//  Gank4Swifty
//
//  Created by vg0x00 on 5/4/18.
//  Copyright © 2018 vg0x00. All rights reserved.
//

import UIKit
import SafariServices

class HomeViewController: BasePageViewController {
    @IBOutlet weak var calendarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var calendarView: CalendarView!
    @IBOutlet weak var dimMask: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var calendarButton: UIBarButtonItem!
    @IBOutlet weak var headerBar: UIView!
    @IBOutlet var apiManager: APIManager! {
        didSet {
            apiManager.delegate = self
        }
    }

    
    @IBOutlet weak var headerBarTextLabel: UILabel!
    var historyModelContainer: HistoryModelContainer? {
        didSet {
            tableView.reloadData()
            if calendarViewVisible() {
                animateCalendarIfNeeded(true)
            }
        }
    }

    var selectedModelItem: DataModel?
    var currentTask: URLSessionTask?
    var bannerItems = [DataModel]()
    var bannerSubviews = [BannerView]()

    @IBAction func calendarButtonTapped(_ sender: UIBarButtonItem) {
        animateCalendarIfNeeded(true)
    }

    @IBAction func maskViewTapped(_ sender: UITapGestureRecognizer) {
        calendarBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            self.dimMask.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    private func calendarViewVisible() -> Bool {
        return calendarBottomConstraint.constant != 0
    }

    private func animateCalendarIfNeeded(_ shouldAnimate: Bool) {
        let targetConstant: CGFloat = calendarBottomConstraint.constant == 0 ? 336 : 0
        let targetShadowMaskAlpha: CGFloat = targetConstant == 0 ? 0 : 0.4
        calendarBottomConstraint.constant = targetConstant
        let calendarButtonActived = targetConstant == 0 ? false: true
        if calendarButtonActived {
            calendarButton.image = UIImage(named: "icons8-overtime_filled")
        } else {
            calendarButton.image = UIImage(named: "icons8-overtime")
        }
        if shouldAnimate {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                self.dimMask.alpha = targetShadowMaskAlpha
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCalendarData()
        fetchBannerData()
        tableView.register(UINib(nibName: "HomeTabelViewCell", bundle: nil), forCellReuseIdentifier: "tableViewCellId")
        tableView.estimatedRowHeight = 100
        tableView.estimatedSectionHeaderHeight = 100
        calendarView.delegate = self
        tableView.addHeaderRefreshControl(delegate: self)

    }

    func showAndHideHeaderBar() {
        UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseInOut, animations: {
            self.headerBar.transform = CGAffineTransform(translationX: 0, y: 40)
        }, completion: nil)

        UIView.animate(withDuration: 0.2, delay: 1.5, options: .curveEaseIn, animations: {
            self.headerBar.transform = .identity
        }, completion: nil)
    }

    func fetchCalendarData() {
        guard let url = URL(string: "https://gank.io/api/day/history") else { return }
        showHUD()
        currentTask = apiManager.dataTask(withRequest: URLRequest(url: url))
    }

}

extension HomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sectionCount = historyModelContainer?.category.count else { return 1 }
        return sectionCount + 1 // "1" for banner view cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section > 0 {
        guard let secionName = historyModelContainer?.category[section - 1],
            let itemsCountInSecion = historyModelContainer?.results[secionName]?.count else { return 0 }
        return itemsCountInSecion
        } else { return 1 }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 { // for banner view
            let cell = tableView.dequeueReusableCell(withIdentifier: "bannerCellId", for: indexPath) as! BannerTableViewCell
            cell.configWithModelItems(bannerItems: bannerItems)
            cell.bannerSelectionHandler = { (url)  in
                let safariConcontroller = SFSafariViewController(url: url)
                self.present(safariConcontroller, animated: true, completion: nil)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCellId", for: indexPath) as! HomeTabelViewCell
            guard let category = historyModelContainer?.category[indexPath.section - 1],
                let modelDict = historyModelContainer?.results,
                let modelList = modelDict[category] else { return cell }
            let model = DataModelItem(withModel: modelList[indexPath.row])

            cell.config(withModelPresentable: model)
            cell.previewInteractionObject = UIPreviewInteraction(view: cell.contentView)
            cell.previewInteractionObject?.delegate = self
            return cell
        }
    }
}


extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section != 0 {
            let header = tableView.dequeueReusableCell(withIdentifier: "headerCellId") as! HomeTableHeaderView
            header.titleLabel.text = historyModelContainer?.category[section - 1]
            return header
        }
        return nil // for banner view, disable header in section
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 0 {
            guard let category = historyModelContainer?.category[indexPath.section - 1],
                let modelDict = historyModelContainer?.results,
                let modelList = modelDict[category] else { return }
            let modelItem = modelList[indexPath.row]

            selectedItem = DataModelItem(withModel: modelItem)
            if !isDuring3DTouch {
                guard let url = URL(string: modelItem.url) else { return }
                let safariViewController = SFSafariViewController(url: url)
                safariViewController.preferredBarTintColor = UIColor(hex: 0xFF6B81)
                safariViewController.preferredControlTintColor = UIColor.white
                safariViewController.delegate = self
                present(safariViewController, animated: true, completion: nil)
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            let tableViewWidth = tableView.bounds.width
            let targetHeight = tableViewWidth * 9 / 16
            return targetHeight
        } else {
            return UITableViewAutomaticDimension
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return UITableViewAutomaticDimension
        }
    }
}

extension HomeViewController: APIManagerDelegate {
    func apiManagerOnFailure(withError error: String) {
        print("debug fetching calendar info error: \(error)")
        updateHUD(with: .processingFail)
    }

    func apiManagerOnSuccess(withData data: Data) {
        let jsonDecoder = JSONDecoder()
        guard let results = try? jsonDecoder.decode(CalendarModel.self, from: data).results else {
            print("decode error")
            updateHUD(with: .processingFail)
            return
        }

        let dates = results.map { DateUtil.getDate(withString: $0, format: "yyyy-MM-dd") }
        self.calendarView.gankDates = dates

        fetchHistory(withDate: results.first)
    }

    func fetchHistory(withDate target: String?) {
        guard let targetDate = target else { return }
        let targetDateString = targetDate.replacingOccurrences(of: "-", with: "/")
        // NOTE: url example: http://gank.io/api/day/2015/08/07
        let query = "https://gank.io/api/day/".appending(targetDateString)
        guard let url = URL(string: query) else { return }

        currentTask = apiManager.dataTask(withURL: url, onFailure: { [unowned self] (error) in
            self.updateHUD(with: .processingFail)
            print("got error when fetching history data: \(error)")
            self.calendarView.isLoading = false
        }) { (data) in
            let jsonDecoder = JSONDecoder()
            guard var container = try? jsonDecoder.decode(HistoryModelContainer.self, from: data) else {
                print("json decode error")
                self.calendarView.isLoading = false
                return
            }
            container.category = container.category.filter{ !$0.contains("Android") }
            DispatchQueue.main.async {
                self.hideHUD()
                self.historyModelContainer = container
                self.calendarView.isLoading = false
                self.headerBarTextLabel.text = "期刊号: G:\(targetDate)"
                self.showAndHideHeaderBar()
            }
        }
    }

    func fetchBannerData() {
        guard let url = URL(string: "https://gank.io/api/random/data/iOS/20") else { return }
        currentTask = apiManager.dataTask(withURL: url, onFailure: { (error) in
            print("debug fetch banner data error: \(error)")
        }, onSuccess: { (data) in
            let jsonDecoder = JSONDecoder()
            guard let jsonResult = try? jsonDecoder.decode(NormalModelContainer.self, from: data) else { return }
            var targetItems = jsonResult.results.filter({ (model) -> Bool in
                return model.images != nil && !model.images!.isEmpty && model.images!.first!.hasPrefix("http://img.gank.io")
            })

            self.bannerItems = Array(targetItems.prefix(5))
        })
    }

}

extension HomeViewController: CalendarViewDelegate {
    func calendarView(didSelect item: String) {
        fetchHistory(withDate: item)
    }
}

extension HomeViewController: RefreshControlDelegate {
    func refreshControlDidRefresh(sender: RefreshControlAdaptable) {
        fetchCalendarData()
        fetchBannerData()
        sender.stopRefreshing()
    }
}
