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

    #if swift(>=4.2)
    typealias UIApplicationLaunchOptionsKey = UIApplication.LaunchOptionsKey
    #endif
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        guard let navigationController = window?.rootViewController as? UINavigationController else {
            return false
        }

        navigationController.setViewControllers([SearchViewController()], animated: false)

        return true
    }
}

