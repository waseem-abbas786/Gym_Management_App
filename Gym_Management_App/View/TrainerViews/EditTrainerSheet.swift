import SwiftUI
import _PhotosUI_SwiftUI

struct EditTrainerSheet: View {
    @ObservedObject var viewModel: TrainerViewModel
    @State var trainer: TrainerEntity
    @Environment(\.dismiss) var dismiss

    @State private var name: String = ""
    @State private var speciality: String = ""
    @State private var number: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var photoItem: PhotosPickerItem?
    var manager = ImageManager.instance

    var body: some View {
        NavigationStack {
            ZStack {
                Image("admin")
                    .resizable()
                    .scaledToFill()
                    .opacity(0.8)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        
                        VStack {
                            PhotosPicker(selection: $photoItem, matching: .images) {
                                profilePhotoView
                            }
                            .onChange(of: photoItem) { _, newItem in
                                Task {
                                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                                       let uiImage = UIImage(data: data) {
                                        selectedImage = uiImage
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
                                .frame(width: 380)
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(8)

                            TextField("Speciality", text: $speciality)
                                .padding()
                                .frame(width: 380)
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(8)

                            TextField("Phone Number", text: $number)
                                .keyboardType(.phonePad)
                                .padding()
                                .frame(width: 380)
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(8)
                        }
                        .padding()
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(12)
                        .shadow(radius: 4)

                        
                        Button(action: saveChanges) {
                            Text("Save Changes")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.yellow)
                                .foregroundColor(.black)
                                .cornerRadius(12)
                                .bold()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .padding(.top, 10)
                        .frame(width: 380)
                    }
                    .padding()
                }
            }
            .navigationTitle("Edit Trainer")
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
                loadTrainerData()
            }
        }
    }
    
    // MARK: - Subviews
    private var profilePhotoView: some View {
        Group {
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
    }
    
    // MARK: - Functions
    private func loadTrainerData() {
        name = trainer.name ?? ""
        speciality = trainer.speciality ?? ""
        number = trainer.number ?? ""
        if let path = trainer.profileImagePath,
           let image = manager.loadImageFromFileManager(path: path) {
            selectedImage = image
        }
    }
    
    private func saveChanges() {
        trainer.name = name
        trainer.speciality = speciality
        trainer.number = number
        if let path = trainer.profileImagePath,
           let image = manager.loadImageFromFileManager(path: path) {
            selectedImage = image
        }
         viewModel.saveContext()
        dismiss()
    }
}
