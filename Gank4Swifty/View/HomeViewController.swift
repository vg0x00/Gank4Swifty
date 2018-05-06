//
//  ViewController.swift
//  Gank4Swifty
//
//  Created by vg0x00 on 5/4/18.
//  Copyright © 2018 vg0x00. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var calendarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuView: UIView! 
    @IBOutlet weak var calendarView: CalendarView!
    @IBOutlet weak var dimMask: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var apiManager: APIManager!
    
    var items = [ModelPresentable]()
    
    @IBAction func menuButtonTapped(_ sender: UIBarButtonItem) {
        if calendarBottomConstraint.constant != 0 {
            UIView.animate(withDuration: 0.12, delay: 0, options: .curveEaseOut, animations: {
                self.animateCalendarIfNeeded(false)
                self.view.layoutIfNeeded()
            }) { (_) in
                self.animateMenuIfNeeded(true)
            }
        } else {
            animateMenuIfNeeded(true)
        }
    }

    @IBAction func calendarButtonTapped(_ sender: UIBarButtonItem) {
        if menuTrailingConstraint.constant != 0 {
            UIView.animate(withDuration: 0.12, delay: 0, options: .curveEaseOut, animations: {
                self.animateMenuIfNeeded(false)
                self.view.layoutIfNeeded()
            }) { (_) in
                self.animateCalendarIfNeeded(true)
            }
        } else {
            animateCalendarIfNeeded(true)
        }
    }

    @IBAction func maskViewTapped(_ sender: UITapGestureRecognizer) {
        calendarBottomConstraint.constant = 0
        menuTrailingConstraint.constant = 0
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            self.dimMask.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    private func animateCalendarIfNeeded(_ shouldAnimate: Bool) {
        let targetConstant: CGFloat = calendarBottomConstraint.constant == 0 ? 300 : 0
        let targetShadowMaskAlpha: CGFloat = targetConstant == 0 ? 0 : 0.4
        calendarBottomConstraint.constant = targetConstant
        if shouldAnimate {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                self.dimMask.alpha = targetShadowMaskAlpha
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }

    private func animateMenuIfNeeded(_ shouldAnimate: Bool) {
        let targetConstant: CGFloat = menuTrailingConstraint.constant == 0 ? 180 : 0
        let targetShadowMaskAlpha: CGFloat = targetConstant == 0 ? 0 : 0.4
        menuTrailingConstraint.constant = targetConstant
        if shouldAnimate {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                self.dimMask.alpha = targetShadowMaskAlpha
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isTranslucent = false
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        return cell
    }
}
