//
//  LocalDataPersistenceManager.swift
//  Gank4Swifty
//
//  Created by vg0x00 on 5/22/18.
//  Copyright © 2018 vg0x00. All rights reserved.
//

import Foundation

protocol LocalDataPersistenceDelgate {
    func loadDataPersistenceDidChange(object: Any)
}

enum LocalDataPersistenceKey: String {
    case iOS = "iOS"
    case web = "前端"
    case expandResource = "拓展资源"
    case android = "Android"
    case video = "休息视频"
    case meizi = "福利"
    case app = "App"
    case mess = "瞎推荐"
    case all // default
}


class LocalDataPersistenceManager {
    static let shared = LocalDataPersistenceManager()

    var delegate: LocalDataPersistenceDelgate?

    let localDataPersistenceKey = "com.vg0x00.gank4swifty.localDataPersistenceKey"

    typealias completionHandler = () -> Void

    static func getCategoryKeyByModelType(model: DataModelItem) -> LocalDataPersistenceKey {
        var categoryKey: LocalDataPersistenceKey
        switch model.type {
        case "iOS":
            categoryKey = .iOS
        case "Android":
            categoryKey = .android
        case "拓展资源":
            categoryKey = .expandResource
        case "福利":
            categoryKey = .meizi
        case "瞎推荐":
            categoryKey = .mess
        case "休息视频":
            categoryKey = .video
        case "前端":
            categoryKey = .web
        case "App":
            categoryKey = .app
        default:
            categoryKey = .all
        }

        return categoryKey
    }

    func add(model: DataModelItem, completion: completionHandler) {
        let categoryKey = LocalDataPersistenceManager.getCategoryKeyByModelType(model: model)
        var allModelDict = getAllModelDict()
        guard let modelKey = model.url?.absoluteString else { return }
        if allModelDict[categoryKey.rawValue] == nil {
            allModelDict[categoryKey.rawValue] = [:]
        }
        allModelDict[categoryKey.rawValue]![modelKey] = model as DataModelItem
        let jsonEncoder = JSONEncoder()
        if let serializedModelDict = try? jsonEncoder.encode(allModelDict) {
            UserDefaults.standard.set(serializedModelDict, forKey: localDataPersistenceKey)
            completion()
        }
    }

    func remove(model: DataModelItem, completion: completionHandler) {
        let categoryKey = LocalDataPersistenceManager.getCategoryKeyByModelType(model: model)
        var allModelDict = getAllModelDict()
        guard let modelKey = model.url?.absoluteString,
            var _ = allModelDict[categoryKey.rawValue] else { return }
        allModelDict[categoryKey.rawValue]![modelKey] = nil
        if allModelDict[categoryKey.rawValue]!.isEmpty {
            allModelDict[categoryKey.rawValue] = nil
        }

        let jsonEncoder = JSONEncoder()
        if let serializedModelDict = try? jsonEncoder.encode(allModelDict) {
            UserDefaults.standard.set(serializedModelDict, forKey: localDataPersistenceKey)
            completion()
        }

    }

    func getAllModelDict() -> [String: [String: DataModelItem]]{
        let jsonDecoder = JSONDecoder()
        guard let dataModelDictData = UserDefaults.standard.object(forKey: localDataPersistenceKey) as? Data else
        {
            print("model item dict not found in user defaults")
            return [:]
        }
        let dataModelDict = try? jsonDecoder.decode([String: [String: DataModelItem]].self, from: dataModelDictData)
        return dataModelDict ?? [:]
    }
}
