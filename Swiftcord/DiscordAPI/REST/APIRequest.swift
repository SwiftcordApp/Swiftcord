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
        DiscordAPI.log.debug("\(method.rawValue): \(path)")
        
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
        let (data, response) = try await DiscordAPI.session.data(for: req)
        guard let httpResponse = response as? HTTPURLResponse else { return nil }
        guard httpResponse.statusCode / 100 == 2 else { // Check if status code is 2**
            log.warning("Status code is not 2xx: \(httpResponse.statusCode, privacy: .public)")
            log.warning("Response: \(String(decoding: data, as: UTF8.self), privacy: .public)")
            return nil
        }
        
        return data
    }
    
    // Make a get request, and decode body with JSONDecoder
    static func getReq<T: Decodable>(
        path: String,
        query: [URLQueryItem] = []
    ) async -> T? {
        // This helps debug JSON decoding errors
        do {
            guard let d = try? await makeRequest(path: path, query: query)
            else { return nil }
            
            return try JSONDecoder().decode(T.self, from: d)
        } catch let DecodingError.dataCorrupted(context) {
            print(context)
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("error: ", error)
        }
        return nil
    }
    
    static func postReq<D: Decodable, B: Encodable>(
        path: String,
        body: B? = nil
    ) async -> D? {        
        let p = body != nil ? try? JSONEncoder().encode(body) : nil
        guard let d = try? await makeRequest(
            path: path,
            body: p != nil ? String(decoding: p!, as: UTF8.self) : nil,
            method: .post
        )
        else { return nil }
        
        return try? JSONDecoder().decode(D.self, from: d)
    }
    
    // For those weird endpoints that expect an empty post request and returns nothing
    static func emptyPostReq(path: String) async -> Bool {
        guard (try? await makeRequest(
            path: path,
            body: nil,
            method: .post
        )) != nil
        else { return false }
        return true
    }
    
    static func deleteReq(path: String) async -> Bool {
        return (try? await makeRequest(path: path, method: .delete)) != nil
    }
}
