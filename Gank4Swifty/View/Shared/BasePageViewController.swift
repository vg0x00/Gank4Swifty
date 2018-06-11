//
//  BasePageViewController.swift
//  Gank4Swifty
//
//  Created by vg0x00 on 6/11/18.
//  Copyright © 2018 vg0x00. All rights reserved.
//

import UIKit
import SafariServices

class BasePageViewController: UIViewController {
    var isDuring3DTouch: Bool = false
    var selectedItem: DataModelItem?
}

extension BasePageViewController: UIPreviewInteractionDelegate {
    func previewInteraction(_ previewInteraction: UIPreviewInteraction, didUpdatePreviewTransition transitionProgress: CGFloat, ended: Bool) {
        isDuring3DTouch = true
        if ended {
            // NOTE: show action sheets
            let action = UIAlertController(title: "喜欢这条干货么?", message: nil, preferredStyle: .actionSheet)

            action.addAction(UIAlertAction(title: "加入收藏", style: .default, handler: { (action) in
                self.addItemToCollection(model: self.selectedItem)
            }))
            action.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))

            self.present(action, animated: true) {
                self.isDuring3DTouch = false
            }
        }
    }

    func previewInteractionDidCancel(_ previewInteraction: UIPreviewInteraction) {
        print("3d touch canceled")
        self.isDuring3DTouch = false
    }

    func addItemToCollection(model: DataModelItem?) {
        guard let model = model else { return }
        LocalDataPersistenceManager.shared.add(model: model, completion: nil)
    }

    func removeItemFromCollection(model: DataModelItem?) {
        guard let model = model else { return }
        LocalDataPersistenceManager.shared.remove(model: model, completion: nil)
    }
}


extension BasePageViewController: SFSafariViewControllerDelegate {
    func safariViewController(_ controller: SFSafariViewController, activityItemsFor URL: URL, title: String?) -> [UIActivity] {
        let activity = GankAction(image: UIImage(named: "userCollection")!)
        activity.userCollectionHandler = {
            guard let modelItem = self.selectedItem else { return }
            LocalDataPersistenceManager.shared.add(model: modelItem, completion: nil)
        }
        return [activity]
    }


    func safariViewController(_ controller: SFSafariViewController, excludedActivityTypesFor URL: URL, title: String?) -> [UIActivityType] {
        return [UIActivityType.airDrop, .assignToContact, .openInIBooks]
    }
}
