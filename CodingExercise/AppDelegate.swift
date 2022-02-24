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

        let dataProvider = UserSearchResultDataProvider(slackAPI: SlackApi.shared)
        let viewModel = AutocompleteViewModel(dataProvider: dataProvider)

        let autocompleteViewController = AutocompleteViewController(viewModel: viewModel)
        window?.makeKeyAndVisible()
        window?.backgroundColor = UIColor.white
        window?.rootViewController = autocompleteViewController
        return true
    }
}
