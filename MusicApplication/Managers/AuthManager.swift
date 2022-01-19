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
    }
    
    private init() {}
    
    public var signInURL: URL? {
        let string = "https://accounts.spotify.com/authorize?response_type=code&client_id=\(Constants.clientID)&scope=user-read-private&redirect_uri=https://www.google.com.sa&show_dialog=TRUE"
        return URL(string: string)
    }
    
    var isSignedIn: Bool {
        return false
    }
    
    private var accessToken: String? {
        return nil
    }
    
    private var refreshToken: String? {
        return nil
    }
    
    private var tokenExoirationDate: Date? {
        return nil
    }
    
    private var shouldRefreshToken: Bool {
        return false
    }
    
    public func exchangeCodeForToken(code: String, completion: @escaping ((Bool) -> Void)) {
        //get Token
        
    }
    
    public func refreshAccessToken() {
        
    }
    
    private func cacheToken() {
        
    }
}
