//
//  AppDelegate.swift
//  MatrixMath
//
//  Created by Ivan Magda on 31.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import UIKit

//---------------------------------------------------------
// MARK: - AppDelegate: UIResponder, UIApplicationDelegate
//---------------------------------------------------------

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    //-----------------------------------------------------
    // MARK: Properties
    //-----------------------------------------------------

    var window: UIWindow?
    
    private let apiClient = MatrixMathApiClient.sharedInstance
    
    //-----------------------------------------------------
    // MARK: UIApplicationDelegate
    //-----------------------------------------------------

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        setup()
        return true
    }
    
    //-----------------------------------------------------
    // MARK: Setup
    //-----------------------------------------------------
    
    private func setup() {
        let navigationController = window!.rootViewController as! UINavigationController
        
        let operationsViewController = navigationController.topViewController as! MatrixOperationsTableViewController
        operationsViewController.apiClient = apiClient
    }
    
}

