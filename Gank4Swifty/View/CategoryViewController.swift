//
//  CategoryViewController.swift
//  Gank4Swifty
//
//  Created by vg0x00 on 5/11/18.
//  Copyright © 2018 vg0x00. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController {
    @IBOutlet weak var navItemContainer: UIStackView!
    @IBOutlet weak var topSegmentControl: UIScrollView!
    @IBOutlet weak var bottomContentScrollView: UIScrollView! {
        didSet {
            bottomContentScrollView.delegate = self
        }
    }
    var indicatorBar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 1
        view.backgroundColor = UIColor(displayP3Red: 241 / 255, green: 242 / 255, blue: 246 / 255, alpha: 1)
        return view
    }()

    let pageTypeList = ["iOS", "前端", "拓展资源", "休息视频", "福利", "all"]
    var currentPageIndex = 0 {
        didSet {
            targetPageType = pageTypeList[currentPageIndex]
        }
    }
    var previousPageIndex = 0
    lazy var targetPageType: String = "iOS"
    var currentIndicatorBarCenterX: NSLayoutConstraint?
    var currentIndicatorBarWidth: NSLayoutConstraint?

    @IBAction func segmentControlTapped(_ sender: UIButton) {
        let offset = bottomContentScrollView.bounds.width * CGFloat(sender.tag)
        bottomContentScrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
        previousPageIndex = currentPageIndex
        currentPageIndex = sender.tag
        updateIndicatorConstraint(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(indicatorBar)

        indicatorBar.bottomAnchor.constraint(equalTo: topSegmentControl.bottomAnchor, constant: -3).isActive = true
        indicatorBar.heightAnchor.constraint(equalToConstant: 2).isActive = true
        updateIndicatorConstraint(animated: false)
        self.topSegmentControl.setContentOffset(CGPoint(x: -10, y: 0), animated: false)
    }

    func updateIndicatorConstraint(animated: Bool) {
        if let centerX = currentIndicatorBarCenterX,
            let width = currentIndicatorBarWidth {
            centerX.isActive = false
            width.isActive = false
        }

        let item = navItemContainer.arrangedSubviews[currentPageIndex] as! UIButton
        self.currentIndicatorBarCenterX =  indicatorBar.centerXAnchor.constraint(equalTo: item.centerXAnchor)
        self.currentIndicatorBarWidth =  indicatorBar.widthAnchor.constraint(equalTo: item.widthAnchor)

        self.currentIndicatorBarCenterX?.isActive = true
        self.currentIndicatorBarWidth?.isActive = true

        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.indicatorBar.superview?.layoutIfNeeded()
            }) { (completed) in
                let isTurnRight = (self.currentPageIndex - self.previousPageIndex) > 0
                let item = self.navItemContainer.arrangedSubviews[self.currentPageIndex]
                let visibleRect = CGRect(origin: self.topSegmentControl.contentOffset, size: self.topSegmentControl.bounds.size)

                if isTurnRight {
                    let maxX = item.frame.maxX
                    let offset = maxX - visibleRect.size.width
                    print("debug: offest: \(offset + 20)")
                    if offset + 10 > 0 {
                        self.topSegmentControl.setContentOffset(CGPoint(x: offset + 10, y: 0), animated: true)
                    }
                } else {
                    let offset = item.frame.minX - visibleRect.minX
                    if offset - 10 < 0 {
                        self.topSegmentControl.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
                    }
                }
                print("debug: \(self.topSegmentControl.contentOffset.x)")
            }
        } else {
            self.indicatorBar.superview?.layoutIfNeeded()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: .categoryPageIndexChanged, object: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let target = segue.destination as! CategoryPageViewController
        switch segue.identifier {
        case "iOS":
            target.pageType = "iOS"
        case "web":
            target.pageType = "前端"
        case "expandResource":
            target.pageType = "拓展资源"
        case "video":
            target.pageType = "休息视频"
        case "meizi":
            target.pageType = "福利"
        default:
            target.pageType = "all"
        }
    }
}

extension CategoryViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let targetIndex = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        if currentPageIndex != targetIndex {
            previousPageIndex = currentPageIndex
            currentPageIndex = targetIndex
            NotificationCenter.default.post(name: .categoryPageIndexChanged, object: self)
            updateIndicatorConstraint(animated: true)
        }
    }
}

extension NSNotification.Name {
    static let categoryPageIndexChanged = NSNotification.Name("categoryPageIndexChanged")
}
