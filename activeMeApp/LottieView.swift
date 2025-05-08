//
//  LottieView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 09/02/2025.
//

import SwiftUI
import Lottie

// A SwiftUI wrapper for displaying Lottie animations using UIKit.
struct LottieView: UIViewRepresentable {
    var animationName: String     // Name of the Lottie animation JSON file
    var width: CGFloat
    var height: CGFloat
    
    private let animationView = LottieAnimationView()    // Lottie animation player

    // Creates the UIView that will host the Lottie animation.
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        
        animationView.animation = LottieAnimation.named(animationName)    // Load animation by name
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop    // Repeat indefinitely
        animationView.play()        // Start animation

        // Add animation view inside container
        animationView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(animationView)
        // Constraint the animation to fill the container
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            animationView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        ])

        return containerView
    }

    // Updates the animation view (not used in this case)
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    // Stops the animation when the view is dismantled
    static func dismantleUIView(_ uiView: UIView, coordinator: ()) {
        if let animationView = uiView.subviews.first as? LottieAnimationView {
            animationView.stop()
        }
    }
}
