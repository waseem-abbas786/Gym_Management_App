//
//  EditAdminSheet.swift
//  Gym_Management_App
//
//  Created by Waseem Abbas on 26/08/2025.
//

import SwiftUI
import _PhotosUI_SwiftUI

struct EditAdminSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: AdminViewModel
    var admin: AdminEntity
    
    @State private var name: String
    @State private var gymName: String
    @State private var gymAddress: String
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImage: UIImage?
    var manager = ImageManager.instance
    
    init(viewModel: AdminViewModel, admin: AdminEntity) {
        self.viewModel = viewModel
        self.admin = admin
        _name = State(initialValue: admin.name ?? "")
        _gymName = State(initialValue: admin.gymName ?? "")
        _gymAddress = State(initialValue: admin.gymAddress ?? "")
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("addscreen")
                    .resizable()
                    .scaledToFill()
                    .opacity(0.8)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        VStack {
                            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                if let profileImage {
                                    Image(uiImage: profileImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.yellow, lineWidth: 3))
                                        .shadow(radius: 5)
                                } else if let path = admin.profileImagePath,
                                          let image = manager.loadImageFromFileManager(path: path) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.yellow, lineWidth: 3))
                                        .shadow(radius: 5)
                                } else {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 120, height: 120)
                                        .overlay {
                                            Image(systemName: "camera.fill")
                                                .foregroundColor(.gray)
                                                .font(.system(size: 30))
                                        }
                                }
                            }
                            .onChange(of: selectedPhoto) { _, newValue in
                                Task {
                                    if let newValue,
                                       let data = try? await newValue.loadTransferable(type: Data.self),
                                       let uiImage = UIImage(data: data) {
                                        await MainActor.run {
                                            profileImage = uiImage
                                        }
                                    }
                                }
                            }
                            Text("Tap to change profile photo")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding()
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(12)
                        .shadow(radius: 4)
                        
                        VStack(spacing: 16) {
                            TextField("Name", text: $name)
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(8)
                                .frame(width: 380)
                            
                            TextField("Gym Name", text: $gymName)
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(8)
                                .frame(width: 380)
                            
                            TextField("Gym Address", text: $gymAddress)
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(8)
                                .frame(width: 380)
                        }
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(12)
                        .shadow(radius: 4)
                        .padding(.horizontal)
                        
                        Button(action: saveAdmin) {
                            Text("Save Changes")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isSaveDisabled ? Color.gray : Color.yellow)
                                .foregroundColor(.black)
                                .cornerRadius(12)
                                .bold()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .disabled(isSaveDisabled)
                        .padding(.top, 10)
                        .animation(.easeInOut(duration: 0.3), value: isSaveDisabled)
                        .frame(width: 380)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Edit Admin")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    var isSaveDisabled: Bool {
        name.isEmpty || gymName.isEmpty || gymAddress.isEmpty
    }
    
    func saveAdmin() {
        admin.name = name
        admin.gymName = gymName
        admin.gymAddress = gymAddress
        
        if let image = profileImage {
            let path = manager.saveImageToFileManager(image: image)
                admin.profileImagePath = path
            
            viewModel.saveContext()
            dismiss()
        }
    }
}
