//
//  PresentAlert.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 14/03/2025.
//

import Foundation
import SwiftUI

// MARK: Pressent an aleart from anywhere in my app

// Useful when triggered from a non-UI context (e.g., network or background handlers).
func presentAlert(title: String, message: String) {
  let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
  let ok = UIAlertAction(title: "OK", style: .default)
  alert.addAction(ok)
  rootController?.present(alert, animated: true)
}

// Returns the top-most view controller currently being displayed in the app window.
/// Used for presenting alerts when no specific view context is available.
var rootController: UIViewController? {
  var root = UIApplication.shared.windows.first?.rootViewController
    // Navigate through any presented view controllers
  if let presenter = root?.presentedViewController {
      root = presenter
  }
  return root
}
