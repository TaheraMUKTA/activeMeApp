//
//  DetailsRowView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 11/03/2025.
//

import SwiftUI

struct DetailsRowView: View {
    let title: String
    let value: String
    var action: (() -> Void)?
    var body: some View {
        // Adaptive color for dark/light mode
        let adaptiveColor = Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : .black
        })
        HStack {
            Text(title)
                .fontWeight(.bold)
                .font(.headline)
                .foregroundColor(adaptiveColor)
            
            Spacer()
            Text(value)
                .font(.headline)
                .foregroundColor(adaptiveColor.opacity(0.6))
            
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .onTapGesture {
            action?()    // Executes action if set (e.g., open editor)
        }
    }
}

struct DetailsRowView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsRowView(title: "Preview", value: "Preview")
    }
}
