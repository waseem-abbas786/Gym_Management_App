//
//  TrainerView.swift
//  Gym_Management_App
//
//  Created by Waseem Abbas on 09/08/2025.
import CoreData
import SwiftUI

struct TrainerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var trainerVM: TrainerViewModel

    let isAdminAvailable: Bool

      init(context: NSManagedObjectContext, isAdminAvailable: Bool) {
          self._trainerVM = StateObject(wrappedValue: TrainerViewModel(context: context))
          self.isAdminAvailable = isAdminAvailable
      }

    var body: some View {
        NavigationStack {
            ZStack {
                Image("admin")
                    .resizable()
                    .opacity(0.8)
                    .ignoresSafeArea()

                VStack {
                    if trainerVM.trainers.isEmpty {
                        ContentUnavailableView(
                            "No Trainers Yet",
                            systemImage: "person.crop.circle.badge.xmark",
                            description: Text("Tap the Add Button To Add a Trainer!")
                        )
                        .foregroundStyle(Color.red)
                    } else {
                        List {
                            ForEach(trainerVM.trainers, id: \.id) { trainer in
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
                                        Text(trainer.speciality ?? "No Speciality")
                                            .font(.subheadline)
                                        Text(trainer.number ?? "No Number")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .frame(height: 100)
                                
                                .id(trainer.id)
                                .listRowBackground(Color.white.opacity(0.9))
                                Divider()
                                    .frame(height: 10)
                                    .listRowBackground(Color.white.opacity(0.0))
                            }
                            .onDelete(perform: trainerVM.deleteTrainer)
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink("Add Trainer") {
                 AddTrainerSheet(viewModel: trainerVM)
                    }
                    .disabled(!isAdminAvailable)
                    .foregroundStyle(Color.white)
                    .frame(width: 100, height: 50)
                    .background(Color.blue)
                    .clipShape(.buttonBorder)
                }
            }
         
        }
        .onAppear {
                       trainerVM.fetchTrainers()
                   }
    }
}

#Preview {
    TrainerView(context: PersistenceController.shared.container.viewContext, isAdminAvailable: false)
       
}
// MARK: The sheet \ View for adding the trainer
import SwiftUI
import PhotosUI

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
                        .pickerStyle(.menu)
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
                    .disabled(viewModel.name.isEmpty || viewModel.number.isEmpty)
                    .foregroundStyle((viewModel.name.isEmpty || viewModel.number.isEmpty) ? Color.red : Color.white)
                    .animation(.easeInOut(duration: 2.0), value: viewModel.name.isEmpty || viewModel.number.isEmpty)
                    .frame(width: 100, height: 50)
                    .background(Color.white.opacity(0.8))
                    .clipShape(.buttonBorder)
                }
            }
        }
    }
}
