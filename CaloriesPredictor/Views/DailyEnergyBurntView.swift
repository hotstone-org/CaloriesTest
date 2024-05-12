//
//  DailyEnergyBurnView.swift
//  CaloriesPredictor
//
//  Created by Matt Hotstone on 9/5/2024.
//

import SwiftUI

struct DailyEnergyBurntView: View {
    @ObservedObject var energyBurntManager: EnergyBurntManager
    
    var body: some View {
        VStack{
            List {
                Section(header: Text("Calories"))
                {
                    HStack {
                        Label("Resting", systemImage: "person")
                        Spacer()
                        Text("\(energyBurntManager.restingCalories)")
                    }
                    .fontWeight(.light)
                    HStack {
                        Label("Active", systemImage: "person")
                        Spacer()
                        Text("\(energyBurntManager.activeCalories)")
                    }
                    .fontWeight(.light)
                    HStack {
                        Label("Total", systemImage: "person")
                        Spacer()
                        Text("\(energyBurntManager.totalCalories)")
                    }.fontWeight(.medium)
                }
            }
            Spacer()
            Button(action:  {
                Task {
                   await energyBurntManager.updateData()
                }
            }) {
                Text("Update")
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    DailyEnergyBurntView(energyBurntManager: EnergyBurntManager())
}
