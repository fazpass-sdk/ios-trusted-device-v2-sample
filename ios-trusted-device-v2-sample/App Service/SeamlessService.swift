//
//  SeamlessService.swift
//  ios-trusted-device-v2-sample
//
//  Created by Andri nova riswanto on 11/11/24.
//

import Foundation

class SeamlessService {
    
    private let baseUrl = "https://api.fazpas.com/v2/trusted-device"
    private let bearerToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZGVudGlmaWVyIjozNn0.mfny8amysdJQYlCrUlYeA-u4EG1Dw9_nwotOl-0XuQ8"
    private let merchantAppId = "afb2c34a-4c4f-4188-9921-5c17d81a3b3d"
    private let picId = "hello@mail.com"
    
    private var challenge = ""
    private var fazpassId = ""
    
    func check(meta: String, onError: @escaping (Error) -> Void, onSuccess: @escaping (String) -> Void) {
        let url = URL(string: "\(baseUrl)/check")!
        let body = """
            {
              "merchant_app_id": "\(merchantAppId)",
              "meta": "\(meta)",
              "pic_id": "\(picId)"
            }
            """.data(using: .utf8)
        apiRequest(url: url, body: body, onError: onError, onSuccess: onSuccess)
    }
    
    func enroll(meta: String, onError: @escaping (Error) -> Void, onSuccess: @escaping (String) -> Void) {
        let url = URL(string: "\(baseUrl)/enroll")!
        let body = """
        {
          "merchant_app_id": "\(merchantAppId)",
          "meta": "\(meta)",
          "pic_id": "\(picId)",
          "challenge": "\(challenge)"
        }
        """.data(using: .utf8)
        apiRequest(url: url, body: body, onError: onError, onSuccess: onSuccess)
    }
    
    func validate(meta: String, onError: @escaping (Error) -> Void, onSuccess: @escaping (String) -> Void) {
        let url = URL(string: "\(baseUrl)/validate")!
        let body = """
        {
          "merchant_app_id": "\(merchantAppId)",
          "meta": "\(meta)",
          "fazpass_id": "\(fazpassId)",
          "challenge": "\(challenge)"
        }
        """.data(using: .utf8)
        apiRequest(url: url, body: body, onError: onError, onSuccess: onSuccess)
    }
    
    func remove(meta: String, onError: @escaping (Error) -> Void, onSuccess: @escaping (String) -> Void) {
        let url = URL(string: "\(baseUrl)/remove")!
        let body = """
        {
          "merchant_app_id": "\(merchantAppId)",
          "meta": "\(meta)",
          "fazpass_id": "\(fazpassId)",
          "challenge": "\(challenge)"
        }
        """.data(using: .utf8)
        apiRequest(url: url, body: body, onError: onError, onSuccess: onSuccess)
    }
    
    private func apiRequest(url: URL, body: Data?, onError: @escaping (Error) -> Void, onSuccess: @escaping (String) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        request.allHTTPHeaderFields = [
            "Authorization": "Bearer \(bearerToken)",
            "Content-Type": "application/json"
        ]
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                onError(error ?? NSError(domain: "Data is nil", code: 10001))
                return
            }
            
            do {
                let prettyJson = try self.readData(data: data)
                guard prettyJson != "" else {
                    onError(NSError(domain: "Unable to read data", code: 10002))
                    return
                }
                
                onSuccess(prettyJson)
            } catch {
                onError(error)
                onSuccess(String(data: data, encoding: .utf8) ?? "")
            }
        }.resume()
    }
    
    private func readData(data: Data) throws -> String {
        let mapper = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String:AnyObject]
        
        let jsonData = mapper["data"]
        let identification = jsonData?["identification"] as? AnyObject
        let identificationData = identification?["data"] as? AnyObject
        
        self.challenge = identificationData?["challenge"] as? String ?? ""
        self.fazpassId = identificationData?["fazpass_id"] as? String ?? ""
        
        let prettyData = try JSONSerialization.data(withJSONObject: mapper, options: [.prettyPrinted, .sortedKeys])
        return String(data: prettyData, encoding: .utf8) ?? ""
    }
}
