//
//  EditMemberSheet.swift
//  Gym_Management_App
//
//  Created by Waseem Abbas on 26/08/2025.
//

import SwiftUI
import _PhotosUI_SwiftUI

struct EditMemberSheet: View {
    @ObservedObject var viewModel: MemberViewModel
    @State var member: MemberEntity
    @Environment(\.dismiss) var dismiss

    // Local editable states
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var membershipType: MembershipType = .basic
    @State private var number: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var photoItem: PhotosPickerItem?
    var manager = ImageManager.instance

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
                            PhotosPicker(selection: $photoItem, matching: .images) {
                                if let selectedImage {
                                    Image(uiImage: selectedImage)
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
                            .onChange(of: photoItem) { _, newValue in
                                Task {
                                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                                       let uiImage = UIImage(data: data) {
                                        await MainActor.run {
                                            selectedImage = uiImage
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

                            TextField("Phone Number", text: $number)
                                .keyboardType(.phonePad)
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(8)
                                .frame(width: 380)

                            TextField("Age", text: $age)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(8)
                                .frame(width: 380)

                            Picker("Membership Type", selection: $membershipType) {
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
                        Button(action: saveMember) {
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
            .navigationTitle("Edit Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .onAppear {
                name = member.name ?? ""
                age = member.age ?? ""
                number = member.number ?? ""
                membershipType = MembershipType(rawValue: member.membershipType ?? "") ?? .basic
                if let path = member.profileImagePath,
                   let image = manager.loadImageFromFileManager(path: path) {
                    selectedImage = image
                }
            }
        }
    }

    var isSaveDisabled: Bool {
        name.isEmpty || age.isEmpty || number.isEmpty
    }

    func saveMember() {
        member.name = name
        member.age = age
        member.membershipType = membershipType.rawValue
        member.number = number

        if let image = selectedImage {
            let path = manager.saveImageToFileManager(image: image)
                member.profileImagePath = path
            viewModel.saveContext()
            dismiss()
        }

      
    }
}
