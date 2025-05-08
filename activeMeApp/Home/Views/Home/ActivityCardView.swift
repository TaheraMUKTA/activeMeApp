//
//  ActivityCardView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 02/02/2025.
//

import SwiftUI

struct ActivityCardView: View {
    @State var activity: Activity
    var body: some View {
        ZStack {
            Color(uiColor: .systemGray6)
                .cornerRadius(15)
            VStack {
                HStack(alignment: .top) {
                    // Title and subtitle on left
                    VStack(alignment: .leading, spacing: 8) {
                        Text(activity.title)    // e.g. "Today Steps"
                            .font(.headline)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        Text(activity.subtitle)    // e.g. "Goal: 12,000"
                            .font(.caption)
                    }
                    Spacer()
                    
                    // Icon on the right side
                    Image(systemName: activity.image)
                        .foregroundColor(activity.tintColor)
                }
                
                // Main amount shown in bold (e.g. step count)
                Text(activity.amount)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
            }
            .padding()
        }
    }
}

struct ActivityCardView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityCardView(activity: Activity(title: "Today Steps", subtitle: "Goal 12,000", image: "figure.walk", tintColor: .green, amount: "6850"))
    }
}
