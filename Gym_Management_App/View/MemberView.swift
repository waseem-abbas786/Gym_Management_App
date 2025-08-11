//
//  MemberView.swift
//  Gym_Management_App
//
//  Created by Waseem Abbas on 10/08/2025.
//
import SwiftUI
import PhotosUI
import CoreData

struct MemberView: View {
    @State var searchText = ""
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var memberVM: MemberViewModel
    
    @State private var showDeleteAlert = false
    @State private var memberToDelete: MemberEntity?
    @State private var memberToEdit: MemberEntity? = nil


    init(context: NSManagedObjectContext) {
        self._memberVM = StateObject(wrappedValue: MemberViewModel(context: context))
    }
    
    var filteredMembers: [MemberEntity] {
        if searchText.isEmpty {
            return memberVM.members
        } else {
            return memberVM.members.filter {
                ($0.name ?? "").localizedCaseInsensitiveContains(searchText) ||
                ($0.membershipType ?? "").localizedCaseInsensitiveContains(searchText) ||
                ($0.age ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Image("muscule")
                    .resizable()
                    .ignoresSafeArea(edges: .bottom)
                    .opacity(0.9)

                VStack {
                    if memberVM.members.isEmpty {
                        ContentUnavailableView(
                            "No Members Yet",
                            systemImage: "person.3",
                            description: Text("Tap the Add Button to Add a Member!")
                        )
                        .foregroundStyle(Color.white)
                        .transition(.opacity.combined(with: .scale))
                        .animation(.easeInOut(duration: 0.4), value: memberVM.members.isEmpty)
                    } else {
                        List {
                            ForEach(filteredMembers, id: \.id) { member in
                                HStack {
                                    if let imagePath = member.profileImagePath,
                                       let image = memberVM.loadImageFromFileManager(path: imagePath) {
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
                                        Text(member.name ?? "No Name")
                                            .font(.headline)
                                            .foregroundStyle(Color.white)
                                        Text(member.age ?? "no age")
                                            .font(.subheadline)
                                            .foregroundStyle(Color.yellow)
                                            .bold()
                                        Text(member.membershipType ?? "No Membership Type")
                                            .font(.subheadline)
                                            .foregroundStyle(Color.white)
                                        Text(member.number ?? "No Number")
                                            .font(.caption)
                                            .foregroundColor(.yellow)
                                            .bold()
                                    }
                                    .bold()
                                }
                                .frame(height: 100)
                                .id(member.id)
                                .listRowBackground(Color.black.opacity(0))
                                .shadow(radius: 5)
                                .onTapGesture (count: 2) {
                                            memberToEdit = member
                                        }
                                Divider()
                                    .frame(height: 10)
                                    .listRowBackground(Color.white.opacity(0.0))
                            }
                            .onDelete { indexSet in
                                if let index = indexSet.first {
                                    memberToDelete = filteredMembers[index]
                                    showDeleteAlert = true
                                }
                            }
                        }
                        .sheet(item: $memberToEdit) { member in
                            EditMemberSheet(viewModel: memberVM, member: member)
                        }
                        .scrollContentBackground(.hidden)
                        .transition(.slide)
                        .animation(.easeInOut(duration: 0.5), value: memberVM.members)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink("Member+") {
                        AddMemberSheet(viewModel: memberVM)
                    }
                    .foregroundStyle(Color.yellow)
                   
                }
            }
            .onAppear {
                memberVM.fetchMembers()
            }
            .navigationTitle("Members")
            .searchable(text: $searchText, placement: .automatic, prompt: "Search by Name, Age, or Type")
            .alert("Delete Member?", isPresented: $showDeleteAlert) {
                Button("Yes", role: .destructive) {
                    if let member = memberToDelete {
                        memberVM.deleteMember(member: member)
                    }
                    memberToDelete = nil
                }
                Button("No", role: .cancel) {
                    memberToDelete = nil
                }
            } message: {
                Text("Are you sure you want to delete this member?")
            }
        }
    }
}


#Preview {
    MemberView(context: PersistenceController.shared.container.viewContext)
}

// MARK: The sheet \ View for adding the members


struct AddMemberSheet: View {
    @ObservedObject var viewModel: MemberViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Image("muscule")
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

                    Section("Member Details") {
                        TextField("Name", text: $viewModel.name)
                        TextField("Phone Number", text: $viewModel.number)
                       TextField("Age", text: $viewModel.age)

                        Picker("Membership Type", selection: $viewModel.membershipType) {
                            ForEach(MembershipType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.segmented) 
                    }
                    .listRowBackground(Color.white.opacity(0.9))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Add Member")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.addMember()
                        dismiss()
                    }
                    .disabled(viewModel.isSaveButtonDisabled)
                    .bold()
                    .foregroundStyle(viewModel.isSaveButtonDisabled ? Color.red : Color.yellow)
                    .strikethrough(viewModel.isSaveButtonDisabled ? true : false, pattern: .solid)
                    .animation(.easeInOut(duration: 1.0), value: viewModel.isSaveButtonDisabled)
                }
            }
        }
    }
}

// MARK: The sheet \ View for editing the members
struct EditMemberSheet: View {
    @ObservedObject var viewModel: MemberViewModel
    @State var member: MemberEntity
    @Environment(\.dismiss) var dismiss

    @State private var name: String = ""
    @State private var age: String = ""
    @State private var membershipType: String = ""
    @State private var number: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var photoItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Personal Info")) {
                    TextField("Name", text: $name)
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                    TextField("Membership Type", text: $membershipType)
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
                    .onChange(of: photoItem) {_ , newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                selectedImage = uiImage
                            }
                        }
                    }
                }
            }
            .navigationTitle("Edit Member")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        member.name = name
                        member.age = age
                        member.membershipType = membershipType
                        member.number = number

                        if let image = selectedImage {
                            if let path = viewModel.saveImageToFileManager(image: image) {
                                member.profileImagePath = path
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
                name = member.name ?? ""
                age = member.age ?? ""
                membershipType = member.membershipType ?? ""
                number = member.number ?? ""
                if let path = member.profileImagePath,
                   let image = viewModel.loadImageFromFileManager(path: path) {
                    selectedImage = image
                }
            }
        }
    }
}
