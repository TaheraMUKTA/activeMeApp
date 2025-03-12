//
//  DetailsRowView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 12/03/2025.
//

import SwiftUI

struct DetailsRowView: View {
    let title: String
    let value: String
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.bold)
                .font(.headline)
                .foregroundColor(.black)
            
            Spacer()
            Text(value)
                .font(.headline)
                .foregroundColor(.black.opacity(0.6))
            
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}
