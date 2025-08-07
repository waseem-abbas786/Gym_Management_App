
import SwiftUI
import Firebase
@main
struct Gym_Management_AppApp: App {
    let persistenceController = PersistenceController.shared
    init () {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            NavigationStack {
              RootView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
           
        }
    }
}
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}
