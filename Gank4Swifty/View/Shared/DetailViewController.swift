//
//  DetailViewController.swift
//  Gank4Swifty
//
//  Created by vg0x00 on 5/7/18.
//  Copyright © 2018 vg0x00. All rights reserved.
//

import UIKit
import WebKit
import SafariServices

class DetailViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var urlIconButton: UIButton!
    @IBOutlet weak var authorIconButton: UIButton!
    @IBOutlet weak var dateIconButton: UIButton!
    @IBOutlet weak var categoryIconButton: UIButton!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var webContainer: UIView!
    @IBOutlet weak var topContainerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var topContainer: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var likeButton: UIBarButtonItem!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBAction func safariButtonTapped(_ sender: UIBarButtonItem) {
        guard let model = modelItem, let url = model.url else {
            return
        }

        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
    }

    @IBAction func shareButtonTapped(_ sender: UIBarButtonItem) {
        guard let item = modelItem, let url = item.url else { return }
        let thingsToShare = [item.title, url] as [Any]
        let activityController = UIActivityViewController(activityItems: thingsToShare, applicationActivities: nil)
        activityController.excludedActivityTypes = [.addToReadingList, .airDrop, .openInIBooks, .postToFacebook, .postToVimeo, .postToFlickr, .postToTwitter, .print, .saveToCameraRoll]
        present(activityController, animated: true, completion: nil)
    }

    @IBAction func likeButtonTapped(_ sender: UIBarButtonItem) {
        guard let modelItem = modelItem else { return }
        if modelInCollection(model: modelItem as! DataModelItem) {
            LocalDataPersistenceManager.shared.remove(model: modelItem as! DataModelItem) {
                self.updateLikeButtonState()
            }
        } else {
            LocalDataPersistenceManager.shared.add(model: modelItem as! DataModelItem) {
                DispatchQueue.main.async {
                    print("debug: local data persistence done")
                    self.updateLikeButtonState()
                }
            }
        }
    }

    private func updateLikeButtonState() {
        if self.modelInCollection(model: modelItem as! DataModelItem) {
            self.likeButton.image = UIImage(named: "icons8-hearts_filled")
            self.likeButton.tintColor = UIColor(hex: 0xFF4757)
        } else {
            self.likeButton.image = UIImage(named: "icons8-hearts")
            self.likeButton.tintColor = UIColor(hex: 0xffffff)
        }
    }

    func modelInCollection(model: DataModelItem) -> Bool {
        let categoryKey = LocalDataPersistenceManager.getCategoryKeyByModelType(model: model)
        guard let url = model.url else { return false }
        return LocalDataPersistenceManager.shared.getAllModelDict()[categoryKey.rawValue]?.keys.contains((url.absoluteString)) ?? false
    }

    var modelItem: ModelPresentable?
    var apiManager = APIManager()
    
    lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        let webPreference = WKPreferences()
        webPreference.minimumFontSize = 16
        config.preferences = webPreference
        config.allowsInlineMediaPlayback = true
        config.allowsPictureInPictureMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.delegate = self
        webView.scrollView.alwaysBounceVertical = false
        webView.navigationDelegate = self
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateLikeButtonState()
    }

    func setupUI() {
        webContainer.addSubview(webView)
        webView.leadingAnchor.constraint(equalTo: webContainer.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: webContainer.trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: progressBar.bottomAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: webContainer.bottomAnchor).isActive = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let model = modelItem, let url = model.url else { return }
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.isLoading), options: .new, context: nil)
        updateLikeButtonState()
        config(withModel: model)
        renderPage(url: url, model: model)
    }

    private func renderPage(url: URL, model: ModelPresentable) {
            if url.absoluteString.hasPrefix("https://github.com") {
                let result = url.absoluteString.split(separator: "/").map { String($0) }

                let user = result[2]
                let repo = result[3]

                self.loadingIndicator.startAnimating()
                apiManager.fetchGithubRawReadme(user: user, repo: repo, failureHandler: { (error) in
                    print("fetch github read me file error: \(error)")
                    DispatchQueue.main.async {
                        self.loadingIndicator.stopAnimating()
                        self.showHUD(.processingFail)
                    }
                }) { (content) in
                    DispatchQueue.main.async {
                        self.loadingIndicator.stopAnimating()
                        self.webView.isHidden = true
                    }
                }
                return
            }

            if url.absoluteString.hasPrefix("https://mp.weixin.qq.com") || model.type == "福利"{
                self.webView.isHidden = false
                self.webView.load(URLRequest(url: url))
                return
            }

            if model.type == "休息视频" {
                UIApplication.shared.open(url, options: [:]) { (completed) in
                    self.navigationController?.popViewController(animated: false)
                }
            }

            self.loadingIndicator.startAnimating()
            apiManager.fetchHtmlString(url: url.absoluteString, failureHandler: { (error) in
                print("debug: Error: \(error)")
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    self.showHUD(.processingFail)
                }
            }) { (content) in
                var contentString = """
<header>
    <meta name="viewport" content="width=device-width,initial-scale=1.0,maximum-scale=1.0,user-scalable=0,viewport-fit=cover">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <style>h1 {visibility: hidden; } a {color: #0366d6; } img {width: 96vw; height: auto; margin-left: 2vw; margin-right: 2vw; margin-top: 2vw; margin-bottom: auto; padding: 0px;} body {margin: 0; font-family: -apple-system,BlinkMacSystemFont,"Segoe UI",Helvetica,Arial,sans-serif,"Apple Color Emoji","Segoe UI Emoji","Segoe UI Symbol"; font-size: 16px; line-height: 1.5; word-wrap: break-word;}</style>
</header>
"""
                contentString.append(content)
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    self.hideHUD()
                    self.webView.isHidden = false
                    self.webView.loadHTMLString(contentString, baseURL: nil)
                }
            }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.stopLoading()
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.isLoading))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }

    func config(withModel model: ModelPresentable) {
        titleLabel.text = model.title
        authorLabel.text = model.author
        categoryLabel.text = model.type
        if let url = model.url {
            urlLabel.text = url.absoluteString
        }
        dateLabel.text = model.date
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath, let _ = object as? WKWebView,
            let change = change else { return }
        switch keyPath {
        case #keyPath(WKWebView.estimatedProgress):
            guard let value = change[.newKey] as? NSNumber else { return }
            self.progressBar.setProgress(value.floatValue, animated: true)
        case #keyPath(WKWebView.isLoading):
            guard let isLoading = change[.newKey] as? Bool else { return }
            if !isLoading {
                self.progressBar.isHidden = true
            }
        default:
            break
        }
    }
}

extension DetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = min(scrollView.contentOffset.y, topContainer.bounds.height)
        topContainerViewTopConstraint.constant = -offsetY + 4
        let percent = 1 - offsetY / topContainer.bounds.height
        topContainer.alpha = percent
        view.layoutIfNeeded()
    }
}

extension DetailViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            guard let url = navigationAction.request.url else { return decisionHandler(.cancel) }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
