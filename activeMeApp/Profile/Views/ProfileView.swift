//
//  ProfileView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 02/02/2025.
//

import SwiftUI

struct ProfileView: View {
    @AppStorage("profileName") var profileName: String?
    @AppStorage("profileAvatar") var profileAvatar: String?
    @AppStorage("profileEmail") var profileEmail: String?
    
    @State private var isEditingAvatar = false
    @State private var selectedAvatar: String?
    @State private var isEditingName = false
    @State private var newName: String = ""
    @State private var isEditingEmail = false
    
    @State private var avatars = ["woman", "woman(1)", "woman(2)", "woman(3)", "man", "man(1)", "man(2)", "man(3)"]
    
    var body: some View {
        VStack {
            HStack(spacing: 15) {
                Image(profileAvatar ?? "woman")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90)
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray)
                        .opacity(0.1))
                    .padding(.leading, -75)
                    .onTapGesture {
                        withAnimation {
                            isEditingName = false
                            isEditingAvatar = true
                        }
                    }
                
                
                VStack(alignment: .leading) {
                    Text(profileName ?? "Tahera Mukta")
                        .font(.title)
                        .onTapGesture {
                            withAnimation {
                                isEditingName = true
                                isEditingAvatar = false
                            }
                        }
                    
                    Text(profileEmail ?? "name.example.com")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                }
                
            }
            .padding(.bottom, 15)
            
            ScrollView {
            
            if isEditingName {
                TextField("New User Name...", text: $newName)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.green, lineWidth: 2))
                
                HStack(spacing: 25) {
                    ProfileEditButtonView(title: "Cancel", backgroundColor: Color(red: 15/255, green: 174/255, blue: 1/255)) {
                        withAnimation {
                            isEditingName = false
                        }
                    }
                        
                    ProfileEditButtonView(title: "Done", backgroundColor: Color(red: 15/255, green: 174/255, blue: 1/255)) {
                        if !newName.isEmpty {
                            withAnimation {
                                profileName = newName
                                isEditingName = false
                            }
                        }
                    }
                    
                }

            }
                
                
            if isEditingAvatar {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(avatars, id: \.self) { avatar in
                            Button {
                                withAnimation {
                                    selectedAvatar = avatar
                                }
                            } label: {
                                Image(avatar)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 90, height: 90)
                                    .padding()
                            }
                            .overlay(
                                Circle()
                                    .stroke(selectedAvatar == avatar ? Color(red: 15/255, green: 174/255, blue: 1/255) : Color.clear, lineWidth: 3)
                            )
                        }
                    }
                }
                .frame(width: 370, height: 130)
                .background( RoundedRectangle(cornerRadius: 10)
                    .fill(.gray.opacity(0.1)))
                
                HStack(spacing: 25) {
                    
                    ProfileEditButtonView(title: "Cancel", backgroundColor: Color(red: 15/255, green: 174/255, blue: 1/255)) {
                        withAnimation {
                            isEditingAvatar = false
                        }
                    }
                        
                    ProfileEditButtonView(title: "Done", backgroundColor: Color(red: 15/255, green: 174/255, blue: 1/255)) {
                        withAnimation {
                            profileAvatar = selectedAvatar
                            isEditingAvatar = false
                        }
                    }
                        
                }
                
            }
            
                VStack(spacing: 15) {
                    ProfileButtonView(image: "square.and.pencil", title: "Edit User Name") {
                        withAnimation {
                            isEditingName = true
                            isEditingAvatar = false
                        }
                    }
                    
                    ProfileButtonView(image: "square.and.pencil", title: "Edit Avatar") {
                        withAnimation {
                            isEditingName = false
                            isEditingAvatar = true
                        }
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
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            selectedAvatar = profileAvatar
                
            
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
