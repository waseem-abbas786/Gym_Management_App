//
//  AddMemberSheet.swift
//  Gym_Management_App
//
//  Created by Waseem Abbas on 26/08/2025.
//

import SwiftUI
import _PhotosUI_SwiftUI
struct AddMemberSheet: View {
    @ObservedObject var viewModel: MemberViewModel
    @Environment(\.dismiss) var dismiss

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
                            PhotosPicker(selection: $viewModel.selectedPhoto, matching: .images) {
                                if let profileImage = viewModel.profileImage {
                                    Image(uiImage: profileImage)
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
                            Text("Tap to add profile photo")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding()
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(12)
                        .shadow(radius: 4)

                        // Member Details Section
                        VStack(spacing: 16) {
                                 TextField("Name", text: $viewModel.name)
                                     .padding()
                                     .background(Color.white.opacity(0.9))
                                     .cornerRadius(8)
                                     .frame(width: 380)

                                 TextField("Phone Number", text: $viewModel.number)
                                     .keyboardType(.phonePad)
                                     .padding()
                                     .background(Color.white.opacity(0.9))
                                     .cornerRadius(8)
                                     .frame(width: 380)

                                 TextField("Age", text: $viewModel.age)
                                     .keyboardType(.numberPad)
                                     .padding()
                                     .background(Color.white.opacity(0.9))
                                     .cornerRadius(8)
                                     .frame(width: 380)

                                 Picker("Membership Type", selection: $viewModel.membershipType) {
                                     ForEach(MembershipType.allCases) { type in
                                         Text(type.rawValue).tag(type)
                                     }
                                 }
                                 .pickerStyle(.segmented)
                                 .frame(width: 380)
                             }
                             .background(Color.black.opacity(0.4))
                             .cornerRadius(12)
                             .shadow(radius: 4)
                             .padding(.horizontal)
                        Button(action: {
                            viewModel.addMember()
                            dismiss()
                        }) {
                            Text("Save Member")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(viewModel.isSaveButtonDisabled ? Color.gray : Color.yellow)
                                .foregroundColor(.black)
                                .cornerRadius(12)
                                .bold()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .disabled(viewModel.isSaveButtonDisabled)
                        .padding(.top, 10)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.isSaveButtonDisabled)
                    }
                    .padding()
                    .frame(width: 380)
                }
            }
            .navigationTitle("Add Member")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
