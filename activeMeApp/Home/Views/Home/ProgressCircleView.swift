//
//  ProgressCircleView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 02/02/2025.
//

import SwiftUI

struct ProgressCircleView: View {
    var progress: Int
    var goal: Int
    var color: Color
    private let lineWidth: CGFloat = 20
    
    var body: some View {
        // Background circle (faded)
        ZStack {
            Circle()
                .stroke(color.opacity(0.3), lineWidth: lineWidth)
            // Foreground circle showing progress
            Circle()
                .trim(from: 0, to: min(CGFloat(progress) / CGFloat(goal), 1.0)) // Ensure it stays within range
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))    // Start from top
                .shadow(radius: 5)
            
        }
        .padding()
    }
}

struct ProgressCircleView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressCircleView(progress: 8, goal: 12, color: .blue)
    }
    
}
