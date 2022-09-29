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
        let weight = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!

        return [waterType, weight]
      }
}

struct HKWaterRecord{
    var id: String
    var recordDate: Date
    var sizeML: Double
    var syncVersion: Int
}

class HKStoreManager {
    
    var healthStore = HKHealthStore()
    

    func createAuthRequest(completion: @escaping (Bool, Error?) -> Void){
        
        self.healthStore.requestAuthorization(toShare: HKSampleTypes.ToShare, read: HKSampleTypes.ToGet, completion: completion )

    }

    func addWaterAmountToHealthKit(ml: Double, completion: @escaping (HKWaterRecord, Error?) -> Void) {
        
        
        let now = Date()
        let id = UUID().uuidString
        var meta = [String: Any]()
        
        meta[HKMetadataKeySyncVersion] = 1
        meta[HKMetadataKeySyncIdentifier] = id
        
        let quantityType = HKQuantityType.quantityType(forIdentifier: .dietaryWater)
        let quanitytUnit = HKUnit(from: "ml")
        let quantityAmount = HKQuantity(unit: quanitytUnit, doubleValue: ml)
      
        let sample = HKQuantitySample(type: quantityType!, quantity: quantityAmount, start: now, end: now, metadata: meta)
        
        let correlationType = HKObjectType.correlationType(forIdentifier: HKCorrelationTypeIdentifier.food)
        let waterCorrelationForWaterAmount = HKCorrelation(type: correlationType!, start: now, end: now, objects: [sample])
        
        let record = HKWaterRecord(id: id, recordDate: now, sizeML: ml, syncVersion: 1)
        
        self.healthStore.save(waterCorrelationForWaterAmount) { response, error in
            completion(record, error)
        }
    }
    
    

    func deleteRecord( registro: HKWaterRecord, completion: @escaping (Bool, Int, Error?) -> Void){
        
        let identifier = registro.id
        
        let predicate = HKQuery.predicateForObjects(withMetadataKey: HKMetadataKeySyncIdentifier, allowedValues: [identifier])
        
        let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryWater)
        
        healthStore.deleteObjects(of: type!, predicate: predicate, withCompletion: completion)
        
        
    }
    
    func getWeight(completion: @escaping (Double?, NSError?) -> ()){
        let type = HKSampleType.quantityType(forIdentifier: .bodyMass)!
        
        let agora = Date()
        
        let predicate = HKQuery.predicateForSamples(withStart: nil , end: agora)
        
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: 0, sortDescriptors: nil) { query, results, error in
            if let results = results{
                let unit = HKUnit(from: "kg")
                let pesoAtual = (results as! [HKQuantitySample]).last?.quantity.doubleValue(for: unit)
                completion(pesoAtual, error as NSError?)
                
            }else{
                completion(nil, error as NSError?)
            }
           
            
        }
        
        self.healthStore.execute(query)
    }
    
    func getHeight(completion: @escaping (Double, NSError?) -> ()){
        
        let type = HKSampleType.quantityType(forIdentifier: .height)!
        let agora = Date()
        
        let predicate = HKQuery.predicateForSamples(withStart: nil , end: agora)
        
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: 0, sortDescriptors: nil) { query, results, error in
           
            
            if let results =  results as? [HKQuantitySample]{
            let unit = HKUnit(from: "cm")
            
            let alturaAtual = results.last?.quantity.doubleValue(for: unit)
                
                completion(alturaAtual ?? 0, error as NSError?)
                
            }else{
                completion(0, error as NSError?)
            }
            
        }
        
        self.healthStore.execute(query)
    }
    
 
    func getRecords(completion: @escaping ([HKWaterRecord], NSError?) -> ()){
    let type = HKSampleType.quantityType(forIdentifier: .dietaryWater)

    let meiaNoite: Date = Calendar.current.startOfDay(for: .now)
    let agora = Date()
    
    let predicate = HKQuery.predicateForSamples(withStart: meiaNoite , end: agora, options: [])

    let query = HKSampleQuery(sampleType: type!, predicate: predicate, limit: 0, sortDescriptors: nil) { query, results, error in
        let quanitytUnit = HKUnit(from: "ml")
        if let results = results {
            let resultsArray = (results as! [HKQuantitySample]).map {
                    
                HKWaterRecord(id: $0.metadata?["HKMetadataKeySyncIdentifier"] as! String, recordDate: $0.endDate, sizeML:  $0.quantity.doubleValue(for: quanitytUnit), syncVersion: $0.metadata?["HKMetadataKeySyncVersion"] as! Int)
                
            }
            completion(resultsArray, error as NSError?)
        }else{
            completion([], error as NSError?)
        }
        
    }

    self.healthStore.execute(query)
}
}
