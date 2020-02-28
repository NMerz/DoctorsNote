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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        
//        let credentialsProvider = AWSCognitoCredentialsProvider(
//            regionType: .USEast2,
//            identityPoolId: "us-east-2:3980383c-3915-4eb1-839f-9254a7358ec6")
//        let configuration = AWSServiceConfiguration(
//            region: .USEast2,
//            credentialsProvider: credentialsProvider)
//        AWSServiceManager.default().defaultServiceConfiguration = configuration
//
        AWSMobileClient.default().initialize { (userState, error) in
            if let userState = userState {
                print("UserState: \(userState.rawValue)")
            } else if let error = error {
                print("error: \(error.localizedDescription)")
            }
        }
////        AWSMobileClient.default().getAWSCredentials { (credentials, error) in
////            if let error = error as? AWSMobileClientError {
////                print("\(error.message)")
////            } else if let credentials = credentials {
////                print(credentials.accessKey)
////            }
////        }
//
//
<<<<<<< HEAD
        AWSMobileClient.default().signOut()
        var signInWaiter = DispatchSemaphore(value: 0)
        if (!AWSMobileClient.default().isSignedIn) {
            AWSMobileClient.default().signIn(username: "hardin30@purdue.edu", password: "DoctorsNote1@") { (signInResult, error) in
                if let error = error as? AWSMobileClientError {
                    print("\(error.message)")
                } else if let signInResult = signInResult {
                    switch (signInResult.signInState) {
                    case .signedIn:
                        print("User is signed in.")
                    case .smsMFA:
                        print("SMS message sent to \(signInResult.codeDetails!.destination!)")
                    case .newPasswordRequired:
                        print("New password required")
                    default:
                        print("Sign In needs info which is not yet supported.")
                    }
                    //print(signInResult.codeDetails!)
                }
                signInWaiter.signal()
            }
        } else {
            signInWaiter.signal()
        }

        signInWaiter.wait()
        AWSMobileClient.default().getUserAttributes { (dict, _) in
            for attribute in dict! {
                print(attribute)
            }
        }
//        let authorizedConnector = Connector()
//        AWSMobileClient.default().getTokens(authorizedConnector.setToken(potentialTokens:potentialError:))
//        let processor = ConnectionProcessor(connector: authorizedConnector)
//        let (data, error) = processor.processConversationList(url: "https://ro9koaka0l.execute-api.us-east-2.amazonaws.com/deploy/APITest")
        
        
        
//        //print(error!.getMessage())
//        print(data!)
        
=======
        
//        if (!AWSMobileClient.default().isSignedIn) {
//            AWSMobileClient.default().signIn(username: "hardin30@purdue.edu", password: "DoctorsNote1@") { (signInResult, error) in
//                if let error = error as? AWSMobileClientError {
//                    print("\(error.message)")
//                } else if let signInResult = signInResult {
//                    switch (signInResult.signInState) {
//                    case .signedIn:
//                        print("User is signed in.")
//                    case .smsMFA:
//                        print("SMS message sent to \(signInResult.codeDetails!.destination!)")
//                    case .newPasswordRequired:
//                        print("New password required")
//                    default:
//                        print("Sign In needs info which is not yet supported.")
//                    }
//                }
//            }
//        } else {
//            AWSMobileClient.default().signOut()
//            
//        }
//            
//        
>>>>>>> origin/dev
//        AWSMobileClient.default().addUserStateListener(self) { (userState, info) in
//            switch (userState) {
//            case .guest:
//                print("user is in guest mode.")
//            case .signedOut:
//                print("user signed out")
//            case .signedIn:
//                print("user is signed in.")
//            case .signedOutUserPoolsTokenInvalid:
//                print("need to login again.")
//            case .signedOutFederatedTokensInvalid:
//                print("user logged in via federation, but currently needs new tokens")
//            default:
//                print("unsupported")
//            }
//        }
        
//        let dynamoDB = AWSDynamoDB.default()
//        let listTableInput = AWSDynamoDBListTablesInput()
//        dynamoDB.listTables(listTableInput!).continueWith { (task:AWSTask<AWSDynamoDBListTablesOutput>) -> Any? in
//            if let error = task.error as? NSError {
//            print("Error occurred: \(error)")
//                return nil
//            }
//
//            let listTablesOutput = task.result
//
//            for tableName in listTablesOutput!.tableNames! {
//                print("\(tableName)")
//            }
//
//            return nil
//        }
//
//        print(AWSMobileClient.default().currentUserState)
        
        return true
    }

    // MARK: UISceneSession Lifecycle

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


}

