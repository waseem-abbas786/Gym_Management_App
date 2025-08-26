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
    var manager = ImageManager.instance

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
                                           let image = manager.loadImageFromFileManager(path: imagePath) {
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


