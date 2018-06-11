//
//  BannerTableViewCell.swift
//  Gank4Swifty
//
//  Created by vg0x00 on 6/4/18.
//  Copyright © 2018 vg0x00. All rights reserved.
//

import UIKit
import Kingfisher
import SafariServices

class BannerTableViewCell: UITableViewCell {
    lazy var bannerScrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.bounces = false
        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        view.delegate = self
        return view
    }()

    var bannerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    typealias BannerSelectionHandler = (URL) -> Void

    var bannerSelectionHandler: BannerSelectionHandler?

    @objc func bannerPanGuestureHandler(sender: UIPanGestureRecognizer) {
        let pageIndex = pageControl.currentPage
        guard let items = items else { return }
        let urlString = items[pageIndex].url
        guard let url = URL(string: urlString) else { return }
        bannerSelectionHandler?(url)
    }

    var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.hidesForSinglePage = true
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()

    weak var timer: Timer? {
        didSet {
            print("debug timer setted valid: \(timer?.isValid)")
        }
    }

    var currentPageIndex = 0

    var items: [DataModel]? {
        didSet {
            print("debug banner items count: \(items?.count ?? 0)")
        }
    }

    var lastBannerView: BannerView?

    @objc func timerHandler() {
        DispatchQueue.main.async {
            let totalPageCount = self.bannerStack.arrangedSubviews.count
            if totalPageCount > 0 {
                var offsetX = self.bannerScrollView.contentOffset.x
                var targetOffsetX = offsetX + self.bannerScrollView.bounds.width

                if targetOffsetX == self.bannerScrollView.contentSize.width - self.bannerScrollView.bounds.width {
                    self.pageControl.currentPage = 0
                    // NOTE: setContentOffset methods does not change content offset immediately
                    //       use UIView's animation manually.
                    UIView.animate(withDuration: 0.25, animations: {
                        self.bannerScrollView.contentOffset = CGPoint(x: targetOffsetX, y: 0)
                    }, completion: { (completed) in
                        self.bannerScrollView.contentOffset = .zero
                    })
                } else {
                    self.pageControl.currentPage = self.pageControl.currentPage + 1
                    self.bannerScrollView.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: true)
                }
            }
        }
    }


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentView.addSubview(bannerScrollView)
        bannerScrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        bannerScrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        bannerScrollView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        bannerScrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true

        bannerScrollView.addSubview(bannerStack)
        bannerStack.leadingAnchor.constraint(equalTo: bannerScrollView.leadingAnchor).isActive = true
        bannerStack.trailingAnchor.constraint(equalTo: bannerScrollView.trailingAnchor).isActive = true
        bannerStack.topAnchor.constraint(equalTo: bannerScrollView.topAnchor).isActive = true
        bannerStack.bottomAnchor.constraint(equalTo: bannerScrollView.bottomAnchor).isActive = true
        bannerStack.heightAnchor.constraint(equalTo: bannerScrollView.heightAnchor, multiplier: 1).isActive = true

        contentView.addSubview(pageControl)
        pageControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        pageControl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(bannerPanGuestureHandler(sender:)))
        bannerScrollView.addGestureRecognizer(tap)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch bannerScrollView.panGestureRecognizer.state {
        case .ended:
            print("touch ended")
        default:
            break
        }
    }

    private func createBannerViewWithModel(model: DataModel) -> BannerView {
        let v = UINib(nibName: "BannerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! BannerView
        if let imageUrlString = model.images!.first {
            if let imageUrl = URL(string: imageUrlString) {
                v.bannerImageView.kf.setImage(with: imageUrl, placeholder: nil, options: [KingfisherOptionsInfoItem.onlyLoadFirstFrame], progressBlock: nil, completionHandler: nil)
            }
        }
        v.titleLabel.text = model.desc

        return v
    }

    func configWithModelItems(bannerItems: [DataModel]) {
        bannerStack.arrangedSubviews.map {
            bannerStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        bannerItems.map { (model) -> BannerView in
            return createBannerViewWithModel(model: model)
            }.map {
                bannerStack.addArrangedSubview($0)
                $0.widthAnchor.constraint(equalTo: bannerScrollView.widthAnchor, multiplier: 1).isActive = true
                $0.heightAnchor.constraint(equalTo: bannerScrollView.heightAnchor, multiplier: 1).isActive = true
        }

        if let firstItem = bannerItems.first, bannerItems.count > 1 {
            lastBannerView = createBannerViewWithModel(model: firstItem)
            bannerStack.addArrangedSubview(lastBannerView!)
        }

        pageControl.numberOfPages = bannerItems.count

        items = bannerItems

        resetTimerState()
    }

    private func resetTimerState() {
        self.bannerScrollView.contentOffset = .zero
        self.pageControl.currentPage = 0
        clearTimer()
        if self.bannerStack.arrangedSubviews.count > 1 {
            resumeTimer()
        }
    }

    func clearTimer() {
        guard let timer = timer else { return }
        if timer.isValid {
            self.timer?.invalidate()
            self.timer = nil
        }
    }

    func pauseTimer() {
        clearTimer()
    }

    func resumeTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(self.timerHandler), userInfo: nil, repeats: true)
    }

    func dragBegin() {
        pauseTimer()
        guard let lastBannerView = lastBannerView else { return }
        bannerStack.removeArrangedSubview(lastBannerView)
    }

    func dragWillEnd() {
        resumeTimer()
        guard let lastBannerView = lastBannerView else { return }
        bannerStack.addArrangedSubview(lastBannerView)
    }

    deinit {
        print("debug deinit cell")
        timer?.invalidate()
    }
}

extension BannerTableViewCell: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let totalPageCount = bannerStack.arrangedSubviews.count
        if totalPageCount > 0 {
            let targetOffsetX = bannerScrollView.contentOffset.x
            bannerScrollView.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: true)
            pageControl.currentPage = Int(bannerScrollView.contentOffset.x / bannerScrollView.bounds.width)
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("debug drag will begin")
        dragBegin()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("debug did end draggin")
        dragWillEnd()
    }
}
