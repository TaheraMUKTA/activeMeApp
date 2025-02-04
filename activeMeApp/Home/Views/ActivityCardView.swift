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
                    VStack(alignment: .leading, spacing: 8) {
                        Text(activity.title)
                            .font(.headline)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        Text(activity.subtitle)
                            .font(.caption)
                    }
                    Spacer()
                    
                    Image(systemName: activity.image)
                        .foregroundColor(activity.tintColor)
                        
                    
                }
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
