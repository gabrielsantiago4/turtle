//
//  ViewController.swift
//  turtle
//
//  Created by Gabriel Santiago on 15/09/22.
//

import UIKit

class ViewController: UIViewController {
    
    var goalInML: Float = 3000
    
    var waterDrank: Float = 0 {
        didSet {  //faz algo toda vida que um valor mudar
            
            progressBar.setProgress(waterDrank / 3000, animated: true)
            
            let mininumML = Float(3000/Scenario.allCases.count + 150)
            
            var waterStage = Float(mininumML * lakeView.tipo.position)
          
            if(waterDrank/waterStage >= 1 && waterDrank <= goalInML){

                waterStage = Float(mininumML * lakeView.tipo.position)
                let tipo = Scenario(rawValue: lakeView.tipo.rawValue+1) ?? .dry
                lakeView.loadScene(tipo: tipo)

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
        waterCounterHeader.font = UIFont(name: "Quantico-Regular", size: 15.80)
        waterCounterHeader.textColor = .counterColor
        waterCounterHeader.text = "Você já bebeu"
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
        waterGoal.font = UIFont(name: "Quantico-Regular", size: 21)
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
        progressBar.trackTintColor = UIColor.progressbarTrack
        progressBar.firstColor = .progressbarColor1
        progressBar.secondColor = .progressbarColor2
        progressBar.layer.cornerRadius = 13
        progressBar.layer.sublayers![1].cornerRadius = 13
        progressBar.subviews[1].clipsToBounds = true
        progressBar.layer.masksToBounds = true
        return progressBar
    }()
    
    lazy var cloudImage: UIImageView = {
        let cloudCounter = UIImageView()
        cloudCounter.image = UIImage(named: "Vector")
        return cloudCounter
    }()
    
    var lakeView =  LakeView()

    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        
        (self.progressBar as! GradientProgressView).firstColor = UIColor(named: "progressGradient1")!
        
        (self.progressBar as! GradientProgressView).secondColor = UIColor(named: "progressGradient2")!
        self.progressBar.trackTintColor = UIColor(named: "progressTrackColor")
    
        
        self.gradientBackground.colors = [ UIColor(named: "gradientColor1")!.cgColor, UIColor(named: "gradientColor2")!.cgColor]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        lakeView.loadScene(tipo: .dry)
        //view.backgroundColor = .black
        
        view.addSubview(lakeView)
        view.addSubview(button250)
        view.addSubview(button500)
        view.addSubview(progressBar)
        view.addSubview(cloudImage)
        view.addSubview(waterCounterHeader)
        view.addSubview(waterCounter)
        view.addSubview(waterGoal)
        view.layer.insertSublayer(gradientBackground, at: 0)
        
        configureConstraints()
        
    }
    
    func configureConstraints() {
        
        waterGoal.translatesAutoresizingMaskIntoConstraints = false
        waterCounterHeader.translatesAutoresizingMaskIntoConstraints = false
        waterCounter.translatesAutoresizingMaskIntoConstraints = false
        button250.translatesAutoresizingMaskIntoConstraints = false
        button500.translatesAutoresizingMaskIntoConstraints = false
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        cloudImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            lakeView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            lakeView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            lakeView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lakeView.topAnchor.constraint(equalTo: waterGoal.bottomAnchor, constant: 2)
       
//            lakeView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4),
//
//            lakeView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            lakeView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

        ])

        NSLayoutConstraint.activate([
            waterCounter.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            waterCounter.topAnchor.constraint(equalTo: view.topAnchor, constant: 155)
        ])
        
        NSLayoutConstraint.activate([
            button250.widthAnchor.constraint(equalToConstant: 100),
            button250.heightAnchor.constraint(equalToConstant: 130),
            button250.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 52),
            button250.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
        ])
        
        NSLayoutConstraint.activate([
            button500.widthAnchor.constraint(equalToConstant: 100),
            button500.heightAnchor.constraint(equalToConstant: 130),
            button500.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -52),
            button500.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
        ])
        
        NSLayoutConstraint.activate([
            progressBar.widthAnchor.constraint(equalToConstant: 205),
            progressBar.heightAnchor.constraint(equalToConstant: 25),
            progressBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 230)
        
        ])
        
        NSLayoutConstraint.activate([
            cloudImage.widthAnchor.constraint(equalToConstant: 205),
            cloudImage.heightAnchor.constraint(equalToConstant: 127.35),
            cloudImage.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 3),
            cloudImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 90)
        ])
        
        NSLayoutConstraint.activate([
            waterCounterHeader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            waterCounterHeader.topAnchor.constraint(equalTo: view.topAnchor, constant: 135)
        ])
        
        NSLayoutConstraint.activate([
            waterGoal.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            waterGoal.topAnchor.constraint(equalTo: view.topAnchor, constant: 265)
        ])
        
    }

    
    
    @objc func addWater250() {
        self.waterDrank += 250
        let value = self.waterDrank / 1000
        self.waterCounter.text = String(format: "%.1fl", value)
        
    }
    
    @objc func addWater500() {
        self.waterDrank += 500
        let value = self.waterDrank / 1000
        self.waterCounter.text = String(format: "%.1fl", value)

    }
    
    
}
