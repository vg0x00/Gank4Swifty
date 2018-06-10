//
//  BannerCell.swift
//  Gank4Swifty
//
//  Created by vg0x00 on 6/4/18.
//  Copyright © 2018 vg0x00. All rights reserved.
//

import UIKit

class BannerCellView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.frame = bounds
        gradientView.frame = bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var imageView: UIImageView = {
        var imageView = UIImageView(frame: bounds)
        print("debug image bounds: \(bounds)")
        imageView.contentMode = .scaleAspectFill
//        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    lazy var gradientView: UIView = {
        let view = UIView(frame: bounds)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.darkGray.cgColor]
        gradientLayer.startPoint = .zero
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
//        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var textLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    func config(image: UIImage, title: String) {

        addSubview(imageView)

//        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
//        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
//        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
//        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        addSubview(gradientView)

//        gradientView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
//        gradientView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
//        gradientView.topAnchor.constraint(equalTo: topAnchor).isActive = true
//        gradientView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        addSubview(textLabel)
        textLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12).isActive = true

        self.imageView.image = image
        self.textLabel.text = title

    }
}
