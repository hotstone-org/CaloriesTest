//
//  CaloriesPredictorApp.swift
//  CaloriesPredictor
//
//  Created by Matt Hotstone on 9/5/2024.
//

import SwiftUI

@main
struct CaloriesPredictorApp: App {
    @StateObject private var energyBurntManager = EnergyBurntManager()
    
    var body: some Scene {
        WindowGroup {
            DailyEnergyBurntView(energyBurntManager: energyBurntManager)
        }
    }
}
