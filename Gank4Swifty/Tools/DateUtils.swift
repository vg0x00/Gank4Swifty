//
//  DateUtil.swift
//  Gankwo2
//
//  Created by vg0x00 on 4/19/18.
//  Copyright © 2018 vg0x00. All rights reserved.
//

import Foundation

class DateUtil {
  static var shared = DateUtil()
  static var formatter = DateFormatter()

  // NOTE: holy rfc3339: http://www.ietf.org/rfc/rfc3339.txt
    static func getDate(withString str: String?, format: String = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'") -> Date? {
    guard let str = str else { return nil }
    formatter.dateFormat = format
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    return formatter.date(from:str)
  }

  static func getStr(fromDate date: Date?, format: String) -> String? {
    guard let date = date else { return nil }
    formatter.dateFormat = format
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    return formatter.string(from: date)
  }

  static func getStr(from date: Date?) -> String? {
    guard let date = date else { return nil }
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    return formatter.string(from: date)
  }

  static func currentDateString(withFormat format: String) -> String {
    formatter.dateFormat = format
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    return formatter.string(from: Date())
  }

  static func transformDateString(withDateString date: String, inFormat: String = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", outFormat: String) -> String {
    formatter.dateFormat = inFormat
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    guard let date = formatter.date(from: date) else { return "日期转换错误" }
    formatter.dateFormat = outFormat
    return formatter.string(from: date)
  }
}
