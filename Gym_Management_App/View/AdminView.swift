//
//  AdminView.swift
//  Gym_Management_App
//
//  Created by Waseem Abbas on 07/08/2025.
//
import SwiftUI
import PhotosUI
import CoreData

struct AdminView: View {
    @Binding var isLoggedIn: Bool
    @StateObject private var viewModel = SignInViewmodel()
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var adminVM: AdminViewModel
    @StateObject private var memberVM: MemberViewModel
    @StateObject private var trainerVM: TrainerViewModel
    
    @State private var adminToEdit: AdminEntity? // Only one state to handle edit

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
                                .onTapGesture(count: 2) { // Double tap to edit
                                   
                                }
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
                        NavigationLink("Members") {
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
            // Edit sheet using just `adminToEdit`
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
                    .foregroundStyle(viewModel.isSaveButtonDisabled ? Color.red : Color.yellow)
                    .animation(.easeInOut(duration: 2.0), value: viewModel.isSaveButtonDisabled)
                    
                    
                }
            }
        }
    }
}


//MARK: the slide view
struct GymQuoteSlider: View {
    let slides: [(quote: String, image: String)]
    @State private var currentIndex = 0
    @State private var timer: Timer? = nil
    
    var body: some View {
        ZStack {
            Image(slides[currentIndex].image)
                .resizable()
                .scaledToFill()
                .frame(height: 350)
                .clipped()
                .cornerRadius(22)
                .shadow(radius: 5)
                .transition(.opacity)
            Color.black.opacity(0.4)
                .cornerRadius(22)
            Text(slides[currentIndex].quote)
                .font(.headline)
                .foregroundColor(.yellow)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .transition(.opacity)
        }
        .padding(.top, 40)
        .frame(maxWidth: .infinity)
        .frame(height: 350)
        .listRowBackground(Color.clear)
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            withAnimation(.easeInOut) {
                currentIndex = (currentIndex + 1) % slides.count
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
//MARK: the edit  view
struct EditAdminSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: AdminViewModel
    var admin: AdminEntity

    @State private var name: String
    @State private var gymName: String
    @State private var gymAddress: String
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImage: UIImage?

    init(viewModel: AdminViewModel, admin: AdminEntity) {
        self.viewModel = viewModel
        self.admin = admin
        _name = State(initialValue: admin.name ?? "")
        _gymName = State(initialValue: admin.gymName ?? "")
        _gymAddress = State(initialValue: admin.gymAddress ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Admin Details") {
                    TextField("Name", text: $name)
                    TextField("Gym Name", text: $gymName)
                    TextField("Gym Address", text: $gymAddress)
                }

                Section("Profile Image") {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Text("Select Image")
                    }
                    if let profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else if let path = admin.profileImagePath,
                              let image = viewModel.loadImageFromFileManager(path: path) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    }
                }
            }
            .navigationTitle("Edit Admin")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        admin.name = name
                        admin.gymName = gymName
                        admin.gymAddress = gymAddress

                        if let image = profileImage {
                            let savedPath = viewModel.saveImageToFileManager(image: image)
                            admin.profileImagePath = savedPath
                        }

                        viewModel.saveContext()
                        dismiss()
                    }
                }
            }
            .onChange(of: selectedPhoto) { _, newValue in
                Task {
                    if let newValue, let data = try? await newValue.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        profileImage = uiImage
                    }
                }
            }
        }
    }
}
