//
//  SceneDelegate.swift
//  DoctorsNote
//
//  Created by Benjamin Hardin on 2/13/20.
//  Copyright © 2020 Benjamin Hardin. All rights reserved.
//

import UIKit
import AWSMobileClient

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // If this scene's self.window is nil then set a new UIWindow object to it.
        self.window = self.window ?? UIWindow()
            

        if (AWSMobileClient.default().isSignedIn) {
            let group = DispatchGroup()
            group.enter()
            var setup = false

            // avoid deadlocks by not using .main queue here
            CognitoHelper.sharedHelper.isUserSetUp { (setUp) in
                if (setUp) {
                    DispatchQueue.global(qos: .default).async {
                        // User has all properties set
                        setup = true
                        group.leave()
                    }
                } else {
                    DispatchQueue.global(qos: .default).async {
                        // User needs to finish creating profile
                        group.leave()
                    }
                }
            }

            // wait ...
            group.wait()
            if (setup) {
                self.window!.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
            } else {
                self.window!.rootViewController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()
            }
        } else {
            self.window!.rootViewController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()
        }
        
        // Make this scene's window be visible.
        self.window!.makeKeyAndVisible()
        guard let _ = (scene as? UIWindowScene) else { return }
        

    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

