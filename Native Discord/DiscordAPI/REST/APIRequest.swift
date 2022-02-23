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
    func makeRequest(
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
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else { return nil }
        
        return data
    }
    
    // Make a get request, and decode body with JSONDecoder
    func getReq<T: Codable>(
        path: String,
        query: [URLQueryItem] = []
    ) async -> T? {
        guard let d = try? await makeRequest(path: path, query: query)
        else { return nil }
        
        return try? JSONDecoder().decode(T.self, from: d)
    }
    
    func postReq<T: Codable>(
        path: String,
        body: T
    ) async -> T? {
        
        guard let d = try? await makeRequest(path: path, method: .post)
        else { return nil }
        
        return try? JSONDecoder().decode(T.self, from: d)
    }
}
