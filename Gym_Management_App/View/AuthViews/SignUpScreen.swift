import SwiftUI
import CoreData

struct SignUpScreen: View {
    @Binding var isLoggedIn: Bool
    @StateObject private var viewModel: SignInViewmodel
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showError = false
    @State private var navigateToAdmin = false
    @State private var errorMessage = ""

    init(isLoggedIn: Binding<Bool>, context: NSManagedObjectContext) {
        self._isLoggedIn = isLoggedIn
        self._viewModel = StateObject(wrappedValue: SignInViewmodel(context: context))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Image("signin")
                    .resizable()
                    .opacity(0.9)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    Text("Sign Up")
                        .font(.largeTitle)
                        .foregroundStyle(Color.white)
                    Divider()

                    TextField("Email", text: $viewModel.email)
                        .padding()
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .clipShape(.buttonBorder)
                        .padding(.horizontal)

                    SecureField("Password", text: $viewModel.password)
                        .padding()
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .clipShape(.buttonBorder)
                        .padding(.horizontal)

                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    } else {
                        Text("Sign Up")
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .foregroundStyle(Color.white)
                            .background(Color.green)
                            .clipShape(.buttonBorder)
                            .shadow(color: .white, radius: 10, y: 10)
                            .padding()
                            .onTapGesture {
                                if let error = viewModel.validationError {
                                    errorMessage = error
                                    showError = true
                                    return
                                }

                                Task {
                                    do {
                                        // ✅ Firebase signup only
                                        _ = try await viewModel.signUp()

                                        // Clear form and trigger navigation safely
                                        await MainActor.run {
                                            viewModel.email = ""
                                            viewModel.password = ""
                                            isLoggedIn = true
                                            navigateToAdmin = true
                                        }
                                    } catch {
                                        await MainActor.run {
                                            showError = true
                                            errorMessage = error.localizedDescription
                                        }
                                    }
                                }
                            }
                    }
                }
                .padding(.horizontal)
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            // ✅ Navigation occurs only after signup, context is safe
            .navigationDestination(isPresented: $navigateToAdmin) {
                AdminView(isLoggedIn: $isLoggedIn, context: viewContext)
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }
}

#Preview {
    SignUpScreen(
        isLoggedIn: .constant(false),
        context: PersistenceController.shared.container.viewContext
    )
}
