//
//  NewPasswordView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 12/02/2025.
//

import SwiftUI

struct NewPasswordView: View {
    var body: some View {
        VStack {
                   Spacer().frame(height: 30)
            LottieView(animationName: "dumbbell", width: 150, height: 150)
                .frame(width: 170, height: 120)
                .padding(.bottom, -20)
                .padding(.top, 20)
                   Spacer().frame(height: 30)

                   Text("New Password")
                       .font(.title)
                       .bold()
                       .padding(.bottom, 20)
                       

                   Spacer().frame(height: 50)

                   VStack(alignment: .leading, spacing: 10) {
                       Text("Create New Password")
                           .font(.headline)
                           .bold()

                       SecureField("Enter your new password", text: .constant(""))
                           .textFieldStyle(PlainTextFieldStyle())
                           .padding(.vertical, 10)
                           .overlay(Rectangle().frame(height: 1).foregroundColor(.gray), alignment: .bottom)

                       Spacer().frame(height: 20)

                       Text("Confirm Your Password")
                           .font(.headline)
                           .bold()

                       SecureField("Confirm your new password", text: .constant(""))
                           .textFieldStyle(PlainTextFieldStyle())
                           .padding(.vertical, 10)
                           .overlay(Rectangle().frame(height: 1).foregroundColor(.gray), alignment: .bottom)
                   }
                   .padding(.horizontal, 30)
                   .padding()

                   Spacer().frame(height: 30)

                   Button(action: {}) {
                       HStack {
                           Text("RESET PASSWORD")
                               .font(.headline)
                               .bold()
                           Image(systemName: "arrow.right")
                       }
                       .frame(maxWidth: .infinity)
                       .padding()
                       .background(Color(red: 15/255, green: 174/255, blue: 1/255))
                       .foregroundColor(.white)
                       .cornerRadius(10)
                   }
                   .padding(.horizontal, 30)

                   Spacer()

                   HStack {
                       Text("Remember your password?")
                       Text("Sign In")
                           .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                           .bold()
                   }
                   .font(.system(size: 14))

                   Spacer().frame(height: 20)
               }
    }
}

#Preview {
    NewPasswordView()
}
