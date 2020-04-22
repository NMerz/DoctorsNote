//
//  AppDelegate.swift
//  DoctorsNote
//
//  Created by Benjamin Hardin on 2/13/20.
//  Copyright © 2020 Benjamin Hardin and Nathan Merz. All rights reserved.
//

import UIKit
import AWSCore
import AWSS3
import AWSDynamoDB
import AWSSQS
import AWSSNS
import AWSCognito
import AWSMobileClient
import UserNotifications

import CryptoKit
import CommonCrypto


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    private func requestNotificationAuthorization(application: UIApplication) {
        // Ask for notifiction permission
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests() // not sure if this is right
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            // TODO: if !granted, tell user they can change notification settings later on
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        requestNotificationAuthorization(application: application)
        
        let defaults = UserDefaults.standard
        let defaultValue = ["numFails" : "0", "newPassword":""]
        defaults.register(defaults: defaultValue)
        CognitoHelper.newPassword = defaults.value(forKey: "newPassword") as! String
        print(CognitoHelper.newPassword)
        print(defaults.value(forKey: "numFails"))
        
        AWSMobileClient.default().initialize { (userState, error) in
            if let userState = userState {
                print("UserState: \(userState.rawValue)")
            } else if let error = error {
                print("error: \(error.localizedDescription)")
            }
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        let defaults = UserDefaults.standard
        defaults.set(CognitoHelper.numFails, forKey: "numFails")
        defaults.set(CognitoHelper.newPassword, forKey: "newPassword")
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }


}

extension AWSMobileClientError {
    var message: String {
    switch self {
    case .aliasExists(let message),
         .badRequest(let message),
         .codeDeliveryFailure(let message),
         .codeMismatch(let message),
         .cognitoIdentityPoolNotConfigured(let message),
         .deviceNotRemembered(let message),
         .errorLoadingPage(let message),
         .expiredCode(let message),
         .expiredRefreshToken(let message),
         .federationProviderExists(let message),
         .groupExists(let message),
         .guestAccessNotAllowed(let message),
         .idTokenAndAcceessTokenNotIssued(let message),
         .idTokenNotIssued(let message),
         .identityIdUnavailable(let message),
         .internalError(let message),
         .invalidConfiguration(let message),
         .invalidLambdaResponse(let message),
         .invalidOAuthFlow(let message),
         .invalidParameter(let message),
         .invalidPassword(let message),
         .invalidState(let message),
         .invalidUserPoolConfiguration(let message),
         .limitExceeded(let message),
         .mfaMethodNotFound(let message),
         .notAuthorized(let message),
         .notSignedIn(let message),
         .passwordResetRequired(let message),
         .resourceNotFound(let message),
         .scopeDoesNotExist(let message),
         .securityFailed(let message),
         .softwareTokenMFANotFound(let message),
         .tooManyFailedAttempts(let message),
         .tooManyRequests(let message),
         .unableToSignIn(let message),
         .unexpectedLambda(let message),
         .unknown(let message),
         .userCancelledSignIn(let message),
         .userLambdaValidation(let message),
         .userNotConfirmed(let message),
         .userNotFound(let message),
         .userPoolNotConfigured(let message),
         .usernameExists(let message):
        return message
    }
    }
}

