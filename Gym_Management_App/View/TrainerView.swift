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
    @State private var trainerToEdit: TrainerEntity?  // single optional state for edit

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
                Image("admin")
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
                        List {
                            ForEach(filteredTrainers, id: \.id) { trainer in
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
                                }
                                .id(trainer.id)
                                .listRowBackground(Color.black.opacity(0.0))
                                .onTapGesture {
                                    trainerToEdit = trainer
                                }
                                Divider()
                                    .frame(height: 10)
                                    .listRowBackground(Color.white.opacity(0.0))
                            }
                            .onDelete { indexSet in
                                if let index = indexSet.first {
                                    trainerToDelete = filteredTrainers[index]
                                    showDeleteAlert = true
                                }
                            }
                        }
                        .scrollContentBackground(.hidden)
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
                    }
                }
                Button("No", role: .cancel) { }
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
                    
                    Section("Trainer Details") {
                        TextField("Name", text: $viewModel.name)
                        TextField("Phone Number", text: $viewModel.number)
                        
                        Picker("Speciality", selection: $viewModel.speciality) {
                            ForEach(Speciality.allCases) { speciality in
                                Text(speciality.rawValue).tag(speciality)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .listRowBackground(Color.white.opacity(0.9))
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            .navigationTitle("Add Trainer")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.addTrainer()
                        dismiss()
                        viewModel.resetForm()
                    }
                    .disabled(viewModel.isButtonvalid)
                    .bold()
                    .foregroundStyle(viewModel.isButtonvalid ? Color.red : Color.yellow)
                    .strikethrough(viewModel.isButtonvalid ? true : false, pattern: .solid)
                    .animation(.easeInOut(duration: 1.0), value: viewModel.isButtonvalid)
                    
                }
            }
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
            Form {
                Section(header: Text("Trainer Info")) {
                    TextField("Name", text: $name)
                    TextField("Speciality", text: $speciality)
                    TextField("Number", text: $number)
                        .keyboardType(.phonePad)
                }

                Section(header: Text("Profile Image")) {
                    PhotosPicker(selection: $photoItem, matching: .images, photoLibrary: .shared()) {
                        if let selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                                .clipShape(Circle())
                                .padding()
                        } else {
                            Text("Select Image")
                        }
                    }
                    .onChange(of: photoItem) {_, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                selectedImage = uiImage
                            }
                        }
                    }
                }
            }
            .navigationTitle("Edit Trainer")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
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
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
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
