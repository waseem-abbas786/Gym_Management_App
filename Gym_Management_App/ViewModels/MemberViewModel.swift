

import Foundation
import CoreData
import UIKit
import _PhotosUI_SwiftUI

enum MembershipType : String, Identifiable,CaseIterable {
    case basic = "Basic"
    case medium = "Medium"
    case premium = "Premium"
    case ultraPremium = "UltraPremium"
    var id: String { self.rawValue }
}
enum PaymentFilter: String, CaseIterable {
    case all = "All"
    case paid = "Paid"
    case unpaid = "Unpaid"
}

class MemberViewModel : ObservableObject {
    @Published var members : [MemberEntity] = []
    @Published var name : String = ""
    @Published var number : String = ""
    @Published var age : String = ""
    @Published var membershipType : MembershipType = .basic
    @Published var selectedPhoto: PhotosPickerItem?
    @Published var profileImage: UIImage?
    @Published var isPaid : Bool = false
    @Published var searchText = ""
    @Published var filter: PaymentFilter = .all
    var manager = ImageManager.instance
    
    var filteredMembers: [MemberEntity] {
        let baseList: [MemberEntity]
        
        if searchText.isEmpty {
            baseList = members
        } else {
            baseList = members.filter {
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
    
    
    private let context : NSManagedObjectContext
    init (context : NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchMembers () {
        guard context.persistentStoreCoordinator != nil else {
               print("Context not ready, skipping fetchmembers()")
               return
           }
        let request : NSFetchRequest<MemberEntity> = MemberEntity.fetchRequest()
        do {
           members = try context.fetch(request)
        }
        catch {
            print("Error fetching member from CoreData!")
        }
    }
    func addMember() {
        let newMember = MemberEntity(context: context)
        newMember.id = UUID()
        newMember.name = name
        newMember.number = number
        newMember.age = age
        newMember.membershipType = membershipType.rawValue
        newMember.isPaid = isPaid

        if let image = profileImage {
            let savedFileName = manager.saveImageToFileManager(image: image)
            newMember.profileImagePath = savedFileName
        }

        do {
            try context.save()
            fetchMembers()
            resetForm()
        } catch {
            print("Error saving member: \(error.localizedDescription)")
        }
    }

    func deleteMember(member: MemberEntity) {
        context.delete(member)
        do {
            try context.save()
            fetchMembers()
        } catch {
            print("Error deleting member: \(error.localizedDescription)")
        }
    }

    func resetForm() {
        name = ""
        number = ""
        membershipType = .basic
        profileImage = nil
        selectedPhoto = nil
    }
    func saveContext() {
        do {
            try context.save()
            fetchMembers() 
        } catch {
            print("Error saving context: \(error.localizedDescription)")
        }
    }
    func togglePaymentStatus(member: MemberEntity) {
        member.isPaid.toggle()
        saveContext()
    }
    var isSaveButtonDisabled: Bool {
        name.isEmpty || number.isEmpty
    }
//    MARK: THe rest func when the month change the payement status automatically chnage to Unpaid for all
    func resetPaymentStatusIfNeeded( ) {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let lastResetMonth = UserDefaults.standard.integer(forKey: "lastPaymentResetMonth")
        
        if currentMonth != lastResetMonth {
            let fetchRequest: NSFetchRequest<MemberEntity> = MemberEntity.fetchRequest()
            do {
                let members = try context.fetch(fetchRequest)
                for member in members {
                    member.isPaid = false
                }
                try context.save()
                UserDefaults.standard.set(currentMonth, forKey: "lastPaymentResetMonth")
            } catch {
                print("Error resetting payment status: \(error)")
            }
        }
    }
}


