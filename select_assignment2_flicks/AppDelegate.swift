//
//  AppDelegate.swift
//  select_assignment2_flicks
//
//  Created by hoaqt on 7/2/16.
//  Copyright © 2016 com.noron. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        createTabs()
        setUpTheme()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func createTabs() {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        
        let nowPlayingNavigationViewController = storyboard.instantiateViewControllerWithIdentifier("navigationViewController") as! UINavigationController
        nowPlayingNavigationViewController.tabBarItem.title = "Now Playing"
        nowPlayingNavigationViewController.tabBarItem.image = UIImage(named: "nowPlaying")
        let nowPlayingViewController = nowPlayingNavigationViewController.viewControllers[0] as! ViewController
        nowPlayingViewController.viewMode = .NowPlaying
        
        let topRatedNavigationViewController = storyboard.instantiateViewControllerWithIdentifier("navigationViewController") as! UINavigationController
        topRatedNavigationViewController.tabBarItem.title = "Top Rated"
        topRatedNavigationViewController.tabBarItem.image = UIImage(named: "topRated")
        let topRatedViewController = topRatedNavigationViewController.viewControllers[0] as! ViewController
        topRatedViewController.viewMode = .TopRated
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [nowPlayingNavigationViewController, topRatedNavigationViewController]
        
        window?.rootViewController = tabBarController
        
        window?.makeKeyAndVisible()
    }
    
    func setUpTheme() {
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.barStyle = .Black
        navigationBarAppearance.barTintColor = UIColor.redColor()
        navigationBarAppearance.tintColor = UIColor.whiteColor()
        navigationBarAppearance.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.barTintColor = UIColor.redColor()
        tabBarAppearance.tintColor = UIColor.whiteColor()
    }


}

