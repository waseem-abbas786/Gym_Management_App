//
//  AdminView.swift
//  Gym_Management_App
//
//  Created by Waseem Abbas on 07/08/2025.
//
import SwiftUI
import PhotosUI
import CoreData
import Combine

struct AdminView: View {
    @Binding var isLoggedIn: Bool
    @StateObject private var viewModel = SignInViewmodel()
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var adminVM: AdminViewModel
    @StateObject private var memberVM: MemberViewModel
    @StateObject private var trainerVM: TrainerViewModel
    var manager = ImageManager.instance
    
    @State private var adminToEdit: AdminEntity?
    init(isLoggedIn: Binding<Bool>, context: NSManagedObjectContext) {
        self._isLoggedIn = isLoggedIn
        self._adminVM = StateObject(wrappedValue: AdminViewModel(context: context))
        self._memberVM = StateObject(wrappedValue: MemberViewModel(context: context))
        self._trainerVM = StateObject(wrappedValue: TrainerViewModel(context: context))
    }

    let gymSlides: [(quote: String, image: String)] = [
        ("No pain, no gain.", "bg1"),
        ("Train insane or remain the same.", "bg2"),
        ("Sweat is just fat crying.", "bg3"),
        ("Push yourself because no one else will do it for you.", "bg4"),
        ("The body achieves what the mind believes.", "bg5"),
        ("Don’t limit your challenges, challenge your limits.", "bg6"),
        ("Strong is the new sexy.", "bg7"),
        ("Make yourself stronger than your excuses.", "bg8")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Image("muscule")
                    .resizable()
                    .scaledToFill()
                    .opacity(0.9)
                    .ignoresSafeArea()

                VStack {
                    if adminVM.admins.isEmpty {
                        ContentUnavailableView(
                            "No Gym Owner Yet",
                            systemImage: "person.crop.circle.badge.xmark",
                            description: Text("Tap the Add Button To Add a Gym Owner!")
                        )
                        .foregroundStyle(Color.white)
                        .bold()
                    } else {
                        List {
                            ForEach(adminVM.admins, id: \.id) { admin in
                                HStack(alignment: .center, spacing: 12) {
                                    if let imagePath = admin.profileImagePath,
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

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(admin.name ?? "No Name")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text(admin.gymName ?? "No Gym Name")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.9))
                                        Text(admin.gymAddress ?? "No Address")
                                            .font(.caption)
                                            .foregroundColor(.yellow)
                                    }
                                    .bold()
                                    Spacer()
                                    Button {
                                     adminToEdit = admin
                                        } label: {
                                      Image(systemName: "pencil")
                                       .foregroundColor(.yellow)
                                     .padding(8)
                                     .background(Circle().fill(Color.black.opacity(0.3)))
                                            }
                                        .buttonStyle(.plain)
                                }
                                .padding()
                                .background(Color.black.opacity(0.3))
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .listRowBackground(Color.clear)
                            }
                            
                            HStack(spacing: 16) {
                                statCard(title: "Total Members", count: memberVM.members.count)
                                statCard(title: "Total Trainers", count: trainerVM.trainers.count)
                            }
                            .listRowBackground(Color.clear)

                            Section {
                                GymQuoteSlider(slides: gymSlides)
                                    .listRowBackground(Color.clear)
                            }
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .onAppear {
                adminVM.fetchAdmins()
                memberVM.fetchMembers()
                trainerVM.fetchTrainers()
            }
            .toolbar {
                if !adminVM.admins.isEmpty {
                    ToolbarItem(placement: .topBarLeading) {
                        NavigationLink("Members👥") {
                            MemberView(context: viewContext)
                        }
                        .foregroundStyle(Color.white)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink("Trainers🏋🏻‍♀️") {
                            TrainerView(context: viewContext)
                        }
                        .foregroundStyle(Color.white)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Log Out") {
                        do {
                            try viewModel.signOut()
                            isLoggedIn = false
                        } catch {
                            print("Logout failed: \(error.localizedDescription)")
                        }
                    }
                    .foregroundStyle(Color.white)
                }
                if adminVM.admins.isEmpty {
                    ToolbarItem(placement: .topBarLeading) {
                        NavigationLink("Manage Admin") {
                            AddAdminSheet(viewModel: adminVM)
                        }
                        .foregroundStyle(Color.white)
                    }
                }
            }
            .sheet(item: $adminToEdit) { admin in
                EditAdminSheet(viewModel: adminVM, admin: admin)
            }
        }
    }

    private func statCard(title: String, count: Int) -> some View {
        VStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            Text("\(count)")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.yellow)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.black.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(radius: 4)
    }
}


#Preview {
    AdminView(
        isLoggedIn: .constant(false),
        context: PersistenceController.shared.container.viewContext
    )
}

