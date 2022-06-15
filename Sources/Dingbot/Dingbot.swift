//
//  Created by iWw on 2022/1/26.
//

import Foundation
import Crypto

/// Encrypt string with key to hmacSHA256 and then to base64EncodedString
/// - Parameters:
///   - string: will be encrypt string
///   - key: KEY for hmacSHA256
/// - Returns: base64EncodedString
fileprivate func hmacSHA256Base64String(string: String, key: String) -> String {
    let secretString = key
    let key = SymmetricKey(data: secretString.data(using: .utf8)!)
    let signature = HMAC<SHA256>.authenticationCode(for: string.data(using: .utf8)!, using: key)
    return Data(signature).base64EncodedString()
}

// https://open.dingtalk.com/document/group/custom-robot-access
public protocol DingbotMessage { func httpBody() -> Data? }

// MARK: - Dingbot
public struct Dingbot {
    private init() { }
    public static var shared = Dingbot()
    
    // MARK: Configure
    public struct Configure {
        let url: String
        let accessToken: String
        
        let signKey: String?
        
        /// global configure
        /// - Parameters:
        ///   - url: default is 'https://oapi.dingtalk.com/robot/send'
        ///   - accessToken: your access token
        public init(url: String = "https://oapi.dingtalk.com/robot/send", accessToken: String, signKey: String? = nil) {
            self.url = url
            self.accessToken = accessToken
            self.signKey = signKey
        }
    }
    public var configure: Configure = .init(accessToken: "")
    
    // MARK: Validation Error
    public enum ValidationError: Error, LocalizedError {
        case invalidAccessToken
        case invalidURL(_ url: String)
        case signFailed
        
        public var errorDescription: String? {
            switch self {
            case .invalidAccessToken:
                return "Invalid access token, use `Dingbot.shared.configure` to set it."
            case .invalidURL(let url):
                return "Invalid url: \(url)"
            case .signFailed:
                return "Sign failed"
            }
        }
    }
    
    /// Validation with request params
    private func validation() throws {
        guard !configure.accessToken.isEmpty else {
            throw ValidationError.invalidAccessToken
        }
    }
    
    /// Make request url with configure
    /// - Parameter config: the Dingbot webhook's configure
    /// - Returns: URL
    private func makeUrl(with config: Configure) throws -> URL {
        let accessToken: String = config.accessToken
        let urlString: String = "\(config.url)?access_token=\(accessToken)"
        guard let signKey = config.signKey,
              !signKey.isEmpty
        else {
            guard let url = URL(string: urlString) else {
                throw ValidationError.invalidURL(urlString)
            }
            return url
        }
        
        let timestamp: Int = Int(Date().timeIntervalSince1970 * 1000)
        let sign: String = hmacSHA256Base64String(string: "\(timestamp)\n\(signKey)", key: signKey)
        
        var urlComponents: URLComponents = URLComponents()
        urlComponents.scheme = URL(string: urlString)?.scheme
        urlComponents.host = URL(string: urlString)?.host
        urlComponents.path = URL(string: urlString)?.path ?? ""
        urlComponents.queryItems = [
            URLQueryItem(name: "access_token", value: accessToken),
            URLQueryItem(name: "timestamp", value: "\(timestamp)"),
            URLQueryItem(name: "sign", value: sign)
        ]
        
        guard let url = urlComponents.url else {
            throw ValidationError.invalidURL(urlString)
        }
        return url
    }

    #if compiler(>=5.5) && canImport(_Concurrency)
    @discardableResult
    /// Send message with configure, use default when not set configure
    /// - Parameters:
    ///   - message: DingbotMessage
    ///   - configure: configure
    /// - Returns: (data: Data, response: HTTPURLResponse)
    public func send(_ message: DingbotMessage, configure: Configure? = nil) async throws -> (data: Data, response: HTTPURLResponse) {
        let url: URL = try makeUrl(with: configure ?? self.configure)
        var urlRequest: URLRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = message.httpBody()
        urlRequest.allHTTPHeaderFields = [
            "Content-Type": "application/json; charset=utf-8"
        ]
        let (data, response) = try await linuxAsyncURLRequest(urlRequest: urlRequest)
        let _response = (response as! HTTPURLResponse)
        return (data, _response)
    }
    
    private func linuxAsyncURLRequest(urlRequest: URLRequest) async throws -> (data: Data, response: URLResponse) {
        try await withCheckedThrowingContinuation({ continuation in
            
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    guard let data = data,
                          let response = response
                    else {
                        continuation.resume(returning: (data: Data(), response: URLResponse()))
                        return
                    }
                    continuation.resume(returning: (data: data, response: response))
                }
            }
        })
    }
    #endif
}


// MARK: - @ at
public extension Dingbot {
    
    struct At: Encodable {
        var atMobiles: [String]?
        var atUserIds: [String]?
        var isAtAll: Bool = false
        
        public init(atMobiles: [String]? = nil, atUserIds: [String]? = nil, isAtAll: Bool = false) {
            self.atMobiles = atMobiles
            self.atUserIds = atUserIds
            self.isAtAll = isAtAll
        }
    }
    
}

// MARK: - TextMessage
public extension Dingbot {
    
    struct TextMessage: Encodable, DingbotMessage {
        struct Text: Encodable {
            let content: String
            init(content: String) {
                self.content = content
            }
        }
        let text: Text
        let at: At?
        let msgtype: String
        
        public init(_ text: String, at: At? = nil) {
            self.text = Text(content: text)
            self.at = at
            self.msgtype = "text"
        }
        
        public func httpBody() -> Data? {
            try? JSONEncoder().encode(self)
        }
    }
    
}

// MARK: - LinkMessage
public extension Dingbot {
    
    struct LinkMessage: Encodable, DingbotMessage {
        struct Link: Encodable {
            let text: String
            let title: String
            let picUrl: String?
            let messageUrl: String
            
            init(title: String, text: String, messageUrl: String, picUrl: String? = nil) {
                self.title = title
                self.text = text
                self.messageUrl = messageUrl
                self.picUrl = picUrl
            }
        }
        
        let link: Link
        let msgtype: String
        
        public init(title: String, text: String, messageUrl: String, picUrl: String? = nil) {
            self.link = Link(title: title, text: text, messageUrl: messageUrl, picUrl: picUrl)
            self.msgtype = "link"
        }
        
        public func httpBody() -> Data? {
            try? JSONEncoder().encode(self)
        }
    }
    
}

// MARK: - MarkdownMessage
public extension Dingbot {
    
    struct MarkdownMessage: Encodable, DingbotMessage {
        struct Markdown: Encodable {
            let title: String
            let text: String
            
            init(title: String, text: String) {
                self.title = title
                self.text = text
            }
        }
        let markdown: Markdown
        let msgtype: String
        let at: At?
        
        public init(title: String, content: String, at: At? = nil) {
            self.markdown = Markdown(title: title, text: content)
            self.at = at
            self.msgtype = "markdown"
        }
        
        public func httpBody() -> Data? {
            try? JSONEncoder().encode(self)
        }
    }
}
