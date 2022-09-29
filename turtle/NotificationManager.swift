//
//  NotificationManager.swift
//  turtle
//
//  Created by João Victor Ipirajá de Alencar on 25/09/22.
//

import UserNotifications


class NotificationManager{
    
    static let instance = NotificationManager()
    let UNCurrentCenter = UNUserNotificationCenter.current()

    
    func requestAuthorization(){
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { sucess, error in
            if let error = error{
                print(error)
            }else{
                print("Sucess")
            }
        }
    }
    
    func removeAllNotifications(){
        self.UNCurrentCenter.removeAllPendingNotificationRequests()

    }
 
    
      func scheduleNotification(){
        
        
        let content = UNMutableNotificationContent()
        content.title = "Beber Água"
        content.subtitle = "Falta pouco para você alcançar sua meta"
        content.sound = .default
        
          let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 11*60.0, repeats: true)

        let request = UNNotificationRequest(
            identifier: UUID().uuidString, content: content, trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
        getNotications()
       
    }
    
    func getNotications() {
        UNCurrentCenter.getPendingNotificationRequests(completionHandler: { [unowned self] requests in
            
             print(requests)

        })
    }
    
   
    
}
