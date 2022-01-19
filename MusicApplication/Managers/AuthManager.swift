//
//  AuthManager.swift
//  MusicApplication
//
//  Created by administrator on 18/01/2022.
//

import Foundation

final class AuthManager {
    static let shared = AuthManager()
    
    struct Constants {
        static let clientID = "94c8741eddbc458c8b34f9a502f99909"
        static let clientSecret = "417db148af22446a97fdc84046c979ac"
        static let tokenAPIURL = "https://accounts.spotify.com/api/token"
        static let redirectURI = "https://www.google.com.sa"
        static let scope = "user-read-private%20user-read-email%20user-follow-read%20user-library-modify%20user-library-read%20playlist-modify-private%20playlist-read-private%20playlist-modify-public"
    }
    
    private init() {}
    
    public var signInURL: URL? {
        let string = "https://accounts.spotify.com/authorize?response_type=code&client_id=\(Constants.clientID)&scope=\(Constants.scope)&redirect_uri=\(Constants.redirectURI)&show_dialog=TRUE"
        return URL(string: string)
    }
    
    var isSignedIn: Bool {
        return accessToken != nil
    }
    
    private var accessToken: String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }
    
    private var refreshToken: String? {
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    
    private var tokenExoirationDate: Date? {
        return UserDefaults.standard.object(forKey: "expirationDate") as? Date
    }
    
    private var shouldRefreshToken: Bool {
        if let expirationDate = tokenExoirationDate {
            let currentDate = Date()
            let fiveMinutes: TimeInterval = 300
            return currentDate.addingTimeInterval(fiveMinutes) >= expirationDate
        }
        return false
    }
    
    public func exchangeCodeForToken(code: String, completion: @escaping ((Bool) -> Void)) {
        //get Token
        if let url = URL(string: Constants.tokenAPIURL) {
            var components = URLComponents()
            components.queryItems = [
                URLQueryItem(name: "grant_type", value: "authorization_code"),
                URLQueryItem(name: "code", value: code),
                URLQueryItem(name: "redirect_uri", value: Constants.redirectURI)
            ]
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpBody = components.query?.data(using: .utf8)
            let basicToken = "\(Constants.clientID):\(Constants.clientSecret)"
            let data = basicToken.data(using: .utf8)
            let base64String = data?.base64EncodedString() ?? ""
            request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
                guard let data = data, error == nil else {
                    completion(false)
                    return
                }
                do {
                    let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                    self?.cacheToken(result: result)
                    completion(true)
                }catch {
                    print(error)
                    completion(false)
                }
            }
            task.resume()
        }
    }
    
    public func refreshIfNeeded(completion: @escaping (Bool) -> Void) {
//        guard shouldRefreshToken else {
//            completion(true)
//            return
//        }
        guard let refreshToken = refreshToken else {
            return
        }
        //refresh the token
        if let url = URL(string: Constants.tokenAPIURL) {
            var components = URLComponents()
            components.queryItems = [
                URLQueryItem(name: "grant_type", value: "refresh_token"),
                URLQueryItem(name: "refresh_token", value: refreshToken)
            ]
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpBody = components.query?.data(using: .utf8)
            let basicToken = "\(Constants.clientID):\(Constants.clientSecret)"
            let data = basicToken.data(using: .utf8)
            let base64String = data?.base64EncodedString() ?? ""
            request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
                guard let data = data, error == nil else {
                    completion(false)
                    return
                }
                do {
                    let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                    self?.cacheToken(result: result)
                    completion(true)
                }catch {
                    print(error)
                    completion(false)
                }
            }
            task.resume()
        }
    }
    
    private func cacheToken(result: AuthResponse) {
        UserDefaults.standard.setValue(result.access_token, forKey: "access_token")
        if let refresh_token = result.refresh_token {
            UserDefaults.standard.setValue(refresh_token, forKey: "refresh_token")
        }
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expires_in)), forKey: "expirationDate")
    }
}
