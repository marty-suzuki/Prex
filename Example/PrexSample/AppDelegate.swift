//
//  AppDelegate.swift
//  PrexSample
//
//  Created by marty-suzuki on 2018/09/29.
//  Copyright © 2018 marty-suzuki. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        guard let navigationController = window?.rootViewController as? UINavigationController else {
            return false
        }

        navigationController.setViewControllers([SearchViewController()], animated: false)

        return true
    }
}

