
import Foundation
import _PhotosUI_SwiftUI
import CoreData
enum Speciality: String, CaseIterable, Identifiable {
    case strength = "Strength"
    case cardio = "Cardio"
    
    var id: String { self.rawValue }
}

class TrainerViewModel : ObservableObject {
    @Published var name : String = ""
    @Published var number : String = ""
    @Published var speciality : Speciality = .strength
    @Published var selectedPhoto : PhotosPickerItem?
    @Published var profileImage: UIImage?
    @Published var trainers : [TrainerEntity] = []
     
    private let context : NSManagedObjectContext
    init (context: NSManagedObjectContext) {
        self.context = context
    }
    func fetchTrainers () {
        let request : NSFetchRequest <TrainerEntity> = TrainerEntity.fetchRequest()
        do {
            trainers = try context.fetch(request)
        }
        catch {
            print("Error Fetching trainers?\(error)")
        }
    }
    
    func addTrainer () {
        let newTrainer = TrainerEntity(context: context)
        newTrainer.id = UUID()
        newTrainer.name = name
        newTrainer.number = number
        newTrainer.speciality = speciality.rawValue
        if let image = profileImage {
        let savedFileName = saveImageToFilemanager(image: image)
            newTrainer.profileImagePath = savedFileName
            print("Saved Image Filename: \(String(describing: savedFileName))")
        }
        do {
            try context.save()
            fetchTrainers()
            resetForm()
        }
        catch {
            print("Error saving Admin: \(error.localizedDescription)")
        }
    }
    func saveImageToFilemanager(image: UIImage) -> String? {
        let filename = UUID().uuidString + ".jpg"
        let url = getDocumentsDirectory().appendingPathComponent(filename)
        if let data = image.jpegData(compressionQuality: 0.8) {
            do {
                try data.write(to: url)
                return filename
            } catch {
                print("Error saving image: \(error.localizedDescription)")
                return nil
            }
        }
        return nil
    }

    func loadImageFromFileManager (path: String)-> UIImage? {
        let url = getDocumentsDirectory().appendingPathComponent(path)
        if let data =  try? Data(contentsOf: url) {
            return UIImage(data: data)
        }
        
        return nil
    }
    private func getDocumentsDirectory () -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    func deleteTrainer(trainer: TrainerEntity) {
        context.delete(trainer)
        do {
            try context.save()
            fetchTrainers()
        } catch {
            print("Error deleting trainer: \(error.localizedDescription)")
        }
    }

    func saveContext() {
        do {
            try context.save()
            fetchTrainers()
        } catch {
            print("Failed to save trainer: \(error.localizedDescription)")
        }
    }

    func resetForm() {
        name = ""
        number = ""
        speciality = .strength
        selectedPhoto = nil
        profileImage = nil
    }
    var isButtonvalid : Bool {
        name.isEmpty || number.isEmpty
    }

}

