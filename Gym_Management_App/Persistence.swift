import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)

        let viewContext = controller.container.viewContext

        // Sample Admin
        let sampleAdmin = AdminEntity(context: viewContext)
        sampleAdmin.id = UUID()
        sampleAdmin.name = "Preview Admin"
        sampleAdmin.gymName = "Preview Gym"
        sampleAdmin.gymAddress = "123 Preview Street"
        sampleAdmin.profileImagePath = nil
        
        let sampleTrainer = TrainerEntity(context: viewContext)
        sampleTrainer.id = UUID()
        sampleTrainer.name = "Preview Trainer"
        sampleTrainer.number = "030383"
        sampleTrainer.speciality = "Strength"
        sampleTrainer.profileImagePath = nil
        
        let sampleMember = MemberEntity(context: viewContext)
        sampleMember.id = UUID()
        sampleMember.name = "no Name"
        sampleMember.membershipType = "simple"
        sampleMember.number = "83458934"
        sampleMember.age = "no age"
        sampleMember.profileImagePath = nil

        do {
            try viewContext.save()
        } catch {
            fatalError("Failed to create preview data: \(error)")
        }

        return controller
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Gym_Management_App")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved Core Data error: \(error), \(error.userInfo)")
            }
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
