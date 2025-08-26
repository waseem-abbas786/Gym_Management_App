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
    var manager = ImageManager.instance
    
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




