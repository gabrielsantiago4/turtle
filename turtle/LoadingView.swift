//
//  LoadingView.swift
//  turtle
//
//  Created by João Victor Ipirajá de Alencar on 25/09/22.
//

import Foundation
import UIKit


class LoadingView:UIActivityIndicatorView{
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(view: UIView){
        self.init(frame: .zero)
        self.style = .large
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            self.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
  
    
}
