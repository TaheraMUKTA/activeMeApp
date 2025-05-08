//
//  ConditionView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 12/02/2025.
//

import SwiftUI

struct ConditionView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                // Title
                Text("Our Terms & Conditions")
                    .font(.title)
                    .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                    .padding(.top, 5)
            }
            
            VStack(alignment: .leading, spacing: 15) {
                
                // Last Updated Date
                Text("Last Updated: [28/12/2024]")
                    .font(.subheadline)
                    .foregroundColor(.gray.opacity(0.9))
                    .padding(.bottom, 10)
                
                // Intro Text
                Text("""
                    By using activeMe, you agree to these Terms. If you do not agree, please do not use the app.
                    """)
                    .font(.body)
                    .padding(.bottom, 10)
                
                // 1. Use of the App
                Text("1. Use of the App:")
                    .font(.headline)
                    .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                    .fontWeight(.bold)
                
                Text("""
                    • The App tracks fitness activities and provides health insights.
                    • It is not a substitute for professional medical advice.
                    • You must be at least 16 years old to use it.
                    """)
                    .font(.body)
                    .padding(.bottom, 10)
                
                // 2. Accounts & Privacy
                Text("2. Accounts & Privacy:")
                    .font(.headline)
                    .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                    .fontWeight(.bold)
                
                Text("""
                    • You are responsible for your account security.
                    • We collect and process data as outlined in our [Privacy Policy].
                    """)
                    .font(.body)
                    .padding(.bottom, 10)
                
                // 3. Limitation of Liability
                Text("3. Limitation of Liability:")
                    .font(.headline)
                    .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                    .fontWeight(.bold)
                
                Text("""
                    • We do not guarantee the accuracy of health data.
                    • Use the App at your own risk; we are not liable for injuries or health issues.
                    """)
                    .font(.body)
                    .padding(.bottom, 10)
                
                // 4. Changes & Contact
                Text("4. Changes & Contact:")
                    .font(.headline)
                    .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                    .fontWeight(.bold)
                
                Text("""
                    • Terms may be updated; continued use means acceptance.
                    • Questions? Contact us at 
                    """)
                    .font(.body)
                    .padding(.bottom, 10)
                // Contact Button (opens email)
                Button {
                    if let url = URL(string: "mailto:taheraaktermukta17@gmail.com") {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    }
                } label: {
                    Text("active.me@gmail.com")
                        .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                        .underline()
                }
                
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
        ConditionView()
    }
}
