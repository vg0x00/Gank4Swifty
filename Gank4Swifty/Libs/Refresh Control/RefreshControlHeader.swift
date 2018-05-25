//
//  Footer.swift
//  tableRefresh
//
//  Created by vg0x00 on 5/16/18.
//  Copyright © 2018 vg0x00. All rights reserved.
//

import UIKit

class RefreshControlHeader: UIView, RefreshControlAdaptable {
    var type: RefreshControlType = .header

    var delegate: RefreshControlDelegate?

    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.text = "下拉以刷新"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()

    var indicatorView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "icons8-down_arrow")?.withRenderingMode(.alwaysTemplate))
        imageView.tintColor = UIColor.white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    var activityView: UIActivityIndicatorView = {
        let act = UIActivityIndicatorView()
        act.color = .white
        act.translatesAutoresizingMaskIntoConstraints = false
        return act
    }()

    var refreshControlContainer: UIScrollView?

    var state: RefreshControlState = .normal {
        didSet {
            handleStateChanged(state: state)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupComponentViews()
    }

    fileprivate func setupComponentViews() {
        addSubview(textLabel)
        textLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        textLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

        addSubview(indicatorView)
        indicatorView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        indicatorView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        indicatorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        indicatorView.trailingAnchor.constraint(equalTo: textLabel.leadingAnchor, constant: -4).isActive = true

        addSubview(activityView)
        activityView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        activityView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        activityView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        activityView.trailingAnchor.constraint(equalTo: textLabel.leadingAnchor, constant: -4).isActive = true
    }

    fileprivate func handleStateChanged(state: RefreshControlState) {
        switch state {
        case .normal:
            textLabel.text = "下拉以刷新"
            indicatorView.isHidden = false
            activityView.stopAnimating()
            self.refreshControlContainer?.contentInset = .zero
            UIView.animate(withDuration: 0.3) {
                self.indicatorView.transform = .identity
            }
        case .willRefreshing:
            textLabel.text = "松开以刷新"
            indicatorView.isHidden = false
            activityView.stopAnimating()
            UIView.animate(withDuration: 0.3) {
                self.indicatorView.transform = CGAffineTransform(rotationAngle: .pi)
            }
        case .refreshing:
            textLabel.text = "正在载入"
            indicatorView.isHidden = true
            activityView.startAnimating()
            refreshControlContainer?.contentInset = UIEdgeInsetsMake(50, 0, 0, 0)
        }
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        guard let scrollView = newSuperview as? UIScrollView else { return }
        refreshControlContainer = scrollView

        // NOTE - default frame needs update when scroll view
        //        content height > default frame height, handled by:
        //        (P)RefreshControlAdaptable > adjustRefreshControlFrame

        frame = CGRect(x: 0, y: -50, width: scrollView.bounds.width, height: 50)

        scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize), options: .new, context: nil)
        scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: .new, context: nil)
        scrollView.panGestureRecognizer.addTarget(self, action: #selector(adjustRefreshControlPanState(sender:)))
    }

    func adjustRefreshControlFrame(scrollView: UIScrollView) {
        frame.size.width = scrollView.contentSize.width
    }

    @objc func adjustRefreshControlState(scrollView: UIScrollView) {
        let refreshOffsetY = scrollView.contentOffset.y
//        print("debug: header offset Y: \(refreshOffsetY) - state: \(state) - inset top : \(scrollView.contentInset.top)")
        if refreshOffsetY < -50 && state != .refreshing {
            state = .willRefreshing
        }
    }

    @objc func adjustRefreshControlPanState(sender: UIPanGestureRecognizer) {
        if sender.state == .ended && state == .willRefreshing {
            state = .refreshing
            delegate?.refreshControlDidRefresh(sender: self)
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let path = keyPath,
            let scrollView = self.refreshControlContainer else { return }
        switch path {
        case #keyPath(UIScrollView.contentSize):
            adjustRefreshControlFrame(scrollView: scrollView)
        case #keyPath(UIScrollView.contentOffset):
            adjustRefreshControlFrame(scrollView: scrollView)
            adjustRefreshControlState(scrollView: scrollView)
        default:
            break
        }
    }

    func stopRefreshing() {
        state = .normal
    }

    deinit {
        guard let scrollView = superview as? UIScrollView else { return }
        scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize))
        scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

