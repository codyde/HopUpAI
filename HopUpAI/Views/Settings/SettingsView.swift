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
    @Binding var isAuthenticated: Bool
    
    @State private var isSyncing = false
    @State private var lastSyncDate: Date?
    @State private var showingSignOutAlert = false
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    private var displayName: String {
        UserDefaults.standard.string(forKey: "userDisplayName") ?? profile?.displayName ?? "Player"
    }
    
    private var userInitial: String {
        String(displayName.prefix(1)).uppercased()
    }
    
    private var profileImageUrl: String? {
        UserDefaults.standard.string(forKey: "userProfileImageUrl")
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile header
                    profileHeader
                    
                    // Cloud sync section
                    cloudSyncSection
                    
                    // About section
                    aboutSection
                    
                    // Sign out button
                    signOutSection
                }
                .padding()
                .padding(.bottom, 100)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    signOut()
                }
            } message: {
                Text("Are you sure you want to sign out? Your local data will be preserved.")
            }
        }
    }
    
    // MARK: - Profile Initial View
    
    private var profileInitialView: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [AppColors.basketball, AppColors.basketballDark],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)
                .shadow(color: AppColors.basketball.opacity(0.4), radius: 15, y: 5)
            
            Text(userInitial)
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
    }
    
    // MARK: - Profile Header
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Large avatar
            ZStack {
                if let imageUrlString = profileImageUrl,
                   let imageUrl = URL(string: imageUrlString) {
                    AsyncImage(url: imageUrl) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(AppColors.basketball, lineWidth: 3)
                                )
                        case .failure(_):
                            profileInitialView
                        case .empty:
                            ProgressView()
                                .frame(width: 100, height: 100)
                        @unknown default:
                            profileInitialView
                        }
                    }
                    .shadow(color: AppColors.basketball.opacity(0.4), radius: 15, y: 5)
                } else {
                    profileInitialView
                }
            }
            
            // Name and level
            VStack(spacing: 6) {
                Text(displayName)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                
                if let profile = profile {
                    HStack(spacing: 6) {
                        Image(systemName: profile.levelTitle.icon)
                            .font(.system(size: 14))
                        Text("Level \(profile.level) \(profile.levelTitle.rawValue)")
                            .font(.system(size: 15, weight: .medium))
                    }
                    .foregroundStyle(profile.levelTitle.color)
                }
            }
            
            // Sync status badge
            HStack(spacing: 6) {
                Image(systemName: "checkmark.icloud.fill")
                    .font(.system(size: 12))
                Text("Synced")
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundStyle(AppColors.success)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(AppColors.success.opacity(0.15))
            .clipShape(Capsule())
        }
        .padding(.vertical, 24)
    }
    
    // MARK: - Cloud Sync Section
    
    private var cloudSyncSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Cloud Sync")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
            
            VStack(spacing: 0) {
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
                        } else {
                            Text("Synced to cloud")
                                .font(.system(size: 12))
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                    
                    Spacer()
                }
                .padding(16)
                
                Rectangle()
                    .fill(AppColors.courtLines)
                    .frame(height: 1)
                
                // Sync now button
                Button {
                    syncNow()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 16))
                            .opacity(isSyncing ? 0 : 1)
                            .overlay {
                                if isSyncing {
                                    ProgressView()
                                        .tint(AppColors.basketball)
                                        .scaleEffect(0.8)
                                }
                            }
                        
                        Text(isSyncing ? "Syncing..." : "Sync Now")
                            .font(.system(size: 15, weight: .medium))
                    }
                    .foregroundStyle(AppColors.basketball)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                }
                .disabled(isSyncing)
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
                    .background(AppColors.courtLines)
                
                SettingsRow(icon: "hammer", title: "Build", value: "1")
            }
            .background(AppColors.court)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    // MARK: - Sign Out Section
    
    private var signOutSection: some View {
        Button {
            showingSignOutAlert = true
        } label: {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 16))
                
                Text("Sign Out")
                    .font(.system(size: 15, weight: .medium))
            }
            .foregroundStyle(AppColors.error)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppColors.error.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    // MARK: - Actions
    
    private func syncNow() {
        isSyncing = true
        Task {
            // Simulate sync delay
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await MainActor.run {
                lastSyncDate = Date()
                isSyncing = false
            }
        }
    }
    
    private func signOut() {
        AuthenticationService.shared.clearToken()
        UserDefaults.standard.removeObject(forKey: "userDisplayName")
        UserDefaults.standard.removeObject(forKey: "userProfileImageUrl")
        UserDefaults.standard.removeObject(forKey: "isProfileComplete")
        isAuthenticated = false
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
    SettingsView(isAuthenticated: .constant(true))
        .modelContainer(for: [UserProfile.self], inMemory: true)
}
