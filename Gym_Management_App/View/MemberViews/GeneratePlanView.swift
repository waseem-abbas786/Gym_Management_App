//
//  GeneratePlanView.swift
//  Gym_Management_App
//
//  Created by Waseem Abbas on 25/09/2025.
//

import SwiftUI
import CoreData

struct GeneratePlanView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var viewModel : CoreMlViewModel
    @State private var age: String = ""
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var goal: String = "weight_loss"
    @State private var timeframe: String = ""
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: CoreMlViewModel(context: context))
    }
    
    var body: some View {
        NavigationStack {
            Group {
                TextField("Age", text: $age)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                
                TextField("Weight (kg)", text: $weight)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                
                TextField("Height (cm)", text: $height)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                
                Picker("Goal", selection: $goal) {
                    Text("Weight Loss").tag("weight_loss")
                    Text("Weight Gain").tag("weight_gain")
                }
                .pickerStyle(SegmentedPickerStyle())
                
                TextField("Timeframe (weeks)", text: $timeframe)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
            }
            Button(action: {
                                    if let ageInt = Int(age),
                                       let weightDouble = Double(weight),
                                       let heightDouble = Double(height),
                                       let timeframeInt = Int(timeframe) {
                                        
                                        let input = MemberInput(
                                            age: ageInt,
                                            weight: weightDouble,
                                            height: heightDouble,
                                            goal: goal,
                                            timeframe: timeframeInt
                                        )
                                        
                                        viewModel.generatePlan(for: input)
                                    }
                                }) {
                                    Text("Generate Plan")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.blue)
                                        .cornerRadius(12)
                                }
                                .padding(.vertical)
            if let plan = viewModel.latestPlan {
                VStack(alignment: .leading, spacing: 16) {
                    Text("🍽 Diet Plan")
                        .font(.headline)
                    TextEditor(text: .constant(plan.dietPlan ?? ""))
                        .frame(height: 120)
                        .padding(6)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .disabled(true)
                }
            }
            }
        }
    }
        #Preview {
            GeneratePlanView(context: PersistenceController.shared.container.viewContext)
        }
  
