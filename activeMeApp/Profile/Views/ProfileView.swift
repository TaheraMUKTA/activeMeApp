//
//  ProfileView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 02/02/2025.
//

import SwiftUI
import MessageUI
import RevenueCat


struct ProfileView: View {
    // Persistent storage for user details
    @AppStorage("profileName") var profileName: String?
    @AppStorage("profileAvatar") var profileAvatar: String?
    @AppStorage("profileEmail") var profileEmail: String?
    @AppStorage("isPremiumUser") var isPremiumUser: Bool = false
    //let isPremiumUser = true

    // UI control states
    @State private var isEditingAvatar = false
    @State private var selectedAvatar: String?
    @State private var isEditingName = false
    @State private var newName: String = ""
    @State private var showDeleteAlert = false
    @State private var showSignOutAlert = false
    @State private var showMailView = false
    @State private var showMailErrorAlert = false
    @State private var showLaunchingMailAppAlert = false
    @State private var mailURL: URL? = nil
    @State private var showMailSuccessAlert = false
    @State private var showingCancelAlert = false
    
    // ViewModel and Environment
    @StateObject var profileViewModel = ProfileViewModel()
    @EnvironmentObject var viewModel: AuthViewModel
    
    // Available avatars
    @State private var avatars = ["woman", "woman(1)", "woman(2)", "woman(3)", "man", "man(1)", "man(2)", "man(3)"]
    
    var body: some View {
        NavigationStack {
            // Check if user is logged in
            if let user = viewModel.currentUser {
                VStack {
                    // MARK: - User Profile Header
                    HStack(spacing: 4) {
                        // Avatar
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
                            // User Name
                            Text(user.profileName)
                                .font(.title)
                                .onTapGesture {
                                    withAnimation {
                                        isEditingName = true
                                        isEditingAvatar = false
                                    }
                                }
                            // User Email
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.trailing, 0)
                        
                    }
                    .padding(.bottom, 5)
                    
                    // MARK: - Profile Content Area
                    ScrollView(showsIndicators: false) {
                        // Name editing UI
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
                        
                        // Avatar editing UI
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
                                    Task {
                                        if let newAvatar = selectedAvatar {
                                            await viewModel.updateUserDetails(name: nil, height: nil, weight: nil, profileAvatar: newAvatar)
                                            profileAvatar = newAvatar
                                        }
                                        isEditingAvatar = false
                                    }
                                }
                            }
                        }
                        
                        // MARK: - Profile Actions
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
                            
                            // User Details
                            VStack {
                                NavigationLink(destination: {
                                    if let user = viewModel.currentUser {
                                        UserDetailsView(user: user)
                                    } else {
                                        Text("No user data found")
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "person.text.rectangle")
                                            .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                                        Text("User Details")
                                            .foregroundColor(.primary)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(RoundedRectangle(cornerRadius: 10)
                                        .fill(.gray.opacity(0.1)))
                                    .padding(.horizontal, 5)
                                }
                            }
                            
                            // Contact Us Button
                            ProfileButtonView(image: "envelope", title: "Contact Us") {
                                if let encodedSubject = "Contact Us - activeMe App".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                                   let encodedBody = "Hello,\n\nI would like to get in touch regarding...".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                                   let url = URL(string: "mailto:taheraaktermukta17@gmail.com?subject=\(encodedSubject)&body=\(encodedBody)") {
                                    
                                    if UIApplication.shared.canOpenURL(url) {
                                        
                                        showLaunchingMailAppAlert = true
                                        mailURL = url // Save it to use after user taps "Continue"
                                    } else {
                                        showMailErrorAlert = true
                                    }
                                } else {
                                    showMailErrorAlert = true
                                }
                            }
                            .alert("Mail Not Available", isPresented: $showMailErrorAlert) {
                                Button("OK", role: .cancel) {}
                            } message: {
                                Text("Your device couldn't open the Mail app. Please try again later or configure an email app.")
                            }
                            .alert("Ready to Contact", isPresented: $showLaunchingMailAppAlert) {
                                Button("Continue") {
                                    if let url = mailURL {
                                        UIApplication.shared.open(url)
                                    }
                                }
                                Button("Cancel", role: .cancel) {}
                            } message: {
                                Text("We'll open your default Mail app to send your message.")
                            }
                            
                            // Privacy Policy Button
                            let adaptiveColor = Color(UIColor { traitCollection in
                                return traitCollection.userInterfaceStyle == .dark ? .white : .black
                            })
                            VStack {
                                NavigationLink {
                                    PrivacyView()
                                } label: {
                                    HStack {
                                        Image(systemName: "doc.text")
                                            .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                                        Text("Privacy Policy")
                                            .foregroundColor(adaptiveColor)
                                        
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
                                            .foregroundColor(adaptiveColor)
                                        
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
                            
                            // Show Cancel Subscription button only if the user is premium
                            if isPremiumUser {
                                ProfileButtonView(image: "xmark.circle", title: "Cancel Subscription") {
                                    showingCancelAlert = true
                                }
                                .alert("Manage Your Subscription", isPresented: $showingCancelAlert) {
                                    Button("Cancel", role: .destructive) {
                                        Task {
                                            // Optionally open the Apple Subscriptions page
                                            if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                                await UIApplication.shared.open(url)
                                            }
                                        }
                                    }
                                    
                                    Button("Keep", role: .cancel) {}
                                } message: {
                                    Text("Are you sure you want to cancel your subscription? You will be redirected to Apple’s subscription page.")
                                }
                            }
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .onAppear {
                    selectedAvatar = profileAvatar
                    if profileAvatar == nil {  // Only set if no avatar is stored
                        if let user = viewModel.currentUser {
                            profileAvatar = user.gender.lowercased() == "male" ? "man" : "woman"
                        }
                    }
                    // Fetch latest user and subscription data
                    Task {
                        await viewModel.fetchUserData()
                        // Refresh the subscription from RevenueCat
                        do {
                            let customerInfo = try await Purchases.shared.customerInfo()
                            let isActive = customerInfo.entitlements["Subscription"]?.isActive == true
                            
                            await viewModel.updateSubscriptionStatusInFirestore(isActive: isActive)
                            isPremiumUser = isActive
                        } catch {
                            print("Failed to fetch subscription status: \(error)")
                        }
                    }
                }
            } else {
                // Show loading indicator if user not yet loaded
                ProgressView()
                    .onAppear {
                        Task {
                            await viewModel.fetchUserData()
                            if let user = viewModel.currentUser {
                                profileAvatar = user.profileAvatar
                            }
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
