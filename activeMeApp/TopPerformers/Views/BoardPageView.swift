//
//  BoardPageView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 07/02/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// View shown when the user enters the Top Performers leaderboard for the first time.
struct BoardPageView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showLottie = false
    
    @AppStorage("acceptedTerms") var acceptedTerms: Bool = false
    
    
    @AppStorage("profileName") var profileName: String?
    
    @State var name = ""        // Holds user input for name
    @State private var showTerms = false    // Toggles terms & conditions modal
    @Binding var showPage: Bool
    
    var body: some View {
        // Adaptive color for dark/light mode
        let adaptiveColor = Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : .black
        })
        
        NavigationStack {
            VStack {
                Spacer().frame(height: 70)
                // MARK: - Lottie Animation
                if showLottie {
                    LottieView(animationName: "dumbbell", width: 150, height: 150)
                        .frame(width: 170, height: 120)
                        .padding(.bottom, -20)
                        .padding(.top, -40)
                    
                }
                // Title
                Text("Top Performers")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 30)
                
                Spacer().frame(height: 120)
                
                // MARK: - Name Input Field
                TextField("Enter your name", text: $name)
                    .padding()
                    .padding(.horizontal, 30)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(style: StrokeStyle(lineWidth: 2))
                            .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255)))
                    .padding(.bottom, 30)
                
                // MARK: - Terms Agreement
                HStack(alignment: .top) {
                    // Toggle checkbox
                    Button {
                        withAnimation {
                            acceptedTerms.toggle()
                        }
                    } label: {
                        if acceptedTerms {
                            Image(systemName: "checkmark.square.fill")
                                .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                        } else {
                            Image(systemName: "square")
                                .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                        }
                    }
                    // Terms and Conditions text with link
                    VStack(alignment: .leading) {
                        NavigationLink(destination: ConditionView()) {
                            Text("By checking this check box you agree to the terms and conditions to enter into the Top Performers competition.")
                                .foregroundColor(adaptiveColor)
                        }
                        
                    }
                    .padding(.horizontal, 10)
                    .frame(width: 290, height: 90, alignment: .leading)
                }
                .padding(.horizontal, 10)
                
                Spacer().frame(height: 110)
                
                // MARK: - Continue Button
                Button {
                    Task {
                        guard let user = Auth.auth().currentUser else { return }
                        let userId = user.uid
                        // Update Firestore with user profile name
                        let userRef = Firestore.firestore().collection("users").document(userId)
                        try? await userRef.setData(["profileName": name], merge: true)
                        // Persist name locally and dismiss onboarding
                        profileName = name
                        DispatchQueue.main.async {
                            UserDefaults.standard.set(true, forKey: "acceptedTerms")
                            UserDefaults.standard.synchronize()
                            acceptedTerms = true
                            showPage = false
                            dismiss()
                        }
                    }
                } label: {
                    Text("Continue")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 15/255, green: 174/255, blue: 1/255))
                        .foregroundColor(.white)
                        .bold()
                        .cornerRadius(10)
                        .padding()
                }
                .disabled(!formIsValid)          // Disable button if form is invalid
                .opacity(formIsValid ? 1 : 0.5)

            }
            .padding(.horizontal)
            .padding(.bottom, 50)
            .onAppear {
                // Delay animation to avoid rendering issue
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showLottie = true
                }
            }
            .sheet(isPresented: $showTerms) {
                ConditionView()
            }
        }
        
    }
    // Name must be at least 3 characters & terms must be accepted
    var formIsValid: Bool {
        return acceptedTerms && name.count > 2
    }
}


struct BoardPageView_Previews: PreviewProvider {
    static var previews: some View {
        BoardPageView(showPage: .constant(true))
    }
}
