//
//  UserViewController.swift
//  Gank4Swifty
//
//  Created by vg0x00 on 5/22/18.
//  Copyright © 2018 vg0x00. All rights reserved.
//

import UIKit
import SafariServices

class UserCollectionViewController: UIViewController {
    let cellId = "userCollectionTableViewCellId"
    let userCollectionHeaderId = "userCollectionHeader"
    let userCollectionToDetailSegue = "userCollectionToDetailSegue"

    @IBOutlet weak var userCollectionTableView: UITableView! {
        didSet {
            userCollectionTableView.register(UINib(nibName: "HomeTabelViewCell", bundle: nil), forCellReuseIdentifier: cellId)
            // NOTE: set header estimatedRowHeight in storyBoard do not work...
            userCollectionTableView.estimatedRowHeight = 100
            userCollectionTableView.estimatedSectionHeaderHeight = 100
        }
    }
    var userCollectionDict = [String: [String: DataModelItem]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserCollectionData()
    }

    private func loadUserCollectionData() {
        userCollectionDict = LocalDataPersistenceManager.shared.getAllModelDict()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("debug view will appear")
        loadUserCollectionData()
        userCollectionTableView.reloadData()
    }

    func getModelItem(by indexPath: IndexPath) -> ModelPresentable? {
        let categoryKeys = userCollectionDict.keys.map{ $0 }
        let key = categoryKeys[indexPath.section]
        guard let userCollection = userCollectionDict[key] else { return nil }
        let modelKeys = userCollection.keys.map{ $0 }
        let modelKey = modelKeys[indexPath.row]
        return userCollection[modelKey]
    }

}

extension UserCollectionViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        let validatedKeys = userCollectionDict.keys.filter { (key) -> Bool in
            if let modelCollection = userCollectionDict[key], !modelCollection.isEmpty {
                return true
            }
            return false
        }

        print("debug: validate count: \(validatedKeys.count)")
        return validatedKeys.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dictKeys = userCollectionDict.keys.map{ $0 }
        let key = dictKeys[section]
        guard let userCollection = userCollectionDict[key] else { return 0 }
        return userCollection.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! HomeTabelViewCell
        guard let modelIten = getModelItem(by: indexPath) else { return cell }
        cell.config(withModelPresentable: modelIten)
        return cell
    }

    // NOTE: table view cell editing
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "确定删除?"
    }
}

extension UserCollectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: userCollectionHeaderId) as! UserCollectionHeader
        let dictKeys = userCollectionDict.keys.map{ $0 }
        let key = dictKeys[section]
        header.titleLabel.text = key
        // NOTE: using normal cell as header will cause section
        //       header moving with cell when cell delete, return
        //       header's content view as header view
        // ref:  https://stackoverflow.com/questions/26009722/swipe-to-delete-cell-causes-tableviewheader-to-move-with-cell
        return header.contentView
    }

    // NOTE: table view editing
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard let modelItem = getModelItem(by: indexPath) else { return }
        LocalDataPersistenceManager.shared.remove(model: modelItem as! DataModelItem) {
            DispatchQueue.main.async {[unowned self] in
                print("debug: current user collection data: \(self.userCollectionDict)")
                // NOTE: update your model, make sure it async with both
                //       section and indexPath count with the final state
                self.loadUserCollectionData()
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .fade)
                let categoryKey = LocalDataPersistenceManager.getCategoryKeyByModelType(model: modelItem as! DataModelItem)
                if self.userCollectionDict[categoryKey.rawValue] == nil {
                    tableView.deleteSections(IndexSet(integer: indexPath.section), with: .left)
                }
                tableView.endUpdates()
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let targetModelItem = getModelItem(by: indexPath),
        let url = targetModelItem.url else { return }

        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
    }
}
