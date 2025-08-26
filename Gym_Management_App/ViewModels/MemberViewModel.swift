

import Foundation
enum MembershipType : String, Identifiable,CaseIterable {
    case basic = "Basic"
    case medium = "Medium"
    case premium = "Premium"
    case ultraPremium = "UltraPremium"
    var id: String { self.rawValue }
}
import CoreData
import UIKit
import _PhotosUI_SwiftUI

class MemberViewModel : ObservableObject {
    @Published var members : [MemberEntity] = []
    @Published var name : String = ""
    @Published var number : String = ""
    @Published var age : String = ""
    @Published var membershipType : MembershipType = .basic
    @Published var selectedPhoto: PhotosPickerItem?
    @Published var profileImage: UIImage?
    @Published var isPaid : Bool = false
    var manager = ImageManager.instance
    
    private let context : NSManagedObjectContext
    init (context : NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchMembers () {
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


