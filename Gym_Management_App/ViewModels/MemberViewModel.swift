

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

        if let image = profileImage {
            let savedFileName = saveImageToFileManager(image: image)
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

        func saveImageToFileManager(image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let filename = UUID().uuidString + ".jpg"
        let url = getDocumentsDirectory().appendingPathComponent(filename)

        do {
            try data.write(to: url)
            return filename
        } catch {
            print("Error saving image: \(error.localizedDescription)")
            return nil
        }
    }

    func loadImageFromFileManager(path: String) -> UIImage? {
        let url = getDocumentsDirectory().appendingPathComponent(path)
        return UIImage(contentsOfFile: url.path)
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    var isSaveButtonDisabled: Bool {
        name.isEmpty || number.isEmpty
    }
}


