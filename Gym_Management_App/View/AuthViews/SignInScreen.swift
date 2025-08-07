//
//  SignInScreen.swift
//  Gym_Management_App
//
//  Created by Waseem Abbas on 07/08/2025.
//

import SwiftUI

struct SignInScreen: View {
    @Binding var isLoggedIn: Bool
    @StateObject private var viewModel = SignInViewmodel()
    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var animate = false
    var body: some View {
        ZStack {
            Image("signin")
                .resizable()
                .opacity(0.9)
                .ignoresSafeArea()
            VStack(spacing: 16) {
                Text("Sign In").font(.largeTitle)
                    .foregroundStyle(Color.white)
                    Divider()

                TextField("Email", text: $email)
                    .padding()
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .clipShape(.buttonBorder)
                    .padding(.horizontal)
                    

                SecureField("Password", text: $password)
                    .padding()
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .clipShape(.buttonBorder)
                    .padding(.horizontal)

                Button("Sign In") {
                    Task {
                        do {
                            _ = try await viewModel.signIn(email: email, password: password)
                            isLoggedIn = true
                        } catch {
                            await MainActor.run {
                                showError = true
                                errorMessage = error.localizedDescription
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 55)
                .foregroundStyle(Color.white)
                .background(Color.blue)
                .clipShape(.buttonBorder)
                .shadow(color: .white, radius: 10, y: 10)
                .padding()

                NavigationLink("Don't have an account? Sign Up", destination: SignUpScreen(isLoggedIn: $isLoggedIn))
                    .padding(.top, 20)
                    .foregroundStyle(Color.white)
            }
            .padding(.horizontal)
        }
    
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
}


#Preview {
    SignInScreen(isLoggedIn: .constant(false))
}
