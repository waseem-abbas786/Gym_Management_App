import SwiftUI

struct NutritionView: View {
    @StateObject private var networkManager = NetworkManager()
    @State private var foodInput: String = ""
    @State private var quantityInput: String = ""
    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 10), count: 2)

    var body: some View {
            VStack {
                TextField("Enter food item", text: $foodInput)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)

                TextField("Quantity (e.g., 1lb)", text: $quantityInput)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)

                Button("Get Nutrition Info") {
                    Task {
                        var quantityToSend = quantityInput.trimmingCharacters(in: .whitespaces)
                        if quantityToSend.lowercased().contains("lb") {
                            if let grams = networkManager.convertLbToGrams(quantityToSend) {
                                quantityToSend = grams
                            }
                        }
                        await networkManager.fetchNutrition(for: foodInput, quantity: quantityToSend)
                    }
                }
                .buttonStyle(.borderedProminent)
                    ScrollView {
                        if let nutrition = networkManager.nutrition {
                            LazyVGrid(columns: columns, spacing: 10) {
                                NutrientCard(title: "Total Fat", value: "\(nutrition.fat_total_g) g")
                                NutrientCard(title: "Saturated Fat", value: "\(nutrition.fat_saturated_g) g")
                                NutrientCard(title: "Sodium", value: "\(nutrition.sodium_mg) mg")
                                NutrientCard(title: "Potassium", value: "\(nutrition.potassium_mg) mg")
                                NutrientCard(title: "Cholesterol", value: "\(nutrition.cholesterol_mg) mg")
                                NutrientCard(title: "Total Carbs", value: "\(nutrition.carbohydrates_total_g) g")
                                NutrientCard(title: "Fiber", value: "\(nutrition.fiber_g) g")
                                NutrientCard(title: "Sugar", value: "\(nutrition.sugar_g) g")
                            }
                            .padding()
                        } else if let error = networkManager.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                        else {
                            VStack(spacing: 12) {
                                                   Image(systemName: "leaf.circle.fill")
                                                       .resizable()
                                                       .scaledToFit()
                                                       .frame(width: 80, height: 80)
                                                       .foregroundColor(.green.opacity(0.8))

                                                   Text("Welcome to Nutrition Calculator")
                                                       .font(.title3)
                                                       .fontWeight(.semibold)

                                                   Text("Enter a food item and quantity above to see its nutrition details.")
                                                       .font(.subheadline)
                                                       .foregroundColor(.secondary)
                                                       .multilineTextAlignment(.center)
                                                       .padding(.horizontal, 20)
                                               }
                                        .padding(.top, 40)
                        }
                    }
                }
            .navigationTitle("Nutrition Calculator")
                .padding()
            }
       
        }

#Preview {
    NavigationStack {
        NutritionView()
    }
}
struct NutrientCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Text(value)
                .font(.headline)
                .bold()
                .foregroundColor(.primary)
        }
        .frame(width: 150, height: 100)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
    }
}
