//
//  ScreenChecker.swift
//  NASAApp
//
//  Created by Piotr Nietrzebka on 20/12/2024.
//

import UIKit

class ScreenChecker {

    static var isNarrowScreen: Bool {
        let iPhone6Width = CGFloat(375)
        return UIScreen.main.bounds.width < iPhone6Width
    }

    static var isBigScreen: Bool {
        return UIScreen.main.bounds.width >= 768 && UIScreen.main.bounds.height >= 768
    }
    
    static var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}

extension ScreenChecker {
    static func size(big: CGFloat, small: CGFloat) -> CGFloat {
        if isIPad {
            return big
        }
        
        return small
    }
}
