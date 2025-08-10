//
//  AdminView.swift
//  Gym_Management_App
//
//  Created by Waseem Abbas on 07/08/2025.
//
import SwiftUI
import CoreData

struct AdminView: View {
    @Binding var isLoggedIn: Bool
    @StateObject private var viewModel = SignInViewmodel()
    @Environment(\.managedObjectContext) private var viewContext
       @StateObject private var adminVM: AdminViewModel
       init(isLoggedIn: Binding<Bool>, context: NSManagedObjectContext) {
           self._isLoggedIn = isLoggedIn
           self._adminVM = StateObject(wrappedValue: AdminViewModel(context: context))
       }

    var body: some View {
        NavigationStack {
            ZStack {
                Image("muscule")
                    .resizable()
                    .opacity(0.9)
                    .ignoresSafeArea()
                VStack {
                    if adminVM.admins.isEmpty {
                        ContentUnavailableView (
                            "No Gym Owner Yet",
                            systemImage: "person.crop.circle.badge.xmark",
                            description: Text("Tap the Add Button To Add a Gym Owner!")
                        )
                        .foregroundStyle(Color.white)
                        .bold()
                    } else {
                        List {
                            ForEach(adminVM.admins, id:\.id) { admin in
                                HStack() {
                                    if let imagePath = admin.profileImagePath,
                                       let image = adminVM.loadImageFromFileManager(path: imagePath) {
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
                                        Text(admin.name ?? "No Name")
                                            .font(.headline)
                                        Text(admin.gymName ?? "No Gym Name")
                                            .font(.subheadline)
                                        Text(admin.gymAddress ?? "No Address")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .id(admin.id)
                              }
            
                            .onDelete(perform: adminVM.deleteAdmins)
                        }
                        .scrollContentBackground(.hidden)
                     }
                }
            }
              .toolbar {
                if !adminVM.admins.isEmpty {
                    ToolbarItem(placement: .topBarLeading) {
                        NavigationLink("Members") {
                            MemberView(context: viewContext)
                        }
                        .foregroundStyle(Color.white)
                    }
                }
                if !adminVM.admins.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                          NavigationLink("Trainers🏋🏻‍♀️") {
                              TrainerView(
                                      context: viewContext,
                                      isAdminAvailable: !adminVM.admins.isEmpty
                                  )
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
            
        }
    }
}


#Preview {
    AdminView(isLoggedIn: .constant(false),
    context: PersistenceController.shared.container.viewContext
    )
   
}
import SwiftUI
import PhotosUI

struct AddAdminSheet: View {
    @ObservedObject var viewModel: AdminViewModel
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
                Section("Admin Details") {
                    TextField("Name", text: $viewModel.name)
                    TextField("Gym Name", text: $viewModel.gymName)
                    TextField("Gym Address", text: $viewModel.gymAddress)
                    SecureField("Password", text: $viewModel.password)
                }
                .listRowBackground(Color.white.opacity(0.9))
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
            .navigationTitle("Add Admin")
            
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.addAdmin()
                        dismiss()
                        viewModel.resetForm()
                    }
                    .disabled(viewModel.isSaveButtonDisabled)
                    .foregroundStyle(viewModel.isSaveButtonDisabled ? Color.red : Color.white)
                    .animation(.easeInOut(duration: 2.0), value: viewModel.isSaveButtonDisabled)
                    .frame(width: 100, height: 50)
                    .background(Color.white.opacity(0.8))
                    .clipShape(.buttonBorder)
                    
                }
            }
        }
    }
}


