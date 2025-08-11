
import Foundation
import CoreData
import FirebaseAuth
import UIKit
import _PhotosUI_SwiftUI
class AdminViewModel : ObservableObject, Identifiable {
    @Published var name: String = ""
    @Published var gymName: String = ""
    @Published var gymAddress: String = ""
    @Published var password: String = ""
    @Published var selectedPhoto: PhotosPickerItem?
    @Published var profileImage: UIImage?
    
    @Published var admins : [AdminEntity] = []

    private let context : NSManagedObjectContext
    
    init (context : NSManagedObjectContext) {
        self.context = context
        fetchAdmins()
    }

    func fetchAdmins () {
        let request : NSFetchRequest<AdminEntity> = AdminEntity.fetchRequest()
        do {
            admins = try context.fetch(request)
        } catch {
            print("Error Fetching admins : \(error)")
        }
    }
    
    func addAdmin() {
        let newAdmin = AdminEntity(context: context)
        newAdmin.id = UUID()
        newAdmin.name = name
        newAdmin.gymName = gymName
        newAdmin.gymAddress = gymAddress
        
        if let image = profileImage {
            let savedFileName = saveImageToFileManager(image: image)
            newAdmin.profileImagePath = savedFileName
            print("Saved image filename: \(savedFileName)")
        }
        
        do {
            try context.save()
            fetchAdmins()
        } catch  {
            print("Error saving Admin: \(error.localizedDescription)")
        }
    }


     func saveImageToFileManager(image: UIImage) -> String {
        let filename = UUID().uuidString + ".jpg"
        let url = getDocumentsDirectory().appendingPathComponent(filename)
        
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: url)
        }
        
        return filename
    }
    
    
    func loadImageFromFileManager(path: String) -> UIImage? {
        let url = getDocumentsDirectory().appendingPathComponent(path)
        if let data = try? Data(contentsOf: url) {
            return UIImage(data: data)
        }
        return nil
    }
    
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
     func resetForm() {
        name = ""
        gymName = ""
        gymAddress = ""
        password = ""
        selectedPhoto = nil
        profileImage = nil
    }
//    MARK: The user should only edit the admin no delete bcz if admin is deleted then why  we keep the data of memberes and trainers
//    func deleteAdmins(at offsets: IndexSet) {
//        offsets.forEach { index in
//            let admin = admins[index]
//            context.delete(admin)
//        }
//        do {
//            try context.save()
//            fetchAdmins()
//        } catch {
//            print("Failed to delete admin: \(error.localizedDescription)")
//        }
//    }
    var isSaveButtonDisabled: Bool {
          name.isEmpty || gymName.isEmpty || gymAddress.isEmpty || password.isEmpty
      }

    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
                fetchAdmins() // Refresh list after saving
                print("Context saved successfully.")
            } catch {
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

}
