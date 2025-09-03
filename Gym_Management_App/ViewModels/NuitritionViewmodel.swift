import Foundation

@MainActor
class NetworkManager: ObservableObject {
    @Published var nutrition: Nutrition?
    @Published var errorMessage: String?

    func fetchNutrition(for food: String, quantity: String = "") async {
        let queryText = quantity.isEmpty ? food : "\(quantity) \(food)"
        
        guard let url = URL(string: "https://api.api-ninjas.com/v1/nutrition?query=\(queryText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else {
            self.errorMessage = "Invalid URL"
            return
        }

        var request = URLRequest(url: url)
        request.setValue("6z26erwrHAbXcQz6oKEp9w==bVUNtl60QtvxCZx7", forHTTPHeaderField: "X-Api-Key")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let nutritionData = try JSONDecoder().decode([Nutrition].self, from: data)
            self.nutrition = nutritionData.first
            self.errorMessage = nil
        } catch {
            self.errorMessage = "Failed to fetch data: \(error.localizedDescription)"
            self.nutrition = nil
        }
    }
    func convertLbToGrams(_ lb: String) -> String? {
        guard let lbValue = Double(lb.replacingOccurrences(of: "lb", with: "").trimmingCharacters(in: .whitespaces)) else {
            return nil
        }
        let grams = lbValue * 453.592
        return "\(Int(grams))g" // Convert to integer grams for API
    }

}
