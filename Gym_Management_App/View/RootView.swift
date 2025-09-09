import SwiftUI
import FirebaseAuth

struct RootView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @StateObject private var viewModel: SignInViewmodel
    @State private var isLoggedIn = false

    // store the listener handle so we can remove it later
    @State private var authHandle: AuthStateDidChangeListenerHandle?

    init() {
        let context = PersistenceController.shared.container.viewContext
        _viewModel = StateObject(wrappedValue: SignInViewmodel(context: context))
    }

    var body: some View {
        ZStack {
            if isLoggedIn {
                AdminView(isLoggedIn: $isLoggedIn, context: viewContext)
            } else {
                NavigationStack {
                    SignInScreen(isLoggedIn: $isLoggedIn, context: viewContext)
                }
            }
        }
        .onAppear {
            setupAuthListener()
        }
        .onDisappear {
            removeAuthListener()
        }
    }

    private func setupAuthListener() {
        authHandle = Auth.auth().addStateDidChangeListener { _, user in
            withAnimation {
                isLoggedIn = (user != nil)
            }
        }
    }

    private func removeAuthListener() {
        if let handle = authHandle {
            Auth.auth().removeStateDidChangeListener(handle)
            authHandle = nil
        }
    }
}

#Preview {
    RootView()
}
