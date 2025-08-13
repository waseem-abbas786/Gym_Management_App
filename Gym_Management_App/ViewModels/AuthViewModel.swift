import Foundation
import FirebaseAuth
import Combine

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

class SignInViewmodel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    
    @Published var validationError: String? = nil
    
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupValidation()
    }
    
    private func setupValidation() {
        Publishers.CombineLatest($email, $password)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] email, password in
                self?.validationError = self?.validate(email: email, password: password)
            }
            .store(in: &cancellables)
    }
    
    private func validate(email: String, password: String) -> String? {
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
    
    func getAuthenticatedUser() throws -> AuthModel? {
        if let user = Auth.auth().currentUser {
            return AuthModel(user: user)
        } else {
            return nil
        }
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func signIn(email: String, password: String) async throws -> AuthModel {
        let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthModel(user: authResult.user)
    }

    func signUp(email: String, password: String) async throws -> AuthModel {
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthModel(user: authResult.user)
    }
}
