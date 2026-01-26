//
//  AuthenticationService.swift
//  HopUpAI
//
//  Created by Cody De Arkland on 1/14/26.
//

import AuthenticationServices
import CryptoKit

enum AuthError: Error, LocalizedError {
    case invalidCredentials
    case unsupportedCredential
    case authenticationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid authentication credentials"
        case .unsupportedCredential:
            return "Unsupported authentication method"
        case .authenticationFailed(let message):
            return "Authentication failed: \(message)"
        }
    }
}

@MainActor
final class AuthenticationService: NSObject, ASAuthorizationControllerDelegate {
    
    static let shared = AuthenticationService()
    private var authCompletion: ((Result<AuthResult, Error>) -> Void)?
    
    struct AuthResult {
        let userIdentifier: String
        let identityToken: String
        let authorizationCode: String
        let email: String?
        let fullName: PersonNameComponents?
    }
    
    private override init() {
        super.init()
        ASAuthorizationAppleIDProvider().getCredentialState(
            forUserID: UserDefaults.standard.string(forKey: "appleUserID") ?? ""
        ) { credentialState, error in
            if let error = error {
                print("Error getting credential state: \(error)")
            }
        }
    }
    
    func signInWithApple() async throws -> AuthResult {
        return try await withCheckedThrowingContinuation { continuation in
            self.authCompletion = { result in
                continuation.resume(returning: result)
            }
            
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }
    }
    
    func isUserAuthenticated() -> Bool {
        guard let token = getToken() else { return false }
        return !token.isEmpty
    }
    
    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: "authToken")
    }
    
    func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "authToken")
    }
    
    func clearToken() {
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "appleUserID")
    }
    
    func getCurrentUserID() -> UUID? {
        guard let uuidString = UserDefaults.standard.string(forKey: "currentUserID"),
              let uuid = UUID(uuidString: uuidString) else {
            return nil
        }
        return uuid
    }
    
    func saveCurrentUserID(_ userID: String) {
        UserDefaults.standard.set(userID, forKey: "currentUserID")
    }
}

extension AuthenticationService: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return UIWindow()
        }
        return window
    }
    
    func authorizationController(
        _ controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        guard let authError = error as? ASAuthorizationError else {
            authCompletion?(.failure(AuthError.authenticationFailed(error.localizedDescription)))
            return
        }
        
        switch authError.code {
        case .canceled:
            authCompletion?(.failure(AuthError.authenticationFailed("User canceled sign in")))
        case .failed:
            authCompletion?(.failure(authError))
        case .invalidResponse:
            authCompletion?(.failure(AuthError.invalidCredentials))
        case .notHandled:
            authCompletion?(.failure(AuthError.unsupportedCredential))
        case .unknown:
            authCompletion?(.failure(authError))
        @unknown default:
            authCompletion?(.failure(authError))
        }
    }
    
    func authorizationController(
        _ controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            authenticationCompleted(with: appleIDCredential)
            
        @unknown default:
            authCompletion?(.failure(AuthError.unsupportedCredential))
        }
    }
    
    private func authenticationCompleted(with credential: ASAuthorizationAppleIDCredential) {
        guard 
            let identityToken = credential.identityToken,
            let authorizationCode = credential.authorizationCode,
            let identityTokenString = String(data: identityToken, encoding: .utf8),
            let authorizationCodeString = String(data: authorizationCode, encoding: .utf8)
        else {
            authCompletion?(.failure(AuthError.invalidCredentials))
            return
        }
        
        let userIdentifier = credential.user
        UserDefaults.standard.set(userIdentifier, forKey: "appleUserID")
        
        let result = AuthResult(
            userIdentifier: userIdentifier,
            identityToken: identityTokenString,
            authorizationCode: authorizationCodeString,
            email: credential.email,
            fullName: credential.fullName
        )
        
        authCompletion?(.success(result))
    }
}