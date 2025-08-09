
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
//    MARK: fetch data from Coredata
    func fetchAdmins () {
        let request : NSFetchRequest<AdminEntity> = AdminEntity.fetchRequest()
        do {
            admins = try context.fetch(request)
        } catch {
            print("Error Fetching admins : \(error)")
        }
    }
//    MARK: func to add a new admin
    func addAdmin() {
        let newAdmin = AdminEntity(context: context)
        newAdmin.id = UUID()
        newAdmin.name = name
        newAdmin.gymName = gymName
        newAdmin.gymAddress = gymAddress
        
        // Save image and store path
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

//    MARK: save Image to filemanager
    private func saveImageToFileManager(image: UIImage) -> String {
        let filename = UUID().uuidString + ".jpg"
        let url = getDocumentsDirectory().appendingPathComponent(filename)
        
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: url)
        }
        
        return filename
    }
    
    // MARK: - Load Image from FileManager
    func loadImageFromFileManager(path: String) -> UIImage? {
        let url = getDocumentsDirectory().appendingPathComponent(path)
        if let data = try? Data(contentsOf: url) {
            return UIImage(data: data)
        }
        return nil
    }
    
    // MARK: - Get Documents Directory
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
    func deleteAdmins(at offsets: IndexSet) {
        offsets.forEach { index in
            let admin = admins[index]
            context.delete(admin)
        }
        do {
            try context.save()
            fetchAdmins()
        } catch {
            print("Failed to delete admin: \(error.localizedDescription)")
        }
    }
    var isSaveButtonDisabled: Bool {
          name.isEmpty || gymName.isEmpty || gymAddress.isEmpty || password.isEmpty
      }

   
}
