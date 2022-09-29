//
//  Model.swift
//  turtle
//
//  Created by João Victor Ipirajá de Alencar on 26/09/22.
//

import Foundation

struct WidgetData: Codable{
    
    var waterGoal: Float = 0
    var waterDrank: Float = 0
    
    
    mutating func jsonToObject(data: Data, completion: (Error?) -> ()){
        
        do{
            let decoder = JSONDecoder()
            let decodedObject = try decoder.decode(WidgetData.self, from: data)
            self = decodedObject
            completion(nil)
        }catch{
            completion(error)
        }

    }
    func ToJson(completion: (Data?, Error?) -> ()){
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(self)
            completion(data, nil)
        } catch {
            completion(nil, error)
        }
    }
}
