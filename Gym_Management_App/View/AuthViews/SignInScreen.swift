import SwiftUI
import CoreData
struct SignInScreen: View {
    @Binding var isLoggedIn: Bool
    @StateObject private var viewModel: SignInViewmodel
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showError = false
    @State private var errorMessage = ""
    
    init(isLoggedIn: Binding<Bool>, context: NSManagedObjectContext) {
        self._isLoggedIn = isLoggedIn
        self._viewModel = StateObject(wrappedValue: SignInViewmodel(context: context))
    }
    
    var body: some View {
        ZStack {
            Image("signin")
                .resizable()
                .opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Text("Sign In")
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
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .foregroundStyle(Color.white)
                        .background(Color.blue)
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
                                    _ = try await viewModel.signIn()
                                    isLoggedIn = true
                                } catch {
                                    await MainActor.run {
                                        showError = true
                                        errorMessage = error.localizedDescription
                                    }
                                }
                            }
                        }
                }
                
                NavigationLink(
                    "Don't have an account? Sign Up",
                    destination: SignUpScreen( isLoggedIn: $isLoggedIn, context: viewContext)
                )
                .padding(.top, 20)
                .foregroundStyle(Color.white)
            }
            .padding(.horizontal)
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
}

#Preview {
    SignInScreen(isLoggedIn: .constant(false), context: PersistenceController.preview.container.viewContext)
}
