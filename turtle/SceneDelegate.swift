//
//  SceneDelegate.swift
//  turtle
//
//  Created by Gabriel Santiago on 15/09/22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var healthKitStore: HKStoreManager = HKStoreManager()
    var notification = NotificationManager()
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = ViewController() // Your initial view controller.
        window.makeKeyAndVisible()
        self.window = window
        
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        
        
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        // SceneDelegate.shared?.window?.rootViewController.records
        
        notification.removeAllNotifications()

        let rootVC = self.window?.rootViewController as? ViewController
        
        healthKitStore.getRecords { records, error in
            
            if let error = error{
                print("error")
            }else{
                rootVC?.records = records
            }
            
        }
        

        
        healthKitStore.getWeight { peso, error  in
            if let _ = error{
                
            }else{
                if let peso = peso{
                    rootVC?.goalInML = Float(peso * 35)
                    
                }else{
                    rootVC?.goalInML = 3000
                }
                
                
            }
            
            print(rootVC?.goalInML)
        }
    
        
    }
    
    func sceneWillResignActive(_ scene: UIScene) {

        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {

        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        
        print("sceneDidEnterBackground")
        notification.scheduleNotification()
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    
}

