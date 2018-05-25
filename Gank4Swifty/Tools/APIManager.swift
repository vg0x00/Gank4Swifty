//
//  APIManager.swift
//  Gank4Swifty
//
//  Created by vg0x00 on 5/4/18.
//  Copyright © 2018 vg0x00. All rights reserved.
//

import UIKit

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

    @IBOutlet weak var calendarButton: UIBarButtonItem!
    
    lazy var sessionConfig: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
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
            DispatchQueue.main.async {
                if error != nil || !self.checkResponseStatus(response) {
                    self.delegate?.apiManagerOnFailure(withError: "网络出现问题,请稍后再试")
                } else {
                    self.delegate?.apiManagerOnSuccess(withData: data!)
                }
            }
        }
        task.resume()
        return task
    }

    func dataTask(withURL url: URL, onFailure errorHandler: @escaping (String) -> Void, onSuccess successHandler: @escaping (Data)->Void) -> URLSessionTask {
        let task = session.dataTask(with: url) { (data, response, error) in
            if error != nil || !self.checkResponseStatus(response) { errorHandler("网络出现错误"); return }
            else if let data = data, data.count < 0 {
                errorHandler("没有更多数据"); return
            } else {
                successHandler(data!)
            }
        }
        task.resume()
        return task
    }

    enum GankArticleType: String {
        case iOS = "iOS"
        case video = "休息视频"
        case meizi = "福利"
        case expandResources = "拓展资源"
        case web = "前端"
        case mess = "瞎推荐"
        case app = "App"
    }

    func postGankAriticle(url: String, desc: String, who: String, type: String, debug: Bool = true, failureHandler: @escaping (Error) -> Void, successHandler: @escaping (Data)->Void) {
        guard let targetUrl = URL(string: "https://gank.io/api/add2gank") else {
            let error = NSError(domain: "gank.network.error", code: 1, userInfo: [NSLocalizedDescriptionKey: "create gank post url failed"])
            return failureHandler(error)
        }

        var request = URLRequest(url: targetUrl)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        // NOTE: should do url encoded job here? api test passed
        let formData = "url=\(url)&desc=\(desc)&who=\(who)&type=\(type)&debug=\(debug)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)?.data(using: .utf8)

        session.uploadTask(with: request, from: formData) { (data, response, error) in
            if let error = error {
                print("debug: post failed: \(error)")
                failureHandler(error)
            }

            guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else {
                    let error = NSError(domain: "gank.network.error", code: 2, userInfo: [NSLocalizedDescriptionKey: "post response error"])
                    return failureHandler(error)
            }

            guard let mimeType = response.mimeType,
                mimeType == "application/json",
                let data = data  else {
                    let error = NSError(domain: "gank.network.error", code: 3, userInfo: [NSLocalizedDescriptionKey: "response is not a valid json response"])
                    return failureHandler(error)
            }

            successHandler(data)
        }.resume()
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

struct PostResponse: Decodable {
    var error: Bool
    var msg: String
}
