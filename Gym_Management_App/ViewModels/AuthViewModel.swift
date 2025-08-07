import Foundation
import FirebaseAuth

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
