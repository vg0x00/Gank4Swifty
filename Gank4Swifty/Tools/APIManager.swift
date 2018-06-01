//
//  APIManager.swift
//  Gank4Swifty
//
//  Created by vg0x00 on 5/4/18.
//  Copyright © 2018 vg0x00. All rights reserved.
//

import UIKit

class APIManager: NSObject {
    static let shared: APIManager = APIManager()

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
        config.timeoutIntervalForRequest = 20
        config.timeoutIntervalForResource = 60
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

    func postGankAriticle(url: String, desc: String, who: String, type: String, debug: Bool = false, failureHandler: @escaping (Error) -> Void, successHandler: @escaping (Data)->Void) {
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

    func fetchHtmlString(url: String, failureHandler: @escaping (Error) -> Void, successHandler: @escaping (String) -> Void) {
        guard let url = URL(string: "https://mercury.postlight.com/parser?url=\(url)") else {
            let error = NSError(domain: "com.vg0x00.gank4swifty.network.error", code: 5, userInfo: [NSLocalizedDescriptionKey: "read mode construct url failed"])
            return failureHandler(error)
        }
        var request = URLRequest(url: url)
        request.addValue("xu0FqTkfoZdPeaeaKcGzu0YmftKHWTbFcOpBT0lQ", forHTTPHeaderField: "x-api-key")
        request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3359.181 Safari/537.36", forHTTPHeaderField: "User-Agent")
        session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                return failureHandler(error)
            }

            if !self.checkResponseStatus(response) {
                let error = NSError(domain: "com.vg0x00.gank4swifty.network.error", code: 6, userInfo: [NSLocalizedDescriptionKey: "read mode response status error"])
                return failureHandler(error)
            }

            let jsonDecoder = JSONDecoder()
            guard let renderedItem = try? jsonDecoder.decode(ReadModeItem.self, from: data!) else {
                let error = NSError(domain: "com.vg0x00.gank4swifty.network.error", code: 7, userInfo: [NSLocalizedDescriptionKey: "read mode json decoder error"])
                return failureHandler(error)
            }

            successHandler(renderedItem.content ?? "")
        }.resume()
    }

    typealias FailureHandler = (Error) -> Void
    typealias SuccessHandler = (String) -> Void
    func fetchGithubRawReadme(user: String, repo: String, branch: String = "master", path: String = "README.md", failureHandler: @escaping FailureHandler, successHandler: @escaping SuccessHandler) {
        guard let url = URL(string: "https://raw.githubusercontent.com/\(user)/\(repo)/\(branch)/\(path)") else {
            let error = NSError(domain: "com.vg0x00.gank4swifty.network.error", code: 7, userInfo: [NSLocalizedDescriptionKey: "build github raw readme url failed"])
            return failureHandler(error)
        }

        session.dataTask(with: URLRequest(url: url)) { (data, response, error) in
            if let error = error {
                return failureHandler(error)
            }

            if !self.checkResponseStatus(response) {
                let error = NSError(domain: "com.vg0x00.gank4swifty.network.error", code: 6, userInfo: [NSLocalizedDescriptionKey: "read mode response status error"])
                return failureHandler(error)
            }

            guard let content = String(data: data!, encoding: .utf8) else {
                let error = NSError(domain: "com.vg0x00.gank4swifty.network.error", code: 8, userInfo: [NSLocalizedDescriptionKey: "can not convert github readme data into string"])
                return failureHandler(error)
            }

            return successHandler(content)
        }.resume()
    }

    let localDeviceTokenKey = "localDeviceTokenKey"

    func postDeivceTokenIfNeeded(token: String, failureHandler: FailureHandler?, successHandler: SuccessHandler?) {
        var previousDeviceToken = ""
        if let previousToken = UserDefaults.standard.object(forKey: localDeviceTokenKey) as? String {
            previousDeviceToken = previousToken
        }

        if previousDeviceToken != token {
            UserDefaults.standard.set(token, forKey: localDeviceTokenKey)
        }
        postTokenToProvider(previousToken: previousDeviceToken, token: token, failureHandler: failureHandler, successHandler: successHandler)
    }

    private func postTokenToProvider(previousToken: String, token: String, failureHandler: FailureHandler?, successHandler: SuccessHandler?) {
        let providerUrl = URL(string: "https://gank4swifty.tk/deviceToken")!
        var request = URLRequest(url: providerUrl)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        let payload = DeviceTokenPost(previousToken: previousToken, token: token)
        let jsonEncoder = JSONEncoder()
        guard let json = try? jsonEncoder.encode(payload) else { return }
        request.httpBody = json
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                failureHandler?(error)
                return
            }

            let jsonDecoder = JSONDecoder()
            guard let jsonResponse = try? jsonDecoder.decode(DeviceTOkenResponse.self, from: data!) else {
                let jsonDecoderError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "json decode with token response failed"])
                failureHandler?(jsonDecoderError)
                return 
            }

            successHandler?("post device token to provider: \(jsonResponse.message)")
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

struct ReadModeItem: Decodable {
    var title: String
    var content: String?
    var leadImageUrl: String?
}

struct DeviceTokenPost: Encodable {
    var previousToken: String
    var token: String
}

struct DeviceTOkenResponse: Decodable {
    var success: Bool
    var message: String
}
