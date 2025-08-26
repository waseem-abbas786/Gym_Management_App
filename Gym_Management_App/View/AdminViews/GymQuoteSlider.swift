//
//  GymQuoteSlider.swift
//  Gym_Management_App
//
//  Created by Waseem Abbas on 26/08/2025.
//

import SwiftUI
import Combine
struct GymQuoteSlider: View {
    let slides: [(quote: String, image: String)]
    @State private var currentIndex = 0
    
    
    let timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Image(slides[currentIndex].image)
                .resizable()
                .scaledToFill()
                .frame(height: 350)
                .clipped()
                .cornerRadius(22)
                .shadow(radius: 5)
                .transition(.opacity)
            Color.black.opacity(0.4)
                .cornerRadius(22)
            Text(slides[currentIndex].quote)
                .font(.headline)
                .foregroundColor(.yellow)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .transition(.opacity)
        }
        .padding(.top, 40)
        .frame(maxWidth: .infinity)
        .frame(height: 350)
        .listRowBackground(Color.clear)
        .onReceive(timer) { _ in
            withAnimation(.easeInOut) {
                currentIndex = currentIndex == 7 ? 0 : (currentIndex + 1)
            }
        }
    }
}

