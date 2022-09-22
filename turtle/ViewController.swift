//
//  ViewController.swift
//  turtle
//
//  Created by Gabriel Santiago on 15/09/22.
//

import UIKit
import CoreHaptics


class PulseAnimation: CALayer {

    var animationGroup = CAAnimationGroup()
    var animationDuration: TimeInterval = 1.5
    var radius: CGFloat = 200
    var numebrOfPulse: Float = Float.infinity
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(numberOfPulse: Float = Float.infinity, radius: CGFloat, postion: CGPoint){
        super.init()
        self.backgroundColor = UIColor.black.cgColor
        self.contentsScale = UIScreen.main.scale
        self.opacity = 0
        self.radius = radius
        self.numebrOfPulse = numberOfPulse
        self.position = postion
        
        self.bounds = CGRect(x: 0, y: 0, width: radius*2, height: radius*2)
        self.cornerRadius = radius
        
        DispatchQueue.global(qos: .default).async {
            self.setupAnimationGroup()
            DispatchQueue.main.async {
                self.add(self.animationGroup, forKey: "pulse")
           }
        }
    }
    
    func scaleAnimation() -> CABasicAnimation {
        let scaleAnimaton = CABasicAnimation(keyPath: "transform.scale.xy")
        scaleAnimaton.fromValue = NSNumber(value: 0)
        scaleAnimaton.toValue = NSNumber(value: 1)
        scaleAnimaton.duration = animationDuration
        return scaleAnimaton
    }
    
    func createOpacityAnimation() -> CAKeyframeAnimation {
        let opacityAnimiation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimiation.duration = animationDuration
        opacityAnimiation.values = [0.4,0.8,0]
        opacityAnimiation.keyTimes = [0,0.3,1]
        return opacityAnimiation
    }
    
    func setupAnimationGroup() {
        self.animationGroup.duration = animationDuration
        self.animationGroup.repeatCount = numebrOfPulse
        let defaultCurve = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
        self.animationGroup.timingFunction = defaultCurve
        self.animationGroup.animations = [scaleAnimation(),createOpacityAnimation()]
    }
    
    
}


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
    
    var i = 0

    
    var goalInML: Float = 3000 {
        didSet{
            updateView()
        }
    }
    
    var changedA: Bool = true
    var changedB: Bool = true
    
    var healthManager = HKStoreManager()
    

    var records: Array<(Date, Double, [String: Any]?)> = []{
        
        didSet{
            print(records)
            updateView()
        }
    
    }

    
    var waterDrank: Float = 0
    
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
        waterCounter.text = "0"
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
       // button.addTarget(self, action: #selector(ViewController.addWater250), for: .touchUpInside)
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
        
        let image = UIImage(systemName: "arrowshape.turn.up.backward.fill", withConfiguration: largeConfig)

        button.setImage(image , for: .normal)
        button.tintColor = .white
        
        
        button.addTarget(self, action: #selector(ViewController.deleteLastRecord), for: .touchUpInside)
        
//        button.layer.cornerRadius = 20
//        button.layer.masksToBounds = true
//        button.backgroundColor = .white
        return button
    }()
    
    var lakeView =  LakeView()
    
    
    
    func scenarioSlicer(){
        let countScenarios = Scenario.allCases.count - 1
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
        }else{
            self.lakeView.loadScene(tipo: .dry)
        }
        
    }
    
    
  
    func updateView(){
        DispatchQueue.main.async {
            
            self.waterGoal.text = "Sua meta: \(String(format: "%.1f l", self.goalInML/1000))"
            
            self.waterDrank = Float(self.records.reduce(0, { $0 + $1.1}))
            
            
            self.progressBar.setProgress(self.waterDrank / self.goalInML, animated: true)
            
            let value = self.waterDrank / 1000
            self.waterCounter.text = String(format: "%.2fl", value)
            
            if(self.waterDrank > 0){
                self.waterCounterHeader.text = "Bebidos"
            }else{
                self.waterCounterHeader.text = "Bebido"
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
        super.viewDidAppear(animated)
            self.healthManager.createAuthRequest { result, error in
              
                
            }
        
        self.healthManager.getRecords { records, error in
            
            if let error = error{
                print(error)
            }else{
                self.records = records
                self.waterDrank = Float(records.reduce(0, { partialResult, number in
                    return partialResult + number.1
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
        

        view.layer.insertSublayer(gradientBackground, at: 0)
        
        
        let gesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongPress)
        )
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapPress))
        
        let gesture1: UILongPressGestureRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongPress)
        )
        let tapGesture2: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapPress))
        
        button250.addGestureRecognizer(gesture)
        button250.addGestureRecognizer(tapGesture)
        
        button500.addGestureRecognizer(gesture1)
        button500.addGestureRecognizer(tapGesture2)
        
        configureConstraints(stack2: stack2, stack3: stack3)
        
    }
    
    func configureConstraints(stack2: UIStackView, stack3: UIStackView) {
        
        lakeView.translatesAutoresizingMaskIntoConstraints = false
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        waterGoal.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
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
    
    
    @objc func handleTapPress(tapGesture: UITapGestureRecognizer) {
        
        shakeAnimate(view: tapGesture.view)
        
    func shakeAnimate(view:UIView?){
            let animation = CAKeyframeAnimation()
            animation.keyPath = "position.x"
            animation.values = [0, 10, -10, 10, 0]
            animation.keyTimes = [0, 0.16, 0.5, 0.83, 1]
            animation.duration = 0.4
            
            animation.isAdditive = true
        
            if let view = view{
                view.layer.add(animation, forKey: "shake")
            }
            
        }
    }
    
    @objc func tapped() {

        switch i {
        case 1:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            
        case 2:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
        case 3:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
            
        case 4:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
        case 5:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
        case 6:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            
        default:
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
            i = 0
        }
    }
    
    @objc func handleLongPress(longPress: UIGestureRecognizer) {
        if (longPress.state == UIGestureRecognizer.State.began) {
            // iniciar timer
        } else if (longPress.state == UIGestureRecognizer.State.ended) {
            // timer > 3 ? se sim animação : se não faz nada
            
            
            
            if longPress.view == button250{
                healthManager.addWaterAmountToHealthKit(ml: 250){ meta, date, response, error in
                    if let _ = error{
                        self.errorWhenPermissionDenied()
                    }else{
                        Haptic.buttonWater()
                        self.records.append((date, 250, meta))
                    }
                }

            }else if longPress.view == button500{
                healthManager.addWaterAmountToHealthKit(ml: 500){ meta, date, response, error in
                    if let _ = error{
                        self.errorWhenPermissionDenied()
                    }else{
                        Haptic.buttonWater()
                        self.records.append((date, 500, meta))
                    }
                }

            }
        }
        
    }
    
   
    
    @objc func addWater500() {
       
        healthManager.addWaterAmountToHealthKit(ml: 500){ meta, date, response, error in
            if let _ = error{
                self.errorWhenPermissionDenied()
            }else{
                Haptic.buttonWater()
                self.records.append((date, 500, meta))
            }
        }

    }
    
    @objc func deleteLastRecord(){
        
        
        
        if let lastRecord = self.records.last{
            print(self.records)
            
            
            healthManager.deleteRecord(registro: lastRecord) { response, _ , error  in
                if let _ = error {
                    self.errorWhenPermissionDenied()
                }else{
                    
                    Haptic.buttonReturn()
                    
                    DispatchQueue.main.async {
              
                            if !self.records.isEmpty{
                                self.records.removeLast()
                            }
                       
                    }
  
                }
            }
        }
       
    }
    
    
}
