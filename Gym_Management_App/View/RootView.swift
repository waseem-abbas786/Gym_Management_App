//
//  RootView.swift
//  Gym_Management_App
//
//  Created by Waseem Abbas on 07/08/2025.
//

import SwiftUI

struct RootView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @StateObject private var viewModel = SignInViewmodel()
    @State private var isLoggedIn = false

    var body: some View {
        ZStack {
            if isLoggedIn {
                AdminView(isLoggedIn: $isLoggedIn, context: viewContext)
            } else {
                NavigationStack {
                    SignInScreen(isLoggedIn: $isLoggedIn)
                }
            }
        }
        .onAppear {
            let user = try? viewModel.getAuthenticatedUser()
            isLoggedIn = user != nil
        }
    }
}

#Preview {
    RootView()
}
