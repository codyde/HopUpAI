//
//  SettingsView.swift
//  HopUpAI
//
//  Created by Cody De Arkland on 1/14/26.
//

import SwiftUI
import SwiftData
import AuthenticationServices

/// Settings view with profile info and cloud sync options
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    
    @State private var isSigningIn = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isSyncing = false
    @State private var lastSyncDate: Date?
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    private var isAuthenticated: Bool {
        AuthenticationService.shared.isUserAuthenticated()
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile section
                    profileSection
                    
                    // Cloud sync section
                    cloudSyncSection
                    
                    // About section
                    aboutSection
                }
                .padding()
                .padding(.bottom, 100)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Profile Section
    
    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Profile")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
            
            VStack(spacing: 0) {
                if let profile = profile {
                    HStack(spacing: 16) {
                        // Avatar
                        ZStack {
                            Circle()
                                .fill(AppColors.basketball.opacity(0.2))
                                .frame(width: 56, height: 56)
                            
                            Text(profile.displayName.prefix(1).uppercased())
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundStyle(AppColors.basketball)
                        }
                        
                        // Info
                        VStack(alignment: .leading, spacing: 4) {
                            Text(profile.displayName)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(AppColors.textPrimary)
                            
                            Text("Level \(profile.level) \(profile.levelTitle)")
                                .font(.system(size: 14))
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        
                        Spacer()
                        
                        // Sync status indicator
                        if isAuthenticated {
                            Image(systemName: "checkmark.icloud.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(AppColors.success)
                        }
                    }
                    .padding(16)
                }
            }
            .background(AppColors.court)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    // MARK: - Cloud Sync Section
    
    private var cloudSyncSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Cloud Sync")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
            
            VStack(spacing: 0) {
                if isAuthenticated {
                    // Signed in state
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(AppColors.success)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Signed in with Apple")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(AppColors.textPrimary)
                                
                                if let lastSync = lastSyncDate {
                                    Text("Last synced: \(lastSync.formatted(date: .abbreviated, time: .shortened))")
                                        .font(.system(size: 12))
                                        .foregroundStyle(AppColors.textSecondary)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        Divider()
                            .background(AppColors.courtLine)
                        
                        // Sync now button
                        Button {
                            syncNow()
                        } label: {
                            HStack {
                                if isSyncing {
                                    ProgressView()
                                        .tint(AppColors.basketball)
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                        .font(.system(size: 16))
                                }
                                
                                Text(isSyncing ? "Syncing..." : "Sync Now")
                                    .font(.system(size: 15, weight: .medium))
                            }
                            .foregroundStyle(AppColors.basketball)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        }
                        .disabled(isSyncing)
                        
                        Divider()
                            .background(AppColors.courtLine)
                        
                        // Sign out button
                        Button {
                            signOut()
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 16))
                                
                                Text("Sign Out")
                                    .font(.system(size: 15, weight: .medium))
                            }
                            .foregroundStyle(AppColors.error)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        }
                        .padding(.bottom, 4)
                    }
                } else {
                    // Sign in state
                    VStack(spacing: 16) {
                        VStack(spacing: 8) {
                            Image(systemName: "icloud")
                                .font(.system(size: 40))
                                .foregroundStyle(AppColors.textSecondary)
                            
                            Text("Sync your progress")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(AppColors.textPrimary)
                            
                            Text("Sign in to save your workouts and progress to the cloud. Access them from any device.")
                                .font(.system(size: 14))
                                .foregroundStyle(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top, 20)
                        
                        // Sign in with Apple button
                        SignInWithAppleButton(.signIn) { request in
                            request.requestedScopes = [.fullName, .email]
                        } onCompletion: { result in
                            handleSignInResult(result)
                        }
                        .signInWithAppleButtonStyle(.white)
                        .frame(height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                        .disabled(isSigningIn)
                        .overlay {
                            if isSigningIn {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.black.opacity(0.3))
                                    .frame(height: 50)
                                    .padding(.horizontal, 16)
                                    .overlay {
                                        ProgressView()
                                            .tint(.white)
                                    }
                            }
                        }
                    }
                }
            }
            .background(AppColors.court)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
            
            VStack(spacing: 0) {
                SettingsRow(icon: "info.circle", title: "Version", value: "1.0.0")
                
                Divider()
                    .background(AppColors.courtLine)
                
                SettingsRow(icon: "hammer", title: "Build", value: "1")
            }
            .background(AppColors.court)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    // MARK: - Actions
    
    private func handleSignInResult(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let identityToken = appleIDCredential.identityToken,
                  let identityTokenString = String(data: identityToken, encoding: .utf8) else {
                errorMessage = "Failed to get credentials"
                showingError = true
                return
            }
            
            isSigningIn = true
            
            // Get user info
            let email = appleIDCredential.email
            var displayName: String?
            if let fullName = appleIDCredential.fullName {
                let formatter = PersonNameComponentsFormatter()
                displayName = formatter.string(from: fullName)
            }
            
            // Save Apple User ID
            UserDefaults.standard.set(appleIDCredential.user, forKey: "appleUserID")
            
            // Authenticate with backend
            Task {
                do {
                    let response = try await APIService.shared.signInWithApple(
                        identityToken: identityTokenString,
                        email: email,
                        displayName: displayName
                    )
                    
                    AuthenticationService.shared.saveToken(response.token)
                    AuthenticationService.shared.saveCurrentUserID(response.user.id)
                    
                    // Update local profile if we got a name
                    if let name = displayName, !name.isEmpty, let profile = profile {
                        profile.displayName = name
                    }
                    
                    // Trigger initial sync
                    await syncData()
                    
                    isSigningIn = false
                } catch {
                    isSigningIn = false
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
            
        case .failure(let error):
            // Don't show error for user cancellation
            if let authError = error as? ASAuthorizationError, authError.code == .canceled {
                return
            }
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
    
    private func syncNow() {
        isSyncing = true
        Task {
            await syncData()
            isSyncing = false
        }
    }
    
    private func syncData() async {
        // Note: Full sync implementation would go here
        // For now, we update the last sync date
        await MainActor.run {
            lastSyncDate = Date()
        }
    }
    
    private func signOut() {
        AuthenticationService.shared.clearToken()
        lastSyncDate = nil
    }
}

// MARK: - Settings Row

struct SettingsRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(AppColors.textSecondary)
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 15))
                .foregroundStyle(AppColors.textPrimary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15))
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [UserProfile.self], inMemory: true)
}
