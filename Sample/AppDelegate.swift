//
//  AppDelegate.swift
//  Sample
//
//  Created by nana_dotApp on 2015/11/21.
//  Copyright © 2015年 nanashiki. All rights reserved.
//

import UIKit
import LoginTokyoTechPortal
import SVProgressHUD
import KeychainAccess

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let login = Login.shared
        if let username = UserDefaults.standard.string(forKey: "Account"){
            login.account = PortalAccount(
                username: username,
                password: Keychain(service:"com.dotApp.LoginTokyoTechPortal.password")[username],
                matrixcode: JSON.arrayFromString(Keychain(service:"com.dotApp.LoginTokyoTechPortal.MatrixCode")[username])
            )
            
        
            NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.didStartLogin), name: NSNotification.Name(rawValue: LoginNotification.start.rawValue), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.didFinishLogin), name: NSNotification.Name(rawValue: LoginNotification.success.rawValue), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.didFailLogin), name: NSNotification.Name(rawValue: LoginNotification.fail.rawValue), object: nil)
            
            SVProgressHUD.setMinimumDismissTimeInterval(0.3)
            
            login.addObserver(self, forKeyPath: "progress", options: .new, context: nil)
            
//            login.showMatrixcode(){
//                matrix, code in
//                
//                print(matrix)
//                
//                
//            }
//            return true
            
            login.start{
                status in
                
                if let url = login.ocwiCalendarURL {
                    let ud = UserDefaults.standard
                    ud.set(url, forKey: "OCWiCalendarURL")
                }
                
//                print(login.ocwiCalendarURL)
            }
        }
        
        return true
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?){
//        print(Login.sharedInstance.progress)
    }
    
    
    func didStartLogin(){
        DispatchQueue.main.async(execute: {
            SVProgressHUD.setDefaultMaskType(.clear)
            SVProgressHUD.show(withStatus: "now login...")
        })
    }
    
    func didFinishLogin(){
        
        DispatchQueue.main.async(execute: {
            SVProgressHUD.setDefaultMaskType(.clear)
            SVProgressHUD.showSuccess(withStatus: "Login Success")
        })
    }
    
    func didFailLogin(){
        DispatchQueue.main.async(execute: {
            SVProgressHUD.setDefaultMaskType(.clear)
            SVProgressHUD.showError(withStatus: "Login Failed")
        })
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

