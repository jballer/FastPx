//
//  AppDelegate.swift
//  FastPX
//
//  Created by Ben Sandofsky on 8/2/14.
//  Copyright (c) 2014 Sandofsky. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?
    var tabBarController: UITabBarController?

    func switchToAccount(account: Account, animated: Bool){
        tabBarController = UITabBarController(nibName: nil, bundle: nil)
        let popularNav = UINavigationController(rootViewController: PopularTimelineViewController(account: account))
        popularNav.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.TopRated, tag: 0)

        let editorsNav = UINavigationController(rootViewController: EditorsTimelineViewController(account: account))
        editorsNav.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.Featured, tag: 0)

        tabBarController?.viewControllers = [popularNav, editorsNav]
        window?.rootViewController = tabBarController
    }

    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        if AccountManager.sharedManager.accounts.count > 0 {
            self.switchToAccount(AccountManager.sharedManager.accounts.first!, animated:false)
        } else {
            self.switchToAccount(AccountManager.sharedManager.loggedOutAccount, animated: false)
        }
        window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(application: UIApplication!) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication!) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication!) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication!) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication!) {

    }

}

