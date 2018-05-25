
//
//  DataModel.swift
//  Gank4Swifty
//
//  Created by vg0x00 on 5/4/18.
//  Copyright © 2018 vg0x00. All rights reserved.
//

import Foundation

struct DataModel: Decodable {
    var id: String?
    var gId: String?
    var desc: String
    var publishedAt: String
    var url: String
    var type: String
    var who: String?
    var images: [String]?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case gId = "ganhuo_id"
        case desc
        case publishedAt
        case url
        case type
        case who
        case images
    }
}

struct CalendarModel: Decodable {
    var results: [String]
}

struct HistoryModelContainer: Decodable {
    var category: [String]
    var results: Dictionary<String, [DataModel]>
}

struct NormalModelContainer: Decodable {
    var results: Array<DataModel>
}
