//
//  AppDelegate.swift
//  CodingExercise
//
//  Copyright © 2021 slack. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)

        // Create the (small) dependency tree.
        let dataProvider = UserSearchResultDataProvider(slackAPI: SlackApi(), denyList: DynamicDenyList())
        let viewModel = AutocompleteViewModel(dataProvider: dataProvider)

        // Create the main view controller and add it to the window.
        let autocompleteViewController = AutocompleteViewController(viewModel: viewModel)
        window?.makeKeyAndVisible()
        window?.backgroundColor = UIColor.white
        window?.rootViewController = autocompleteViewController
        return true
    }
}
