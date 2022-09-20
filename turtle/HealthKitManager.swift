//
//  HealthKitManager.swift
//  HealthKitTests
//
//  Created by João Victor Ipirajá de Alencar on 19/09/22.
//

import Foundation
import HealthKit

class HKSampleTypes {
    static var ToShare : Set<HKSampleType> {
      let waterType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryWater)!
      return [waterType]
    }

      static var ToGet : Set<HKSampleType> {
        let waterType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryWater)!
        let height = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!
        let weight = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!

        return [waterType, height, weight]
      }
}

class HKStoreManager {
    
    var healthStore = HKHealthStore()
    

    func createAuthRequest(completion: @escaping (Bool, Error?) -> Void){
        
        self.healthStore.requestAuthorization(toShare: HKSampleTypes.ToShare, read: HKSampleTypes.ToGet, completion: completion )

    }

    func addWaterAmountToHealthKit(ml: Double) {
        
      let quantityType = HKQuantityType.quantityType(forIdentifier: .dietaryWater)
      let quanitytUnit = HKUnit(from: "ml")
      let quantityAmount = HKQuantity(unit: quanitytUnit, doubleValue: ml)
      let now = Date()

      let sample = HKQuantitySample(type: quantityType!, quantity: quantityAmount, start: now, end: now)
      let correlationType = HKObjectType.correlationType(forIdentifier: HKCorrelationTypeIdentifier.food)
      let waterCorrelationForWaterAmount = HKCorrelation(type: correlationType!, start: now, end: now, objects: [sample])
  
        
      self.healthStore.save(waterCorrelationForWaterAmount, withCompletion: { (success, error) in
          print(success.description)
        if (error != nil) {
          NSLog("error occurred saving water data")
        }
      })
    }
    
    
    func getWeight(completion: @escaping (Double?, NSError?) -> ()){
        let type = HKSampleType.quantityType(forIdentifier: .bodyMass)!
        let agora = Date()
        let predicate = HKQuery.predicateForSamples(withStart: nil , end: agora)
        
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: 0, sortDescriptors: nil) { query, results, error in
            let unit = HKUnit(from: "kg")
            let pesoAtual = (results as! [HKQuantitySample]).last?.quantity.doubleValue(for: unit)
            completion(pesoAtual, error as NSError?)
        }
        
        self.healthStore.execute(query)
    }
    
    func getHeight(completion: @escaping (Double?, NSError?) -> ()){
        let type = HKSampleType.quantityType(forIdentifier: .height)!
        let agora = Date()
        let predicate = HKQuery.predicateForSamples(withStart: nil , end: agora)
        
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: 0, sortDescriptors: nil) { query, results, error in
            let unit = HKUnit(from: "cm")
            let alturaAtual = (results as! [HKQuantitySample]).last?.quantity.doubleValue(for: unit)
            completion(alturaAtual, error as NSError?)
        }
        
        self.healthStore.execute(query)
    }
    
 
func getRecords(completion: @escaping ([(Date, Double)], NSError?) -> ()){
    let type = HKSampleType.quantityType(forIdentifier: .dietaryWater)

    let meiaNoite: Date = Calendar.current.startOfDay(for: .now)
    let agora = Date()
    
    let predicate = HKQuery.predicateForSamples(withStart: meiaNoite , end: agora, options: [])

    let query = HKSampleQuery(sampleType: type!, predicate: predicate, limit: 0, sortDescriptors: nil) { query, results, error in
        let quanitytUnit = HKUnit(from: "ml")
        if let results = results {
            let resultsArray = (results as! [HKQuantitySample]).map {
                ($0.endDate,
                $0.quantity.doubleValue(for: quanitytUnit))}
            completion(resultsArray, error as NSError?)
        }
        completion([], error as NSError?)
    }

    self.healthStore.execute(query)
}
}
