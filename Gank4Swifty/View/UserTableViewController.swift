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
                composeShowMailViewController(with: "Gank4Swifty - 问题反馈")
            case 1:
                let githubPage = SFSafariViewController(url: URL(string: "https://www.baidu.com")!)
                present(githubPage, animated: true, completion: nil)
            default:
                composeShowMailViewController(with: "Gank4Swifty - 联系我")
            }
        }
    }

    private func composeShowMailViewController(with subject: String) {
        let mailViewController = MFMailComposeViewController()
        mailViewController.mailComposeDelegate = self
        mailViewController.setSubject(subject)
        mailViewController.setToRecipients(["591064967@qq.com"])
        present(mailViewController, animated: true, completion: nil)
    }
}

extension UserTableViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
