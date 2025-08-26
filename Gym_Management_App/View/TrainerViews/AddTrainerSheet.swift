//
//  AddTrainerSheet.swift
//  Gym_Management_App
//
//  Created by Waseem Abbas on 26/08/2025.
//
import SwiftUI
import _PhotosUI_SwiftUI
struct AddTrainerSheet: View {
    @ObservedObject var viewModel: TrainerViewModel
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
                            Text("Tap to choose profile photo")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding()
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(12)
                        .shadow(radius: 4)

                        VStack(spacing: 16) {
                            TextField("Name", text: $viewModel.name)
                                .padding()
                                .frame(width: 380)
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(8)

                            TextField("Phone Number", text: $viewModel.number)
                                .keyboardType(.phonePad)
                                .padding()
                                .frame(width: 380)
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(8)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Speciality")
                                    .foregroundColor(.white)
                                    .font(.headline)
                                Picker("", selection: $viewModel.speciality) {
                                    ForEach(Speciality.allCases) { speciality in
                                        Text(speciality.rawValue).tag(speciality)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .frame(width: 380)
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(12)
                        .shadow(radius: 4)

                        
                        Button(action: {
                            viewModel.addTrainer()
                            dismiss()
                            viewModel.resetForm()
                        }) {
                            Text("Save Trainer")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(viewModel.isButtonvalid ? Color.red : Color.yellow)
                                .foregroundColor(.black)
                                .cornerRadius(12)
                                .bold()
                                .opacity(viewModel.isButtonvalid ? 0.6 : 1.0)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .disabled(viewModel.isButtonvalid)
                        .padding(.top, 10)
                        .frame(width: 380)
                    }
                    .padding()
                }
            }
            .navigationTitle("Add Trainer")
            .navigationBarTitleDisplayMode(.inline)
            
        }
    }
}

