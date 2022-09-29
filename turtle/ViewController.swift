//
//  ViewController.swift
//  turtle
//
//  Created by Gabriel Santiago on 15/09/22.
//

import UIKit
import CoreHaptics
import ARKit
import WidgetKit
import SwiftUI



class Haptic{
    
    
    static func buttonWater(){
        let parameters = [
          CHHapticEventParameter(
            parameterID: .hapticIntensity,
            value: 0.95)
        ]

        let event = CHHapticEvent(
          eventType: .hapticTransient,
          parameters: parameters,
          relativeTime: 0,
          duration: 0.04)
        
        
        do{
            let engine = try CHHapticEngine()
            try engine.start()

            let pattern = try CHHapticPattern(
              events: [event],
              parameters: [])
            let player = try engine
              .makePlayer(with: pattern)
            try player.start(atTime: 0)
            
        }catch{
            
        }
        
    }
    
    static func buttonReturn() {
        let parameters = [
          CHHapticEventParameter(
            parameterID: .hapticIntensity,
            value: 1.00),
          CHHapticEventParameter(
            parameterID: .hapticSharpness,
            value: 1.00),
        ]

        let event = CHHapticEvent(
          eventType: .hapticTransient,
          parameters: parameters,
          relativeTime: 0,
          duration: 0.04)

        
        do{
            let engine = try CHHapticEngine()
            try engine.start()

            let pattern = try CHHapticPattern(
              events: [event],
              parameters: [])
            let player = try engine
              .makePlayer(with: pattern)
            try player.start(atTime: 0)
            
        }catch{
            
        }
       
        
    }
}





class ViewController: UIViewController {
    
    var isLoaded = false
  
    var goalInML: Float = 3000 {
        didSet{
            updateView()
        }
    }
    

    var healthManager = HKStoreManager()
    
  
    var records: Array<HKWaterRecord> = []{
        
        
        
        didSet{
            
            updateView()

        }
    
    }

    
    var waterDrank: Float = 0 {
        didSet{
            
            DispatchQueue.global(qos: .background).async {
                let widgetData = WidgetData(waterGoal:  self.goalInML, waterDrank: self.waterDrank)
                widgetData.ToJson { json, error in
                    //guard let error else { return }
                    UserDefaults(suiteName: "group.br.com.turtle")!.set( json!, forKey: "records")
                }
                WidgetCenter.shared.reloadTimelines(ofKind: "WaterWidget")

            }
              
            
        }
    }
    
    lazy var gradientBackground: CAGradientLayer = {
        let gradienteLayer = CAGradientLayer()
        gradienteLayer.frame = view.bounds
        gradienteLayer.colors = [ UIColor(named: "gradientColor1")!.cgColor, UIColor(named: "gradientColor2")!.cgColor]
        gradienteLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradienteLayer.endPoint = CGPoint(x: 0.5, y: 1.1)
        return gradienteLayer
    }()
    
    lazy var waterCounterHeader: UILabel = {
        let waterCounterHeader = UILabel ()
        waterCounterHeader.font = UIFont(name: "Quantico-Bold", size: 17)
        waterCounterHeader.textColor = .counterColor
        waterCounterHeader.text = "Bebido"
        return waterCounterHeader
        
    }()
    
    lazy var waterCounter: UILabel = {
        let waterCounter = UILabel()
        waterCounter.font = UIFont(name: "Quantico-Bold", size: 39)
        waterCounter.textColor = .counterColor
        waterCounter.text = "0.00"
        return waterCounter
    }()
    
    lazy var waterGoal: UILabel = {
        let waterGoal = UILabel()
        waterGoal.font = UIFont(name: "Quantico-Bold", size: 21)
        waterGoal.textColor = .goalColor
        waterGoal.text = "Sua meta: 3l"
        return waterGoal
    }()
    
