//
//  PrivacyView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 12/02/2025.
//

import SwiftUI

struct PrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                Text("Our Privacy Policy")
                    .font(.title)
                    .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                    .padding(.top, 5)
            }
            
            VStack(alignment: .leading, spacing: 15) {
                    
                Text("""
                        Please take a moment to read our Privacy Policy to understand how we handle your personal information. As we enhance our services, this policy may be updated, so we encourage you to review it periodically.

                        This Privacy Policy applies to activeMe and its mobile application (collectively, the "App"). It explains how we collect, use, and protect the data you provide while using the App. It also describes your rights and choices regarding your information.
                        """)
                        .font(.body)
                        .padding(.bottom, 10)
                        
                    Text("Information Collection:")
                        .font(.headline)
                        .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                        .fontWeight(.bold)
                        
                    Text("""
                        We may collect personal information such as your name, email, and health-related data (e.g., steps, workouts, activities).
                        """)
                        .font(.body)
                        .padding(.bottom, 10)
                        
                    Text("How We Use Your Information:")
                        .font(.headline)
                        .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                        .fontWeight(.bold)
                        
                    Text("""
                        • To provide and improve app features.
                        • To track your health and fitness progress.
                        """)
                        .font(.body)
                        .padding(.bottom, 10)
                        
                    Text("Data Security & Sharing:")
                        .font(.headline)
                        .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                        .fontWeight(.bold)
                        
                    Text("""
                        • Your data is encrypted and stored securely.
                        • We do not sell your personal information.
                        """)
                        .font(.body)
                        .padding(.bottom, 10)
                        
                    Spacer()
                }
                .padding(20)
                .lineSpacing(10)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
}

#Preview {
    NavigationStack {
        PrivacyView()
    }
}
