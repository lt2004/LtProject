//
//  AppDelegate.swift
//  NetworkDemo
//
//  Created by Mac on 2019/9/29.
//  Copyright © 2019 manman. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        /*
        let classId = "5d8c8d365c32735ce37e31c5"
        let query = GetStudentClassroomQuery.init(classroomId: classId)
        NetworkManager.sharedInstance.apollo.fetch(query: query) { result in
            print("获取结果");
            
        }
 */
        // NSURL（fileURLWithPath：NSTemporaryDirectory（））。 appendingPathComponent（“instagram.igo”）
//        let contactFilePath = NSURL(fileURLWithPath: ).appendingPathComponent("contacts.data")
//        let path=NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,FileManager.SearchPathDomainMask.userDomainMask, true)[0].stringByAppendingPathComponent("user.data")
        let userLoginQuery = UserLoginQuery.init(email: "liute@test.com", passWord: "111111", userType: 0)
        NetworkManager.sharedInstance.commonQuery(query: userLoginQuery, networkTye: .Login) { (_, _) in
            
        }

//        NetworkManager.sharedInstance.apollo.fetch(query: userLoginQuery) { result in
//            guard let data = try? result.get().data else { return }
//            print("获取结果");
//
//        }
        
        
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