    lazy var button250 : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "glass"), for: .normal)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(ViewController.addWater250), for: .touchUpInside)
        return button
    }()
    
    lazy var button500: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "bottle"), for: .normal)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(ViewController.addWater500), for:.touchUpInside)
        return button
    }()
    
    lazy var progressBar: UIProgressView = {
        let progressBar = GradientProgressView(progressViewStyle: .bar)
        progressBar.trackTintColor = UIColor(named: "progressTrackColor")
        progressBar.firstColor =  UIColor(named: "progressGradient1")!
        progressBar.secondColor = UIColor(named: "progressGradient2")!
        progressBar.layer.cornerRadius = 13
        progressBar.layer.sublayers![1].cornerRadius = 13
        progressBar.subviews[1].clipsToBounds = true
        progressBar.layer.masksToBounds = true
        return progressBar
    }()
    
    lazy var cloudImage: UIImageView = {
        let cloudCounter = UIImageView()
        cloudCounter.image = UIImage(named: "Vector")
        cloudCounter.translatesAutoresizingMaskIntoConstraints = false
        return cloudCounter
    }()
    
    lazy var backButton: UIButton = {
        let button = UIButton()
        
        
        let largeConfig = UIImage.SymbolConfiguration(scale: .large)
//        arrowshape.turn.up.backward.fill
        let image = UIImage(systemName: "gear", withConfiguration: largeConfig)

        button.setImage(image , for: .normal)
        button.tintColor = .white
        
        
        button.addTarget(self, action: #selector(ViewController.deleteLastRecord), for: .touchUpInside)
        
//        button.layer.cornerRadius = 20
//        button.layer.masksToBounds = true
//        button.backgroundColor = .white
        return button
    }()
    
    
    lazy var loadingView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.color = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.startAnimating()
        return view
    }()
    
    lazy var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return blurEffectView
    }()
    
    
    var lakeView =  LakeView()
    var notification = NotificationManager()
 

    
    func scenarioSlicer(){
        

        
        let countScenarios = Scenario.allCases.count - 2
        let mininumGoal:Float =  goalInML/Float(countScenarios)
        var parcela: Float = goalInML
        
        
        
        if (self.waterDrank > 0){
            for i in stride(from: countScenarios, to: 0, by: -1){

                if(self.waterDrank >= parcela){
                    self.lakeView.loadScene(tipo: Scenario(rawValue: i) ?? .dry)
                    break
                }
                parcela -=  mininumGoal
            }
            
            if(self.waterDrank > 1.5*goalInML){
                self.lakeView.loadScene(tipo: .wet4)
            }
            
        }else{
            self.lakeView.loadScene(tipo: .dry)
//            self.lakeView.accessibilityLabel()
        }

        
        
    }
    
  
  
    func updateView(){
        DispatchQueue.main.async {
            
            self.waterGoal.text = "Sua meta: \(String(format: "%.1f l", self.goalInML/1000))"
            
            self.waterDrank = Float(self.records.reduce(0, { $0 + $1.sizeML}))
            
            
            self.progressBar.setProgress(self.waterDrank / self.goalInML, animated: true)
            
            let value = self.waterDrank / 1000
            self.waterCounter.text = String(format: "%.2fl", value)
            
            if(self.waterDrank > 0){
                self.waterCounterHeader.text = "Bebidos"
            }else{
                self.waterCounterHeader.text = "Bebido"
            }
            
            if(self.waterDrank >= self.goalInML){
                self.notification.removeAllNotifications()
            }
               

            
            self.scenarioSlicer()
   
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        
        (self.progressBar as! GradientProgressView).firstColor = UIColor(named: "progressGradient1")!
        
        (self.progressBar as! GradientProgressView).secondColor = UIColor(named: "progressGradient2")!
        self.progressBar.trackTintColor = UIColor(named: "progressTrackColor")
    
        
        self.gradientBackground.colors = [ UIColor(named: "gradientColor1")!.cgColor, UIColor(named: "gradientColor2")!.cgColor]
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        print("Teste")
    }
    
 
    override func viewDidAppear(_ animated: Bool) {
        
        
        self.healthManager.createAuthRequest { result, error in
            
            DispatchQueue.main.async {
                self.blurView.isHidden = result
                self.loadingView.isHidden = result
            }
           
        }
        
        self.notification.requestAuthorization()
        
        self.notification.getNotications()
    
    self.healthManager.getRecords { records, error in
        
        if let error = error{
            print(error)
        }else{
            self.records = records
            self.waterDrank = Float(records.reduce(0, { partialResult, number in
                return partialResult + number.sizeML
            }))
        }
       
    }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        
        let (stack2, stack3)  = configureStacks()
        
            
            view.addSubview(lakeView)
            view.addSubview(progressBar)
            view.addSubview(waterGoal)
            view.addSubview(backButton)
            view.addSubview(blurView)
            view.addSubview(loadingView)

        view.layer.insertSublayer(gradientBackground, at: 0)
        
        configureConstraints(stack2: stack2, stack3: stack3)
        
        //lakeView.session.run(ARWorldTrackingConfiguration())


    }
    
    func configureConstraints(stack2: UIStackView, stack3: UIStackView) {
        
        lakeView.translatesAutoresizingMaskIntoConstraints = false
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        waterGoal.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        
            NSLayoutConstraint.activate([
                loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

                stack2.widthAnchor.constraint(equalToConstant: 205),
                stack2.widthAnchor.constraint(equalToConstant: 205),
                stack2.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
                stack2.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                stack3.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
                stack3.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
                stack3.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),

                lakeView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                lakeView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                lakeView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                lakeView.topAnchor.constraint(equalTo: waterGoal.bottomAnchor),
                lakeView.bottomAnchor.constraint(equalTo: stack3.topAnchor),
                
                progressBar.widthAnchor.constraint(equalToConstant: 205),
                progressBar.heightAnchor.constraint(equalToConstant: 22),
                progressBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                progressBar.topAnchor.constraint(equalTo: stack2.bottomAnchor,constant: 27),
            
                waterGoal.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                waterGoal.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 10),
                
                backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
                backButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                backButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.2),
                backButton.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.2),
                
   


                
            ])
       
      
        
    }
    
    func configureStacks() -> (UIStackView, UIStackView){
        let stack = UIStackView(arrangedSubviews: [waterCounter,waterCounterHeader])
        let stack2 = UIStackView(arrangedSubviews: [cloudImage,stack])
        let stack3 = UIStackView(arrangedSubviews: [button250, button500])
                
        
        stack .distribution = .fillProportionally
        stack .alignment = .center
        
        stack.axis = .vertical
        
        stack2.axis = .vertical
        stack2.alignment = .center
        stack2.spacing = -90
        stack2.translatesAutoresizingMaskIntoConstraints = false
        
        
        stack3.axis = .horizontal
        stack3.alignment = .center
        stack3.distribution = .fillEqually
        stack3.spacing = 50
        stack3.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stack2)
        view.addSubview(stack3)
        

        return (stack2,stack3)
        
    }

    
    func errorWhenPermissionDenied(){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Alert", message: "Adicione as permissões de leitura e escrita da quantidade de água no HealthKit", preferredStyle: UIAlertController.Style.alert)
            
     
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { _ in
       
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    

   
    
    
   
    
    @objc func addWater500() {
        
        

       
        healthManager.addWaterAmountToHealthKit(ml: 500){ waterRecord, error in
            if let _ = error{
                self.errorWhenPermissionDenied()
            }else{
                Haptic.buttonWater()
                self.records.append(waterRecord)
            }
        }
    }
    
    @objc func addWater250(){
        
        
       
    
        healthManager.addWaterAmountToHealthKit(ml: 250){ waterRecord, error in
            if let _ = error{
                self.errorWhenPermissionDenied()
            }else{
                Haptic.buttonWater()
                self.records.append(waterRecord)
            }
        }
       
    }
    
    @objc func deleteLastRecord(){
        
        let swiftUIController = UIHostingController(rootView: ConfigView(records: records))
        swiftUIController.modalPresentationStyle = .fullScreen
        present(swiftUIController, animated: true)
        
//        if let lastRecord = self.records.last{
//            print(self.records)
//
//
//            healthManager.deleteRecord(registro: lastRecord) { response, _ , error  in
//                if let _ = error {
//                    self.errorWhenPermissionDenied()
//                }else{
//
//                    Haptic.buttonReturn()
//
//                    DispatchQueue.main.async {
//
//                            if !self.records.isEmpty{
//                                self.records.removeLast()
//                            }
//
//                    }
//
//                }
//            }
//        }
       
    }
    
    
}
