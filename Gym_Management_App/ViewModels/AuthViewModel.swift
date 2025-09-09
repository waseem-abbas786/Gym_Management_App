import Foundation
import FirebaseAuth
import Combine
import CoreData

struct AuthModel {
    let uid: String
    let email: String?
    let photoUrl: String?

    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
    }
}

@MainActor
class SignInViewmodel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var validationError: String? = nil
    @Published var isLoading: Bool = false

    private var cancellables = Set<AnyCancellable>()
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        setupValidation()
    }

    // MARK: - Validation
    private func setupValidation() {
        Publishers.CombineLatest($email, $password)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] email, password in
                self?.validationError = self?.validate(email: email, password: password)
            }
            .store(in: &cancellables)
    }

    private func validate(email: String, password: String) -> String? {
        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Email cannot be empty"
        }
        if !email.contains("@") {
            return "Email must contain '@'"
        }
        if password.count < 6 {
            return "Password must be at least 6 characters long"
        }
        if password.rangeOfCharacter(from: .uppercaseLetters) == nil {
            return "Password must have at least one capital letter"
        }
        if password.rangeOfCharacter(from: .symbols) == nil &&
            password.rangeOfCharacter(from: .punctuationCharacters) == nil {
            return "Password must have at least one symbol"
        }
        return nil
    }

    // MARK: - Auth Actions
    func getAuthenticatedUser() throws -> AuthModel? {
        guard let user = Auth.auth().currentUser else { return nil }
        return AuthModel(user: user)
    }

    func signOut() throws {
        try Auth.auth().signOut()
        clearCoreData() // Safe here because context is ready
    }

    func signIn() async throws -> AuthModel {
        if let error = validationError {
            throw NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: error])
        }

        isLoading = true
        defer { isLoading = false }

        let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
        let userModel = AuthModel(user: authResult.user)

        email = ""
        password = ""

        return userModel
    }

    func signUp() async throws -> AuthModel {
        if let error = validationError {
            throw NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: error])
        }

        try? Auth.auth().signOut() // Sign out previous user

        isLoading = true
        defer { isLoading = false }

        // ✅ Firebase signup only
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let userModel = AuthModel(user: authResult.user)

        // Clear local form
        email = ""
        password = ""

        return userModel
    }

    // MARK: - Core Data Clearing (for sign-out only)
    private func clearCoreData() {
        guard let _ = context.persistentStoreCoordinator else {
            print("Cannot clear Core Data: context has no persistent store coordinator")
            return
        }

        let entityNames = ["AdminEntity", "TrainerEntity", "MemberEntity"]

        for name in entityNames {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: name)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            deleteRequest.resultType = .resultTypeObjectIDs

            do {
                let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
                if let objectIDs = result?.result as? [NSManagedObjectID], !objectIDs.isEmpty {
                    let changes = [NSDeletedObjectsKey: objectIDs]
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
                }
            } catch {
                print("Failed to clear \(name): \(error)")
            }
        }
    }
}
