//
//  SignInView.swift
//  HopUpAI
//
//  Created by Cody De Arkland on 1/26/26.
//

import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isAuthenticated: Bool
    
    @State private var isSigningIn = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var animateBasketball = false
    @State private var animateGlow = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(hex: "0A0A0A"),
                    Color(hex: "1A1510"),
                    Color(hex: "0F0A05")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Subtle court lines pattern
            CourtPattern()
                .opacity(0.1)
            
            VStack(spacing: 0) {
                Spacer()
                
                // Logo and branding
                VStack(spacing: 24) {
                    // Animated basketball icon
                    ZStack {
                        // Glow effect
                        Circle()
                            .fill(AppColors.basketball.opacity(0.3))
                            .frame(width: 140, height: 140)
                            .blur(radius: 30)
                            .scaleEffect(animateGlow ? 1.2 : 1.0)
                        
                        // Basketball
                        ZStack {
                            Circle()
                                .fill(AppColors.basketballGradient)
                                .frame(width: 100, height: 100)
                            
                            // Basketball lines
                            BasketballLines()
                                .stroke(Color.black.opacity(0.3), lineWidth: 2)
                                .frame(width: 100, height: 100)
                        }
                        .shadow(color: AppColors.basketball.opacity(0.5), radius: 20, y: 10)
                        .offset(y: animateBasketball ? -5 : 5)
                    }
                    
                    // App name
                    VStack(spacing: 8) {
                        Text("HopUp")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppColors.basketball, AppColors.basketballLight],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Level Up Your Game")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                
                Spacer()
                
                // Features list
                VStack(spacing: 20) {
                    FeatureRow(
                        icon: "flame.fill",
                        color: AppColors.fire,
                        title: "Track Your Progress",
                        description: "Log workouts and watch your skills grow"
                    )
                    
                    FeatureRow(
                        icon: "trophy.fill",
                        color: AppColors.gold,
                        title: "Earn XP & Level Up",
                        description: "Unlock achievements and climb the ranks"
                    )
                    
                    FeatureRow(
                        icon: "icloud.fill",
                        color: AppColors.basketball,
                        title: "Sync Everywhere",
                        description: "Your progress, backed up and secure"
                    )
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Sign in section
                VStack(spacing: 16) {
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        handleSignInResult(result)
                    }
                    .signInWithAppleButtonStyle(.white)
                    .frame(height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: .white.opacity(0.1), radius: 10, y: 5)
                    .disabled(isSigningIn)
                    .overlay {
                        if isSigningIn {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.black.opacity(0.5))
                                .overlay {
                                    ProgressView()
                                        .tint(.white)
                                }
                        }
                    }
                    
                    Text("Sign in to sync your progress across devices")
                        .font(.system(size: 13))
                        .foregroundStyle(AppColors.textTertiary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
        }
        .alert("Sign In Failed", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                animateBasketball = true
            }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                animateGlow = true
            }
        }
    }
    
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
            
            // Get user info for local profile
            var displayName: String?
            if let fullName = appleIDCredential.fullName {
                let formatter = PersonNameComponentsFormatter()
                let name = formatter.string(from: fullName)
                if !name.isEmpty {
                    displayName = name
                }
            }
            
            // Save Apple User ID
            UserDefaults.standard.set(appleIDCredential.user, forKey: "appleUserID")
            
            // Save display name for later use
            if let name = displayName {
                UserDefaults.standard.set(name, forKey: "userDisplayName")
            }
            
            // Authenticate with backend
            Task {
                do {
                    let response = try await APIService.shared.signInWithApple(
                        identityToken: identityTokenString,
                        userAppleId: appleIDCredential.user
                    )
                    
                    if let token = response.token {
                        AuthenticationService.shared.saveToken(token)
                    }
                    if let userId = response.user?.id {
                        AuthenticationService.shared.saveCurrentUserID(userId)
                    }
                    
                    // Update display name from response if available
                    if let serverName = response.user?.displayName, !serverName.isEmpty {
                        UserDefaults.standard.set(serverName, forKey: "userDisplayName")
                    }
                    
                    await MainActor.run {
                        isSigningIn = false
                        isAuthenticated = true
                    }
                } catch {
                    await MainActor.run {
                        isSigningIn = false
                        errorMessage = error.localizedDescription
                        showingError = true
                    }
                }
            }
            
        case .failure(let error):
            if let authError = error as? ASAuthorizationError, authError.code == .canceled {
                return
            }
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundStyle(AppColors.textSecondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Court Pattern

struct CourtPattern: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                
                // Center circle
                let centerX = width / 2
                let centerY = height * 0.4
                path.addEllipse(in: CGRect(
                    x: centerX - 60,
                    y: centerY - 60,
                    width: 120,
                    height: 120
                ))
                
                // Horizontal line
                path.move(to: CGPoint(x: 0, y: centerY))
                path.addLine(to: CGPoint(x: width, y: centerY))
                
                // Three point arc (top)
                path.addArc(
                    center: CGPoint(x: centerX, y: 0),
                    radius: width * 0.4,
                    startAngle: .degrees(30),
                    endAngle: .degrees(150),
                    clockwise: false
                )
            }
            .stroke(AppColors.courtLines, lineWidth: 1)
        }
    }
}

// MARK: - Basketball Lines

struct BasketballLines: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = rect.width / 2
        
        // Vertical line
        path.move(to: CGPoint(x: center.x, y: rect.minY))
        path.addLine(to: CGPoint(x: center.x, y: rect.maxY))
        
        // Horizontal line
        path.move(to: CGPoint(x: rect.minX, y: center.y))
        path.addLine(to: CGPoint(x: rect.maxX, y: center.y))
        
        // Curved lines
        path.addArc(
            center: center,
            radius: radius * 0.5,
            startAngle: .degrees(0),
            endAngle: .degrees(180),
            clockwise: false
        )
        
        path.addArc(
            center: center,
            radius: radius * 0.5,
            startAngle: .degrees(180),
            endAngle: .degrees(360),
            clockwise: false
        )
        
        return path
    }
}

#Preview {
    SignInView(isAuthenticated: .constant(false))
}
