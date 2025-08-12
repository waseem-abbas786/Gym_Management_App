//
//  MemberView.swift
//  Gym_Management_App
//
//  Created by Waseem Abbas on 10/08/2025.
//

import SwiftUI
import PhotosUI
import CoreData

enum PaymentFilter: String, CaseIterable {
    case all = "All"
    case paid = "Paid"
    case unpaid = "Unpaid"
}

struct MemberView: View {
    @State var searchText = ""
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var memberVM: MemberViewModel
    
    @State private var showDeleteAlert = false
    @State private var memberToDelete: MemberEntity?
    @State private var memberToEdit: MemberEntity? = nil
    @State private var memberToToggle: MemberEntity? = nil
    @State private var filter: PaymentFilter = .all
    @State private var showConfirmation: Bool = false
    
    init(context: NSManagedObjectContext) {
        self._memberVM = StateObject(wrappedValue: MemberViewModel(context: context))
    }
    
    var filteredMembers: [MemberEntity] {
        let baseList: [MemberEntity]
        
        if searchText.isEmpty {
            baseList = memberVM.members
        } else {
            baseList = memberVM.members.filter {
                ($0.name ?? "").localizedCaseInsensitiveContains(searchText) ||
                ($0.membershipType ?? "").localizedCaseInsensitiveContains(searchText) ||
                ($0.age ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
        
        switch filter {
        case .all:
            return baseList
        case .paid:
            return baseList.filter { $0.isPaid }
        case .unpaid:
            return baseList.filter { !$0.isPaid }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("muscule")
                    .resizable()
                    .padding(.top, 34)
                    .ignoresSafeArea(edges: .bottom)
                    .opacity(0.9)
                
                VStack {
                    Picker("Filter", selection: $filter) {
                        ForEach(PaymentFilter.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
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
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(filteredMembers, id: \.id) { member in
                                    VStack {
                                        HStack(alignment: .top, spacing: 12) {
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
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(member.name ?? "No Name")
                                                    .font(.headline)
                                                    .foregroundStyle(Color.white)
                                                Text(member.age ?? "No Age")
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
                                                Text(member.isPaid ? "Paid" : "Unpaid")
                                                    .font(.caption)
                                                    .foregroundColor(member.isPaid ? .green : .red)
                                            }
                                            
                                            Spacer()
                                            
                                            Button {
                                                memberToEdit = member
                                            } label: {
                                                Image(systemName: "pencil")
                                                    .foregroundColor(.yellow)
                                                    .padding(8)
                                                    .background(Circle().fill(Color.black.opacity(0.3)))
                                            }
                                            .buttonStyle(.plain)
                                            Button {
                                                    memberToDelete = member
                                                     showDeleteAlert = true
                                                     } label: {
                                                     Image(systemName: "trash")
                                                       .foregroundColor(.red)
                                                        .padding(8)
                                                        .background(Circle().fill(Color.black.opacity(0.3)))
                                                     }
                                                     .buttonStyle(.plain)
                                        }
                                        .onTapGesture(count: 2) {
                                            if member.isPaid {
                                                memberToToggle = member
                                                showConfirmation = true
                                            } else {
                                                memberVM.togglePaymentStatus(member: member)
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(Color.black.opacity(0.5))
                                    .cornerRadius(12)
                                    .shadow(radius: 5)
                                    .padding(.horizontal)
                                }
                                .onDelete { indexSet in
                                    if let index = indexSet.first {
                                        memberToDelete = filteredMembers[index]
                                        showDeleteAlert = true
                                    }
                                }
                            }
                            .padding(.top)
                        }
                        .sheet(item: $memberToEdit) { member in
                            EditMemberSheet(viewModel: memberVM, member: member)
                        }
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
                memberVM.resetPaymentStatusIfNeeded()
            }
            .navigationTitle("Members")
            .searchable(text: $searchText, placement: .automatic, prompt: "Search by Name, Age, or Type")
            .alert("Are you sure?", isPresented: $showConfirmation) {
                Button("Yes", role: .destructive) {
                    if let member = memberToToggle {
                        memberVM.togglePaymentStatus(member: member)
                    }
                    memberToToggle = nil
                }
                Button("No", role: .cancel) {
                    memberToToggle = nil
                }
            } message: {
                Text("Do you really want to mark this member as unpaid?")
            }
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
                            Text("Tap to add profile photo")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding()
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(12)
                        .shadow(radius: 4)

                        // Member Details Section
                        VStack(spacing: 16) {
                                 TextField("Name", text: $viewModel.name)
                                     .padding()
                                     .background(Color.white.opacity(0.9))
                                     .cornerRadius(8)
                                     .frame(width: 380)

                                 TextField("Phone Number", text: $viewModel.number)
                                     .keyboardType(.phonePad)
                                     .padding()
                                     .background(Color.white.opacity(0.9))
                                     .cornerRadius(8)
                                     .frame(width: 380)

                                 TextField("Age", text: $viewModel.age)
                                     .keyboardType(.numberPad)
                                     .padding()
                                     .background(Color.white.opacity(0.9))
                                     .cornerRadius(8)
                                     .frame(width: 380)

                                 Picker("Membership Type", selection: $viewModel.membershipType) {
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
                        Button(action: {
                            viewModel.addMember()
                            dismiss()
                        }) {
                            Text("Save Member")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(viewModel.isSaveButtonDisabled ? Color.gray : Color.yellow)
                                .foregroundColor(.black)
                                .cornerRadius(12)
                                .bold()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .disabled(viewModel.isSaveButtonDisabled)
                        .padding(.top, 10)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.isSaveButtonDisabled)
                    }
                    .padding()
                    .frame(width: 380)
                }
            }
            .navigationTitle("Add Member")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


// MARK: The sheet \ View for editing the members
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
                   let image = viewModel.loadImageFromFileManager(path: path) {
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
            if let path = viewModel.saveImageToFileManager(image: image) {
                member.profileImagePath = path
            }
        }

        viewModel.saveContext()
        dismiss()
    }
}
