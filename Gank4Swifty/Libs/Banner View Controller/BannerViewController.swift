//
//  BannerViewController.swift
//  Gank4Swifty
//
//  Created by vg0x00 on 6/3/18.
//  Copyright © 2018 vg0x00. All rights reserved.
//

import UIKit

class BannerViewController: UIViewController {
    lazy var bannerView: UIScrollView = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isPagingEnabled = true
        v.bounces = false
        v.showsHorizontalScrollIndicator = false
        return v
    }()

    lazy var bannerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    lazy var bannerPageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        setupBannerView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

//        updateBannerArragnedViews()
        bannerView.setNeedsDisplay()
        bannerView.setNeedsLayout()
    }

    func setupBannerView() {
        view.addSubview(bannerView)

        bannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bannerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bannerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        bannerView.addSubview(bannerStackView)

        bannerStackView.translatesAutoresizingMaskIntoConstraints = false
        bannerStackView.leadingAnchor.constraint(equalTo: bannerView.leadingAnchor).isActive = true
        bannerStackView.trailingAnchor.constraint(equalTo: bannerView.trailingAnchor).isActive = true
        bannerStackView.topAnchor.constraint(equalTo: bannerView.topAnchor).isActive = true
        bannerStackView.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor).isActive = true

        view.addSubview(bannerPageControl)
        bannerPageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        bannerPageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        updateBannerArragnedViews()
    }

    func updateBannerArragnedViews() {
        let imagesViews = ["girl1", "girl2", "girl3"].map { (name) -> UIImageView in
            let imageView = UIImageView(image: UIImage(named: name))
            imageView.contentMode = .scaleAspectFill
            addGradientView(targetView: imageView)
            return imageView
        }
        imagesViews.map { bannerStackView.addArrangedSubview($0) }

        bannerPageControl.numberOfPages = imagesViews.count
        guard  let firstImageView = imagesViews.first else {
            return
        }

        firstImageView.widthAnchor.constraint(equalTo: bannerView.widthAnchor, multiplier: 1).isActive = true
        firstImageView.heightAnchor.constraint(equalTo: bannerView.heightAnchor, multiplier: 1).isActive = true
    }

    func addGradientView(targetView: UIView) {
        let gradientView = UIView(frame: bannerView.bounds)
//        gradientView.translatesAutoresizingMaskIntoConstraints = false
//        gradientView.backgroundColor = UIColor.red

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bannerView.bounds
//        gradientLayer.frame = gradientView.bounds
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.darkGray.cgColor]
        gradientLayer.startPoint = .zero
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        gradientView.layer.insertSublayer(gradientLayer, at: 0)

        targetView.addSubview(gradientView)
//        gradientView.leadingAnchor.constraint(equalTo: targetView.leadingAnchor).isActive = true
//        gradientView.trailingAnchor.constraint(equalTo: targetView.trailingAnchor).isActive = true
//        gradientView.topAnchor.constraint(equalTo: targetView.topAnchor).isActive = true
//        gradientView.bottomAnchor.constraint(equalTo: targetView.bottomAnchor).isActive = true
        targetView.bringSubview(toFront: gradientView)
    }
}
