//
//  APIRequest.swift
//  Native Discord
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

extension DiscordAPI {
    /// Utility wrappers for easy request making
    enum RequestMethod: String {
        case get = "GET"
        case post = "POST"
        case delete = "DELETE"
        case patch = "PATCH"
    }
    
    // Low level Discord API request, meant to be as generic as possible
    static func makeRequest(
        path: String,
        query: [URLQueryItem] = [],
        body: String? = nil,
        method: RequestMethod = .get
    ) async throws -> Data? {
        guard let token = Keychain.load(key: "token") else { return nil }
        guard var apiURL = URL(string: apiConfig.restBase) else { return nil }
        apiURL.appendPathComponent(path, isDirectory: false)
        
        // Add query params (if any)
        var urlBuilder = URLComponents(url: apiURL, resolvingAgainstBaseURL: true)
        urlBuilder?.queryItems = query
        guard let reqURL = urlBuilder?.url else { return nil }
        
        // Create URLRequest and set headers
        var req = URLRequest(url: reqURL)
        req.httpMethod = method.rawValue
        req.setValue(token, forHTTPHeaderField: "authorization")
        req.setValue(apiConfig.baseURL, forHTTPHeaderField: "origin")
        if let body = body {
            req.setValue("application/json", forHTTPHeaderField: "content-type")
            req.httpBody = body.data(using: .utf8)
        }
        
        // Make request
        let (data, response) = try await URLSession.shared.data(for: req)
        guard let httpResponse = response as? HTTPURLResponse else { return nil }
        guard httpResponse.statusCode == 200 else {
            print("Status code is not 200: \(httpResponse.statusCode)")
            return nil
        }
        
        return data
    }
    
    // Make a get request, and decode body with JSONDecoder
    static func getReq<T: Codable>(
        path: String,
        query: [URLQueryItem] = []
    ) async -> T? {
        print("GET: \(path)")
        guard let d = try? await makeRequest(path: path, query: query)
        else { return nil }
        // print(String(decoding: d, as: UTF8.self))
        
        return try? JSONDecoder().decode(T.self, from: d)
    }
    
    static func postReq<D: Codable, B: Codable>(
        path: String,
        body: B? = nil
    ) async -> D? {
        print("POST: \(path)")
        
        let p = body != nil ? try? JSONEncoder().encode(body) : nil
        guard let d = try? await makeRequest(
            path: path,
            body: p != nil ? String(decoding: p!, as: UTF8.self) : nil,
            method: .post
        )
        else { return nil }
        
        return try? JSONDecoder().decode(D.self, from: d)
    }
}
