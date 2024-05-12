//
//  EnergyBurnManager.swift
//  CaloriesPredictor
//
//  Created by Matt Hotstone on 11/5/2024.
//

import HealthKit
import Foundation

class EnergyBurntManager: ObservableObject {
    @Published var restingCalories = 0
    @Published var activeCalories = 0
    @Published var totalCalories = 0
    
    var internalRestingCalories = 0
    
    var healthStore = HKHealthStore()
    
    init() {
        requestAuthorization()
    }
    
    func requestAuthorization() {
        // this is the type of data we will be reading from Health (e.g stepCount)
        let toReads = Set([HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                           HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)!
                          ])
        guard HKHealthStore.isHealthDataAvailable() else {
            print("health data not available!")
            return
        }
        
        // asking User's permission for their Health Data
        // note: toShare is set to nil since I'm not updating any data
        healthStore.requestAuthorization(toShare: nil, read: toReads) {
            success, error in
            if success {
            } else {
                print("\(String(describing: error))")
            }
        }
    }
    
    func updateData() {
        print("Updating calorie data")
        let activeEnergyType = HKQuantityType(.activeEnergyBurned)
        let restingEnergyType = HKQuantityType(.basalEnergyBurned)
        
        let now = Date()
        let startDate = Calendar.current.startOfDay(for: now).addingTimeInterval(-3600*24)
        let endDate = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        print("Getting calories after \(startDate)")
        
        let sortByDate = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        let activeQuery = HKSampleQuery(sampleType: activeEnergyType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortByDate]) { _,
            results, _ in
            guard let samples = results as? [HKQuantitySample], let _ = samples.first else {
                print("No calorie data found")
                DispatchQueue.main.async {
                    self.activeCalories = 0
                    self.totalCalories = self.activeCalories + self.restingCalories
                }
                return
            }
            print("Retrieved \(samples.count) samples")
            let totalCalories = samples.reduce(0.0) { $0 + $1.quantity.doubleValue(for: HKUnit.kilocalorie())}
            print("Retrieved \(totalCalories) calories")
            DispatchQueue.main.async {
                self.activeCalories = Int(totalCalories)
                self.totalCalories = self.activeCalories + self.restingCalories
            }
        }
        
        let restingQuery = HKSampleQuery(sampleType: restingEnergyType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortByDate]) { _,
            results, _ in
            guard let samples = results as? [HKQuantitySample], let _ = samples.first else {
                print("No calorie data found")
                DispatchQueue.main.async {
                    self.restingCalories = 0
                    self.totalCalories = self.activeCalories + self.restingCalories
                }
                return
            }
            
            let totalCalories = samples.reduce(0.0) { $0 + $1.quantity.doubleValue(for: HKUnit.kilocalorie())}
            print("Retrieved \(totalCalories) calories")
            DispatchQueue.main.async {
                self.restingCalories = Int(totalCalories)
                self.totalCalories = self.activeCalories + self.restingCalories
            }
        }
        
        healthStore.execute(activeQuery)
        healthStore.execute(restingQuery)
    }
}
