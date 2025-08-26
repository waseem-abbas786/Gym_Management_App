//
//  AddAdminSheet.swift
//  Gym_Management_App
//
//  Created by Waseem Abbas on 26/08/2025.
//

import SwiftUI
import _PhotosUI_SwiftUI
struct AddAdminSheet: View {
    @ObservedObject var viewModel: AdminViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Image("admin")
                    .resizable()
                    .opacity(0.8)
                    .ignoresSafeArea()
            Form {
                Section("Profile Photo") {
                    PhotosPicker(selection: $viewModel.selectedPhoto, matching: .images) {
                        if let profileImage = viewModel.profileImage {
                            Image(uiImage: profileImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 100, height: 100)
                                .overlay {
                                    Image(systemName: "camera.fill")
                                        .foregroundColor(.gray)
                                }
                        }
                    }
                    .onChange(of: viewModel.selectedPhoto) { _, newValue in
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                await MainActor.run {
                                    viewModel.profileImage = uiImage
                                }
                            }
                        }
                    }
                    
                    
                }
                .listRowBackground(Color.white.opacity(0.9))
                Section("Admin Details") {
                    TextField("Name", text: $viewModel.name)
                    TextField("Gym Name", text: $viewModel.gymName)
                    TextField("Gym Address", text: $viewModel.gymAddress)
                    SecureField("Password", text: $viewModel.password)
                }
                .listRowBackground(Color.white.opacity(0.9))
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
            .navigationTitle("Add Admin")
            
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.addAdmin()
                        dismiss()
                        viewModel.resetForm()
                    }
                    .disabled(viewModel.isSaveButtonDisabled)
                    .foregroundStyle(viewModel.isSaveButtonDisabled ? Color.red : Color.yellow)
                    .animation(.easeInOut(duration: 2.0), value: viewModel.isSaveButtonDisabled)
                    
                    
                }
            }
        }
    }
}

