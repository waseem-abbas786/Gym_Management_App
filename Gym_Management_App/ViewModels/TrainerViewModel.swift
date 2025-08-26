
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
    var manager = ImageManager.instance
     
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
            let savedFileName = manager.saveImageToFileManager(image: image)
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

