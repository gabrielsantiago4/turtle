//
//  My_Widget.swift
//  My Widget
//
//  Created by João Victor Ipirajá de Alencar on 26/09/22.
//

import WidgetKit
import SwiftUI
import Intents


struct WaterEntry: TimelineEntry{
    var date:Date
    var data: WidgetData
}


struct Provider: TimelineProvider{
  
    
    func getRecordsFromUserDefaults() -> Data?{
        return UserDefaults(suiteName: "group.br.com.turtle")?.value(forKey: "records") as? Data
    }
    
    func placeholder(in context: Context) -> WaterEntry {
        let date = Date()
        return WaterEntry(date: date, data: WidgetData())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WaterEntry) -> Void) {
        let date = Date()
        
        if context.isPreview{
            let entry =  WaterEntry(date: date, data: WidgetData(waterGoal: 3, waterDrank: 0))
            completion(entry)
        }else{
            
            if let jsonData = getRecordsFromUserDefaults(){
                var widgetData = WidgetData()
                widgetData.jsonToObject(data: jsonData) { _ in }
                let entry = WaterEntry(date:date, data: widgetData)
                completion(entry)
            }
        }
        
        
        
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WaterEntry>) -> Void){
       
        if let jsonData = getRecordsFromUserDefaults(){
            let date = Date()
            var widgetData = WidgetData()
            widgetData.jsonToObject(data: jsonData) { _ in }
            let entry = WaterEntry(date:date, data: widgetData)
            completion(Timeline(entries: [entry], policy: .never))
            
        }
        
   }
    
 
    typealias Entry = WaterEntry
    
}





struct SmallWidget: View{
    let entry: Provider.Entry

    var body: some View{
        ZStack{
            
            Color(uiColor: UIColor(named: "gradientColor2")!).ignoresSafeArea()
            
            HStack(alignment:.bottom){
                 
                    VStack(alignment: .leading){
                       
                        Text( String(format: "%.2f L", self.entry.data.waterDrank / 1000)).font(.custom("Quantico-Bold", size: 30))
                        Text("Bebidos 💧").font(.custom("Quantico-Regular", size: 20))
                     
                        
                        if (self.entry.data.waterDrank <= entry.data.waterGoal){
                            Divider()
                            Text(String(format: "Falta %.2f L ",entry.data.waterGoal/1000 - entry.data.waterDrank/1000)).font(.custom("Quantico-Regular", size: 17))
                        }
                        
                    }.foregroundColor( .white).shadow(radius: 5)
                }.padding()
                
        }
    }
}

struct MediumWidget: View{
    let entry: Provider.Entry

    var body: some View{
        ZStack{
            
            Color(uiColor: UIColor(named: "gradientColor2")!).ignoresSafeArea()
            
            HStack(){
                 
                    VStack(alignment: .leading){
                        Spacer()
                        Text("💧")
                        Text( String(format: "%.2f L", self.entry.data.waterDrank / 1000)).font(.custom("Quantico-Bold", size: 30))
                        Text("Bebidos").font(.custom("Quantico-Regular", size: 20))
                     
                        
                     
                    }.shadow(radius: 5).padding()
                
                Spacer()
                
                if (self.entry.data.waterDrank <= entry.data.waterGoal){
                    VStack(alignment:.trailing){
                        Text("Falta")
                        Text(String(format: "%.2f L",entry.data.waterGoal/1000 - entry.data.waterDrank/1000)).font(.custom("Quantico-Regular", size: 17))
                        Spacer()
                    }.shadow(radius: 5).padding()
                   
                }
                
                
                
            }.foregroundColor( .white).padding()
                
        }    }
}

struct AccessoryCircularWidget: View{
    let entry: Provider.Entry

    var body: some View{
        let percentage = entry.data.waterDrank / entry.data.waterGoal
        Gauge(value: percentage) {
            Text("💧")
        }.gaugeStyle(.accessoryCircularCapacity)
    }
}

struct AccessoryRectWidget: View{
    let entry: Provider.Entry

    var body: some View{
        
        HStack{
           
            
            VStack(alignment:.leading){
                Text("Você bebeu").font(.system(size: 15, weight: .bold))
                Text( String(format: "%.2f L", self.entry.data.waterDrank / 1000)).font(.system(size: 25))
            }
            Text("🐢").font(.system(size: 30))
        }
        
    }
}


struct WidgetEntyView: View{
    

    let entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    

    var body: some View{
        
        if self.family == .systemSmall{
            SmallWidget(entry: entry)
        }else if self.family == .systemMedium{
            MediumWidget(entry: entry)
        }else if self.family ==  .accessoryCircular{
            AccessoryCircularWidget(entry: entry)
        }else if self.family == .accessoryRectangular{
            AccessoryRectWidget(entry: entry)
        }

    }
}


@main
struct WaterWidget: Widget{
    private let kind = "WaterWidget"
    
    var body: some WidgetConfiguration {
        
        StaticConfiguration(kind: kind,
                            provider: Provider()
        ) { entry in
            WidgetEntyView(entry: entry)
        }
        .configurationDisplayName("Water Widget")
        .description("See your Water Goal")
        .supportedFamilies([.systemSmall,  .systemMedium, .accessoryCircular, .accessoryRectangular])
    }
    
}
