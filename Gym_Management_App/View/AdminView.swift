//
//  AdminView.swift
//  Gym_Management_App
//
//  Created by Waseem Abbas on 07/08/2025.
//
import SwiftUI

struct AdminView: View {
    @Binding var isLoggedIn: Bool
    @StateObject private var viewModel = SignInViewmodel()

    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome Admin 🏋️‍♂️")
                    .font(.largeTitle)

                Button("Log Out") {
                    do {
                        try viewModel.signOut()
                        isLoggedIn = false
                    } catch {
                        print("Logout failed: \(error.localizedDescription)")
                    }
                }
                .padding(.top)
            }
        }
    }
}


#Preview {
    NavigationStack {
        AdminView(isLoggedIn: .constant(false))
    }
   
}
