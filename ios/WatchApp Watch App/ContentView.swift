//
//  ContentView.swift
//  WatchApp Watch App
//
//  Created by Matti Kjellstadli on 01.10.2024.
//

import SwiftUI

struct ContentView: View {
    let exercises = [
        ("Running", "figure.run"),
        ("Cycling", "bicycle"),
        ("Swimming", "drop.fill"),
        ("Yoga", "figure.mind.and.body"),
        ("Strength Training", "dumbbell.fill")
    ]

    var body: some View {
        NavigationView {
            List(exercises, id: \.0) { exercise, icon in
                HStack {
                    Text(exercise)
                    Spacer()
                    Image(systemName: icon)
                        .imageScale(.medium)
                        .foregroundColor(.green)
                    
                    
                }
            }
            .navigationTitle("Exercises")
            .navigationBarTitleDisplayMode(.inline) // Shrinking title effect
            .listStyle(PlainListStyle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
}
