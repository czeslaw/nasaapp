//
//  UIColor+.swift
//  NASAApp
//
//  Created by Piotr Nietrzebka on 20/12/2024.
//

import UIKit

extension UIColor {
    convenience init(red: UInt32, gre: UInt32, blu: UInt32, alp: CGFloat = 1.0) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(gre >= 0 && gre <= 255, "Invalid green component")
        assert(blu >= 0 && blu <= 255, "Invalid blue component")
        self.init(red: CGFloat(red)/255.0,
                  green: CGFloat(gre)/255.0,
                  blue: CGFloat(blu)/255.0,
                  alpha: alp)
    }
}
