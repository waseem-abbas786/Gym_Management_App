//
//  SignUpScreen.swift
//  Gym_Management_App
//
//  Created by Waseem Abbas on 07/08/2025.
//



import SwiftUI

struct SignUpScreen: View {
    @Binding var isLoggedIn: Bool
    @StateObject private var viewModel = SignInViewmodel()
    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack {
            Image("signin")
                .resizable()
                .ignoresSafeArea()
                .opacity(0.9)
            VStack {
                Text("Sign Up").font(.largeTitle)
                    .foregroundStyle(Color.white)
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
                 Text("SignUp")
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .foregroundStyle(Color.white)
                    .background(Color.blue)
                    .clipShape(.buttonBorder)
                    .shadow(color: .white, radius: 10, y: 10)
                    .padding()
                    .onTapGesture {
                        Task {
                            do {
                                _ = try await viewModel.signUp(email: email, password: password)
                                await MainActor.run {
                                    isLoggedIn = true
                                    dismiss()
                                }
                            } catch {
                                await MainActor.run {
                                    showError = true
                                    errorMessage = "The Email Or Password is Invalid⚠️"
                                }
                            }
                        }
                    }

               
            }
        }

        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
}


#Preview {
    SignUpScreen(isLoggedIn: .constant(false))
}
