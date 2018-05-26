//
//  UserTableViewController.swift
//  Gank4Swifty
//
//  Created by vg0x00 on 5/24/18.
//  Copyright © 2018 vg0x00. All rights reserved.
//

import UIKit
import MessageUI
import SafariServices

class UserTableViewController: UITableViewController {

    let postArticleSegue = "postArticleSegue"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == postArticleSegue {
            if let postViewController = segue.destination as? PostViewController {
                postViewController.sourceViewController = self
            }
        }
    }

    // MARK - UITableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                let githubPage = SFSafariViewController(url: URL(string: "https://github.com/vg0x00/Gank4Swifty/issues")!)
                present(githubPage, animated: true, completion: nil)
            case 1:
                let githubPage = SFSafariViewController(url: URL(string: "https://github.com/vg0x00/Gank4Swifty")!)
                present(githubPage, animated: true, completion: nil)
            default:
                composeShowMailViewController {
                    tableView.deselectRow(at: indexPath, animated: false)
                }
            }
        }
    }

    private func composeShowMailViewController(completion: @escaping () -> Void) {
        guard let url = URL(string: "mailto:591064967@qq.com?subject=Gank4Swifty%20Contact%20Me") else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:]) { (completed) in
                completion()
            }
        } 
    }
}
