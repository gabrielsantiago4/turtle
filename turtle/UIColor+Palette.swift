//
//  UIColor+Palette.swift
//  turtle
//
//  Created by Gabriel Santiago on 15/09/22.
//

import Foundation
import UIKit


extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}

extension UIColor {
    
    
    class var backgroundColor1: UIColor {
        return UIColor(red: 67.0 / 255.0, green: 189.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    }
    
    class var backroundColor2: UIColor {
        return UIColor(red: 110.0 / 255.0, green: 217.0 / 255.0, blue: 245.0 / 255.0, alpha: 0.52)
    }
    
    class var progressbarColor1: UIColor {
        return UIColor(red: 0.0 / 255.0, green: 120.0 / 255.0, blue: 188.0 / 255.0, alpha: 1.0)
    }
    
    class var progressbarColor2: UIColor {
        return UIColor(red: 67.0 / 255.0, green: 143.0 / 255.0, blue: 214.0 / 255.0, alpha: 0.75)
    }
    
    class var progressbarTrack: UIColor {
        return UIColor(red: 154.0 / 255.0, green: 213.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    }
    
    class var counterColor: UIColor {
        return UIColor(red: 13 / 255.0, green: 38 / 255.0, blue: 102 / 255.0, alpha: 1.0)
    }
    
    class var goalColor: UIColor {
        return UIColor(red: 230 / 255.0, green: 241 / 255.0, blue: 255 / 255.0, alpha: 1.0)
    }
}
