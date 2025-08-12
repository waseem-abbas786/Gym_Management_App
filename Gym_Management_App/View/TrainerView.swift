//
//  TrainerView.swift
//  Gym_Management_App
//
//  Created by Waseem Abbas on 09/08/2025.
import CoreData
import SwiftUI
import PhotosUI

struct TrainerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var trainerVM: TrainerViewModel

    @State private var searchText = ""
    @State private var showDeleteAlert = false
    @State private var trainerToDelete: TrainerEntity?
    @State private var trainerToEdit: TrainerEntity?

    init(context: NSManagedObjectContext) {
        self._trainerVM = StateObject(wrappedValue: TrainerViewModel(context: context))
    }

    var filteredTrainers: [TrainerEntity] {
        if searchText.isEmpty {
            return trainerVM.trainers
        } else {
            return trainerVM.trainers.filter {
                ($0.name ?? "").localizedCaseInsensitiveContains(searchText) ||
                ($0.speciality ?? "").localizedCaseInsensitiveContains(searchText) ||
                ($0.number ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Image("muscule")
                    .resizable()
                    .opacity(0.9)
                    .ignoresSafeArea(edges: .bottom)

                VStack {
                    if trainerVM.trainers.isEmpty {
                        ContentUnavailableView(
                            "No Trainers Yet",
                            systemImage: "person.crop.circle.badge.xmark",
                            description: Text("Tap the Add Button To Add a Trainer!")
                        )
                        .foregroundStyle(Color.red)
                        .transition(.opacity.combined(with: .scale))
                        .animation(.easeInOut(duration: 0.4), value: trainerVM.trainers.isEmpty)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredTrainers.indices, id: \.self) { index in
                                    let trainer = filteredTrainers[index]

                                    HStack {
                                        if let imagePath = trainer.profileImagePath,
                                           let image = trainerVM.loadImageFromFileManager(path: imagePath) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 70, height: 70)
                                                .clipShape(Circle())
                                        } else {
                                            Circle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(width: 70, height: 70)
                                        }

                                        VStack(alignment: .leading) {
                                            Text(trainer.name ?? "No Name")
                                                .font(.headline)
                                                .foregroundStyle(Color.white)
                                            Text(trainer.speciality ?? "No Speciality")
                                                .font(.subheadline)
                                                .foregroundStyle(Color.white)
                                            Text(trainer.number ?? "No Number")
                                                .font(.caption)
                                                .foregroundColor(.yellow)
                                                .bold()
                                        }
                                        .bold()

                                        Spacer()

                                        Button {
                                            trainerToEdit = trainer
                                        } label: {
                                            Image(systemName: "pencil")
                                                .foregroundColor(.yellow)
                                                .padding(8)
                                                .background(Circle().fill(Color.black.opacity(0.6)))
                                        }
                                        .buttonStyle(.plain)

                                        Button {
                                            trainerToDelete = trainer
                                            showDeleteAlert = true
                                        } label: {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                                .padding(8)
                                                .background(Circle().fill(Color.black.opacity(0.6)))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding()
                                    .background(index.isMultiple(of: 2) ? Color.black.opacity(0.4) : Color.black.opacity(0.2))
                                    .cornerRadius(12)
                                    .shadow(radius: 3)
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.vertical)
                        }
                        .sheet(item: $trainerToEdit) { trainer in
                            EditTrainerSheet(viewModel: trainerVM, trainer: trainer)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink("Trainer+") {
                        AddTrainerSheet(viewModel: trainerVM)
                    }
                    .foregroundStyle(Color.yellow)
                }
            }
            .onAppear {
                trainerVM.fetchTrainers()
            }
            .navigationTitle("Trainers")
            .searchable(text: $searchText, prompt: "Search by Name, Speciality, or Number")
            .alert("Delete Trainer?", isPresented: $showDeleteAlert) {
                Button("Yes", role: .destructive) {
                    if let trainer = trainerToDelete {
                        trainerVM.deleteTrainer(trainer: trainer)
                        trainerToDelete = nil
                    }
                }
                Button("No", role: .cancel) {
                    trainerToDelete = nil
                }
            } message: {
                Text("Are you sure you want to delete this trainer?")
            }
        }
    }
}

#Preview {
    TrainerView(context: PersistenceController.shared.container.viewContext)
       
}
// MARK: The sheet \ View for adding the trainer

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



struct EditTrainerSheet: View {
    @ObservedObject var viewModel: TrainerViewModel
    @State var trainer: TrainerEntity
    @Environment(\.dismiss) var dismiss

    @State private var name: String = ""
    @State private var speciality: String = ""
    @State private var number: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var photoItem: PhotosPickerItem?

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

                        
                        Button(action: {
                            trainer.name = name
                            trainer.speciality = speciality
                            trainer.number = number

                            if let selectedImage {
                                if let path = viewModel.saveImageToFilemanager(image: selectedImage) {
                                    trainer.profileImagePath = path
                                }
                            }

                            viewModel.saveContext()
                            dismiss()
                        }) {
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
                name = trainer.name ?? ""
                speciality = trainer.speciality ?? ""
                number = trainer.number ?? ""
                if let path = trainer.profileImagePath,
                   let image = viewModel.loadImageFromFileManager(path: path) {
                    selectedImage = image
                }
            }
        }
    }
}
