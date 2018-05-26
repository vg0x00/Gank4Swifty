//
//  HUDViewController.swift
//  Gank4Swifty
//
//  Created by vg0x00 on 5/13/18.
//  Copyright © 2018 vg0x00. All rights reserved.
//

import UIKit

enum HUDType {
    case processing
    case processingFail
    case warnning
    case noMoreData
}

class HUDViewController: UIViewController {
    static let shared = HUDViewController()
    
    lazy var infoLabel: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor.white
        return button
    }()

    lazy var hudView: UIView =  {
        let hud = UIView()
        hud.translatesAutoresizingMaskIntoConstraints = false
        hud.layer.cornerRadius = 10
        return hud
    }()
    
    lazy var spinnerView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    lazy var darkView: UIView = {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = UIColor.init(hex: 0xF1F2F6, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var observer: NSObjectProtocol?

    var parentView: UIView!
    var textColor: UIColor = UIColor.white

    var tintColor: UIColor = UIColor.init(hex: 0x38ADA9, alpha: 1) {
        didSet {
            self.hudView.backgroundColor = tintColor
        }
    }

    var spinnerImage: UIImage! {
        didSet {
            spinnerView.image = spinnerImage.withRenderingMode(.alwaysTemplate)
            spinnerView.tintColor = UIColor.white
        }
    }

    var labelText: String! {
        didSet {
            infoLabel.setTitle(labelText, for: .normal)
        }
    }

    var userInteractable: Bool = false {
        didSet {
            view.isUserInteractionEnabled = userInteractable
        }
    }

    var animateSpinnyView: Bool = false {
        didSet {
            if animateSpinnyView {
                spinnerView.startRotaing()
            } else {
                spinnerView.stopRotating()
            }
        }
    }
    var autoHide: Bool = false {
        didSet {
            if autoHide {
               hide(delay: 2)
            }
        }
    }

    var type: HUDType! {
        didSet {
            updateUI()
        }
    }

    func hide(delay: TimeInterval) {
        UIView.animate(withDuration: 0.3, delay: delay, options: .curveEaseOut, animations: {
            self.hudView.alpha = 0
            self.darkView.alpha = 0
        }) { (completed) in
            self.willMove(toParentViewController: nil)
            self.removeFromParentViewController()
            self.view.removeFromSuperview()
        }
    }

    // common setup for all hud type
    fileprivate func setupDinnView() {
        parentView.addSubview(darkView)
        darkView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
        darkView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = true
        darkView.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
        darkView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
        UIView.animate(withDuration: 0.3) {
            self.darkView.alpha = 1
        }
    }

    fileprivate func setupUI() {
        hudView.addSubview(spinnerView)
        spinnerView.centerXAnchor.constraint(equalTo: hudView.centerXAnchor).isActive = true
        spinnerView.centerYAnchor.constraint(equalTo: hudView.centerYAnchor, constant: -25).isActive = true
        spinnerView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        spinnerView.heightAnchor.constraint(equalToConstant: 44).isActive = true

        hudView.addSubview(infoLabel)
        infoLabel.bottomAnchor.constraint(equalTo: hudView.bottomAnchor, constant: -16).isActive = true
        infoLabel.centerXAnchor.constraint(equalTo: hudView.centerXAnchor).isActive = true

        view.addSubview(hudView)
        hudView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.65).isActive = true
        hudView.heightAnchor.constraint(equalToConstant: 140).isActive = true
        hudView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        hudView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

    }

    fileprivate func updateUI() {
        self.hudView.alpha = 1
        switch type {
        case .processing:
            userInteractable = false
            animateSpinnyView = true
            labelText = "载入中..."
            tintColor = UIColor(hex: 0x606568, alpha: 1)
            spinnerImage = UIImage(named: "icons8-reboot")
            autoHide = false
        case .processingFail:
            userInteractable = false
            animateSpinnyView = false
            labelText = "出错啦, 下拉刷新试试~~"
            tintColor = UIColor(hex: 0xEB5937, alpha: 1)
            spinnerImage = UIImage(named: "icons8-info")?.withRenderingMode(.alwaysTemplate)
            autoHide = true
        case .warnning:
            userInteractable = false
            animateSpinnyView = false
            labelText = "请求错误, 稍后再试试~~"
            tintColor = UIColor(hex: 0xEB5937, alpha: 1)
            spinnerImage = UIImage(named: "icons8-info")?.withRenderingMode(.alwaysTemplate)
            autoHide = true
        case .noMoreData:
            userInteractable = false
            animateSpinnyView = false
            labelText = "没有获取到数据~~"
            tintColor = UIColor(hex: 0xEB5937, alpha: 1)
            spinnerImage = UIImage(named: "icons8-info")?.withRenderingMode(.alwaysTemplate)
            autoHide = true
        default:
            break
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDinnView()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hudView.backgroundColor = tintColor
        if animateSpinnyView {
            spinnerView.startRotaing()
            self.observer = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidBecomeActive, object: nil, queue: .main) { (notification) in
                self.spinnerView.startRotaing()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let observer = self.observer else { return }
        NotificationCenter.default.removeObserver(observer)
    }
}
