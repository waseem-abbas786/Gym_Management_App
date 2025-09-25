//
//  CoreMlViewModel.swift
//  Gym_Management_App
//
//  Created by Waseem Abbas on 25/09/2025.
//

import Foundation
import CoreML
import CoreData
struct MemberInput {
    var age: Int
    var weight: Double
    var height: Double
    var goal: String   // "weight_loss" or "weight_gain"
    var timeframe: Int
}

class CoreMlViewModel : ObservableObject {
    private let model : Diet_plan
    private let context : NSManagedObjectContext
    @Published var latestPlan : DietPlanEntity?
    
    init(context : NSManagedObjectContext) {
        self.context = context
        self.model = try! Diet_plan(configuration: .init())
    }
    
    func generatePlan (for input : MemberInput) {
        do {
            let prediction = try model.prediction(
                weight_kg: input.weight,
                height_cm: input.height,
                age: Int64(input.age),
                timeframe_weeks: Int64(input.timeframe),
                goal: input.goal
            )
            let dietPlan = prediction.diet_plan
            DispatchQueue.main.async {
                let newPlan = DietPlanEntity(context: self.context)
                newPlan.id = UUID()
                newPlan.dietPlan = dietPlan
                self.latestPlan = newPlan
            }
            do {
                try self.context.save()
                print("✅ Saved diet & workout plan")
            } catch {
                print("❌ Error saving Core Data: \(error.localizedDescription)")
             }
        } catch  {
            print("❌ Prediction error: \(error.localizedDescription)")
        }
    }
    func fetchPlans () -> [DietPlanEntity]{
        let request : NSFetchRequest<DietPlanEntity> = DietPlanEntity.fetchRequest()
        do {
            return try context.fetch(request)
        } catch  {
            print(error.localizedDescription)
            return []
        }
    }
}
