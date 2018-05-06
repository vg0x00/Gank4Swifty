//
//  APIManager.swift
//  Gank4Swifty
//
//  Created by vg0x00 on 5/4/18.
//  Copyright © 2018 vg0x00. All rights reserved.
//

import Foundation

class APIManager: NSObject {
  lazy var urlCache: URLCache? = {
    guard var cacheDir = try? FileManager.default.url(for: .applicationSupportDirectory,
                                                      in: .userDomainMask,
                                                      appropriateFor: nil,
                                                      create: false) else { return nil }
    cacheDir.appendPathComponent("APIManagerURLSessionCache")
    let cache = URLCache(memoryCapacity: 400, diskCapacity: 400, diskPath: cacheDir.absoluteString)
    return cache
  }()

  lazy var sessionConfig: URLSessionConfiguration = {
    let config = URLSessionConfiguration()
    config.timeoutIntervalForRequest = 5
    config.timeoutIntervalForResource = 20
    config.urlCache = urlCache
    return config
  }()

  lazy var session: URLSession = {
    let session = URLSession(configuration: sessionConfig)
    return session
  }()

  var delegate: APIManagerDelegate?

  // NOTE: caller should ensure synchronized data task - BAD
  func dataTask(withRequest request: URLRequest) -> URLSessionTask {
    let task = session.dataTask(with: request) { (data, response, error) in
      if error != nil || !self.checkResponseStatus(response) {
        self.delegate?.apiManagerOnFailure(withError: "网络出现问题,请稍后再试")
      } else if let data = data, data.count <= 0 {
        self.delegate?.apiManagerOnFailure(withError: "没有更多数据")
      } else {
        self.delegate?.apiManagerOnSuccess(withData: data!)
      }
    }
    task.resume()
    return task
  }

  private func checkResponseStatus(_ response: URLResponse?) -> Bool {
    guard let response = response, let httpResponse = response as? HTTPURLResponse else { return false }
    return 200..<400 ~= httpResponse.statusCode
  }
}


protocol APIManagerDelegate {
  func apiManagerOnFailure(withError error: String)
  func apiManagerOnSuccess(withData data: Data)
}
