//
//  KeyboardAvoidingViewController.swift
//  CodingExercise
//
//  Created by Slack Candidate on 2/26/22.
//  Copyright © 2022 slack. All rights reserved.
//

import Foundation
import UIKit

/// A base class that handles subscription to keyboard frame changes.
class KeyboardNotifyingViewController: UIViewController {

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        // Subscribe to keyboard notifications.
        NotificationCenter.default.addObserver(
            self, selector:
                #selector(keyboardWillShow),
            name: UIApplication.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIApplication.keyboardWillHideNotification, object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // Unsubscribe from keyboard notifications.
        NotificationCenter.default.removeObserver(self, name: UIApplication.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.keyboardWillHideNotification, object: nil)
    }

    // MARK: - Private Functions

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        onKeyboardShowing(withFrame: keyboardFrame)
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        onKeyboardHiding()
    }

    // MARK: - Public Functions

    /// Override to be notified of the keyboard frame size when the keyboard is becoming visible.
    /// - Parameter withFrame: The keyboard frame.
    open func onKeyboardShowing(withFrame: CGRect) { }

    /// Override to be notified that the keyboard is hiding.
    open func onKeyboardHiding() { }
}
