//
//  ProfileView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 02/02/2025.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack {
            HStack(spacing: 15) {
                Image("woman")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90)
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray)
                        .opacity(0.1))
                
                VStack(alignment: .leading) {
                    Text("Tahera Mukta")
                        .font(.title)
                        
                    Text("name.example.com")
                        .font(.headline)
                        .foregroundColor(.gray)
                        
                }
                
            }
            .padding(.bottom, 15)
            
            VStack(spacing: 15) {
                ProfileButtonView(image: "square.and.pencil", title: "Edit User Name") {
                    print("Edit User Name")
                }
                
                ProfileButtonView(image: "square.and.pencil", title: "Edit Avatar") {
                    print("Edit Avatar")
                }
                
                ProfileButtonView(image: "envelope", title: "Contact Us") {
                    print("Contact Us")
                }
                
                ProfileButtonView(image: "document.on.document", title: "Privacy Policy") {
                    print("Privacy Policy")
                }
                
                ProfileButtonView(image: "document", title: "Terms & Conditions") {
                    print("Terms & Conditions")
                }
                
                ProfileButtonView(image: "iphone.and.arrow.forward.outward", title: "Sign Out") {
                    print("Sign Out")
                }
                
                ProfileButtonView(image: "trash.square", title: "Delete Account") {
                    print("Delete Account")
                }
                
                
                
                
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
