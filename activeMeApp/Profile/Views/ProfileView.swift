//
//  ProfileView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 02/02/2025.
//

import SwiftUI
import MessageUI

struct ProfileView: View {
    @AppStorage("profileName") var profileName: String?
    @AppStorage("profileAvatar") var profileAvatar: String?
    @AppStorage("profileEmail") var profileEmail: String?

    @State private var isEditingAvatar = false
    @State private var selectedAvatar: String?
    @State private var isEditingName = false
    @State private var newName: String = ""
    @State private var showDeleteAlert = false
    @State private var showSignOutAlert = false
    @State private var showMailView = false

    
    @EnvironmentObject var viewModel: AuthViewModel
    
    @State private var avatars = ["woman", "woman(1)", "woman(2)", "woman(3)", "man", "man(1)", "man(2)", "man(3)"]
    
    var body: some View {
        NavigationStack {
            
        if let user = viewModel.currentUser {
            VStack {
                HStack(spacing: 4) {
                    Image(profileAvatar ?? "woman")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90)
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray)
                            .opacity(0.1))
                        .padding(.leading, -0)
                        .onTapGesture {
                            withAnimation {
                                isEditingName = false
                                isEditingAvatar = true
                            }
                        }
                        .padding(5)
                    
                    
                    VStack(alignment: .leading) {
                        Text(user.profileName)
                            .font(.title)
                            .onTapGesture {
                                withAnimation {
                                    isEditingName = true
                                    isEditingAvatar = false
                                }
                            }
                        
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.trailing, 0)
                    
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
                            Task {
                                await viewModel.updateUserName(newName: newName)
                                isEditingName = false
                                newName = ""
                            }
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
                        
                        // Edit User Name Button
                        ProfileButtonView(image: "square.and.pencil", title: "Edit User Name") {
                            withAnimation {
                                isEditingName = true
                                isEditingAvatar = false
                            }
                        }
                        
                        // Edit Avatar Button
                        ProfileButtonView(image: "square.and.pencil", title: "Edit Avatar") {
                            withAnimation {
                                isEditingName = false
                                isEditingAvatar = true
                            }
                        }
                        
                        // Contact Us Button
                        // Contact Us Button
                        ProfileButtonView(image: "envelope", title: "Contact Us") {
                            if MFMailComposeViewController.canSendMail() {
                                showMailView = true
                            } else {
                                print("Mail services are not available")
                            }
                        }
                        .sheet(isPresented: $showMailView) {
                            MailView(
                                recipientEmail: "taheraaktermukta17@gmail.com",
                                subject: "Contact Us - activeMe App",
                                body: "Hello,\n\nI would like to get in touch regarding...",
                                senderEmail: user.email  // Pass the user's email as sender
                            )
                        }

                        
                        // Privacy Policy Button
                        VStack {
                            NavigationLink {
                                PrivacyView()
                            } label: {
                                HStack {
                                    Image(systemName: "doc.text")
                                        .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                                    Text("Privacy Policy")
                                        .foregroundColor(.black)
                                    
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .background( RoundedRectangle(cornerRadius: 10)
                                .fill(.gray.opacity(0.1)))
                            .padding(.horizontal, 5)
                        }

                        
                        // Terms & Conditions Button
                        VStack {
                            NavigationLink {
                                ConditionView()
                            } label: {
                                HStack {
                                    Image(systemName: "document")
                                        .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                                    Text("Terms & Conditions")
                                        .foregroundColor(.black)
                                    
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .background( RoundedRectangle(cornerRadius: 10)
                                .fill(.gray.opacity(0.1)))
                            .padding(.horizontal, 5)
                        }
                        
                        
                        // Sign Out Button with Alert
                        ProfileButtonView(image: "iphone.and.arrow.forward.outward", title: "Sign Out") {
                            showSignOutAlert = true
                        }
                        .alert(isPresented: $showSignOutAlert) {
                            Alert(
                                title: Text("Sign Out"),
                                message: Text("Are you sure you want to sign out from this account?"),
                                primaryButton: .destructive(Text("Sign Out")) {
                                    viewModel.signOut()
                                },
                                secondaryButton: .cancel()
                            )
                        }
                        
                        // Delete Account Button with Alert
                        ProfileButtonView(image: "trash.square", title: "Delete Account") {
                            showDeleteAlert = true
                        }
                        .alert(isPresented: $showDeleteAlert) {
                            Alert(
                                title: Text("Delete Account"),
                                message: Text("Are you sure you want to delete your account? This action cannot be undone."),
                                    primaryButton: .destructive(Text("Delete")) {
                                        Task {
                                            await viewModel.deleteAccount()
                                        }
                                    },
                                    secondaryButton: .cancel()
                            )
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .onAppear {
                selectedAvatar = profileAvatar
                Task {
                    await viewModel.fetchUserData()
                }
                
            }
            
        } else {
            ProgressView()
                .onAppear {
                    Task {
                        await viewModel.fetchUserData()
                    }
                }
            }
        }
    }
}




struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthViewModel())
    }
}
