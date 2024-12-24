//
//  AppStyle.swift
//  NASAApp
//
//  Created by Piotr Nietrzebka on 20/12/2024.
//

import SwiftUI

func applyStyle() {
    UIBarButtonItem.appearance(whenContainedInInstancesOf: [UIDocumentBrowserViewController.self]).tintColor = Configuration.Color.navigationBarButtonItemTint
    UIWindow.appearance().tintColor = Configuration.Color.appTint

    UINavigationBar.appearance().shadowImage = UIImage(color: Configuration.Color.navigationBarSeparator, 
                                                       size: CGSize(width: 0.25, height: 0.35))
    UINavigationBar.appearance().compactAppearance = UINavigationBarAppearance.defaultAppearence
    UINavigationBar.appearance().standardAppearance = UINavigationBarAppearance.defaultAppearence
    UINavigationBar.appearance().scrollEdgeAppearance = UINavigationBarAppearance.defaultAppearence
    UINavigationBar.appearance().tintColor = Configuration.Color.navigationBarButtonItemTint

    //We could have set the backBarButtonItem with an empty title for every view controller. Using appearance here, while a hack is still more convenient though, since we don't have to do it for every view controller instance
    UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -200,
                                                                               vertical: 0),
                                                                      for: .default)
    UIBarButtonItem.appearance().tintColor = Configuration.Color.navigationBarButtonItemTint
    UIBarButtonItem.appearance(whenContainedInInstancesOf: [UIToolbar.self]).tintColor = Configuration.Color.navigationBarButtonItemTint

    UIToolbar.appearance().tintColor = Configuration.Color.appTint

    //Background (not needed in iOS 12.1 on simulator)
    //Cancel button
    UISearchBar.appearance().tintColor = Configuration.Color.searchBarTint
    //Cursor color
    UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = Configuration.Color.searchBarTint

    UIRefreshControl.appearance().tintColor = Configuration.Color.appTint
    UIRefreshControl.appearance().bounds.origin.y = -50

    UISwitch.appearance().onTintColor = Configuration.Color.appTint
    
    UITableView.appearance().separatorColor = Configuration.Color.tableViewSeparator
}

extension UINavigationBarAppearance {
    static var defaultAppearence: UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Configuration.Color.navigationBarBackgroundColor
        appearance.shadowColor = Configuration.Color.navigationBarSeparator
        appearance.shadowImage = UIImage(color: Configuration.Color.navigationBarSeparator,
                                         size: CGSize(width: 0.25, height: 0.35))
        
        appearance.setBackIndicatorImage(Images.backWhite,
                                         transitionMaskImage: Images.backWhite)
        appearance.titleTextAttributes = [
            .foregroundColor: Configuration.Color.navigationBarPrimaryFontColor,
            .font: Fonts.regular(size: 16) as Any
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: Configuration.Color.navigationBarPrimaryFontColor,
            .font: Fonts.bold(size: 36) as Any,
        ]
        //NOTE: this hides the back button text
        appearance.backButtonAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.clear,
        ]
        
        return appearance
    }
}
