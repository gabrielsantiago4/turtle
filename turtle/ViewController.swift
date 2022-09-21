//
//  ViewController.swift
//  turtle
//
//  Created by Gabriel Santiago on 15/09/22.
//

import UIKit



class ViewController: UIViewController {
    
    var goalInML: Float = 3000
    
    var changedA: Bool = true
    var changedB: Bool = true
    
    var healthManager = HKStoreManager()
    var records: Array<(Date, Double)> = []{
        
        didSet{
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
        button.setImage(UIImage(named: "pencil") , for: .normal)
        button.addTarget(self, action: #selector(ViewController.deleteLastRecord), for: .touchUpInside)
        return button
    }()
    
    var lakeView =  LakeView()
    
    
    
    func scenarioSlicer(){
        let countScenarios = Scenario.allCases.count - 1
        let mininumGoal:Float =  goalInML/Float(countScenarios)
        
        var parcela: Float = goalInML
        
        if (self.waterDrank > 0){
            for i in stride(from: countScenarios, to: 0, by: -1){
                
                print(self.waterDrank, parcela)
                print(mininumGoal,parcela,i)
                
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
            
            self.waterDrank = Float(self.records.reduce(0, { $0 + $1.1}))
            
            self.progressBar.setProgress(self.waterDrank / 3000, animated: true)
            
            let value = self.waterDrank / 1000
            self.waterCounter.text = String(format: "%.2fl", value)
            
     
            //print(self.waterDrank)
            
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
                print(self.records)
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
        
        backButton.backgroundColor = .red

        view.layer.insertSublayer(gradientBackground, at: 0)
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
            
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            backButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),

            
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
        stack3.distribution = .equalSpacing
        stack3.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stack2)
        view.addSubview(stack3)
        

        return (stack2,stack3)
        
    }

    
    func errorWhenPermissionDenied(){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Alert", message: "Adicione as permissões de leitura e escrita da quantidade de água no HealthKit", preferredStyle: UIAlertController.Style.alert)
            
     
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { _ in
                
                guard let settingsURL = URL(string: UIApplication.openSettingsURLString),UIApplication.shared.canOpenURL(settingsURL)
                           else {
                            return
                       }

                       UIApplication.shared.open(settingsURL)
            
              
               
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @objc func addWater250() {
       
        healthManager.addWaterAmountToHealthKit(ml: 250){ date, response, error in
            if let _ = error{
                self.errorWhenPermissionDenied()
            }else{
                self.records.append((date, 250))
            }
        }
    }
    
    @objc func addWater500() {
       
        healthManager.addWaterAmountToHealthKit(ml: 500){ date, response, error in
            if let _ = error{
                self.errorWhenPermissionDenied()
            }else{
                self.records.append((date, 500))
            }
        }
    }
    
    @objc func deleteLastRecord(){
        
        print("CLick")
        
        if let lastRecord = self.records.last{
            print(self.records)
            
            
            healthManager.deleteRecord(registro: lastRecord) { response, error in
                if let error = error {
                    print(error)
                }else{
                    print("Deu certo")
                }
            }
        }
       
    }
    
    
}
