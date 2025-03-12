//
//  BoardPageView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 07/02/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct BoardPageView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showLottie = false
    @AppStorage("acceptedTerms") var acceptedTerms: Bool = false
    @AppStorage("profileName") var profileName: String?
    
    @State var name = ""
    @State private var showTerms = false
    @Binding var showPage: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer().frame(height: 70)
                
                if showLottie {
                    LottieView(animationName: "dumbbell", width: 150, height: 150)
                        .frame(width: 170, height: 120)
                        .padding(.bottom, -20)
                        .padding(.top, -40)
                    
                }
                
                Text("Top Performers")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 30)
                
                Spacer().frame(height: 120)
                
                TextField("Enter your name", text: $name)
                    .padding()
                    .padding(.horizontal, 30)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(style: StrokeStyle(lineWidth: 2))
                            .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255)))
                    .padding(.bottom, 30)
                
                HStack(alignment: .top) {
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
                    
                    VStack(alignment: .leading) {
                        NavigationLink(destination: ConditionView()) {
                            Text("By checking this check box you agree to the terms and conditions to enter into the Top Performers competition.")
                                .foregroundColor(.black)
                        }
                        
                    }
                    .padding(.horizontal, 10)
                    .frame(width: 290, height: 90, alignment: .leading)
                }
                .padding(.horizontal, 10)
                
                Spacer().frame(height: 110)
                
                Button {
                    Task {
                        guard let user = Auth.auth().currentUser else { return }
                        let userId = user.uid
                        
                        let userRef = Firestore.firestore().collection("users").document(userId)
                        try? await userRef.setData(["profileName": name], merge: true)
                        
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
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1 : 0.5)

            }
            .padding(.horizontal)
            .padding(.bottom, 50)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showLottie = true // Prevents immediate crash
                }
            }
            .sheet(isPresented: $showTerms) {
                ConditionView()
            }
        }
        
    }
    
    var formIsValid: Bool {
        return acceptedTerms && name.count > 2
    }
}


#Preview {
    BoardPageView(showPage: .constant(true))
}
