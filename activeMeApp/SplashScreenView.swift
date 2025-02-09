//
//  SplashScreenView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 09/02/2025.
//

import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        VStack {
                    // Now Lottie animation will properly resize
                    LottieView(animationName: "dumbbell", width: 150, height: 150)
                        .frame(width: 200, height: 150)
                        .padding(.bottom, -50)

                    VStack {
                        Text("activeMe")
                            .font(.system(size: 45, weight: .heavy))
                            .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                            .italic()
                        
                        Text("For the Active You")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(red: 201/255, green: 104/255, blue: 8/255))
                            .fontDesign(.serif)
                    }
                    .fontWeight(.bold)
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
            }
}

#Preview {
    SplashScreenView()
}
