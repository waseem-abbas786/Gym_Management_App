//
//  DetailView.swift
//  Gym_Management_App
//
//  Created by Waseem Abbas on 25/09/2025.
//

import SwiftUI
struct DetailView : View {
    @Environment(\.managedObjectContext) private var context
    @StateObject var viewModel : CoreMlViewModel
    @State var isSheetOn : Bool = false
    let member : MemberEntity
    var body: some View {
        NavigationStack {
            ZStack {
                Image("muscule")
                    .resizable()
                    .padding(.top, 34)
                    .ignoresSafeArea(edges: .bottom)
                    .opacity(0.9)
                Spacer()
                VStack {
                    Text("The age of \(member.name ?? "") is \(member.age ?? "No Age")")
                        .font(.subheadline)
                        .foregroundStyle(Color.yellow)
                        .bold()
                    Text("The membershipType of  \(member.name ?? "") Is \(member.membershipType ?? "No Membership Type")")
                        .font(.subheadline)
                        .foregroundStyle(Color.white)
                    Text("The Phone Number of \(member.name ?? "") is \(member.number ?? "No Number")")
                        .font(.caption)
                        .foregroundColor(.yellow)
                        .bold()
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.8))
                Spacer()
                VStack {
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
            .navigationTitle("\(member.name ?? "") Info")
            .sheet(isPresented: $isSheetOn) {
                GeneratePlanView(context: context)
            }
        }
 
     }
}



//
//#Preview {
//    DetailView()
//}
