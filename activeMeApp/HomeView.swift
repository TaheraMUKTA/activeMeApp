//
//  HomeView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 02/02/2025.
//

import SwiftUI

struct HomeView: View {
    @State var calories: Int = 123
    @State var active: Int = 45
    @State var stand: Int = 8
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                Text("Welcome")
                    .font(.largeTitle)
                    .padding()
                
                HStack {
                    
                    Spacer()
                    
                    VStack{
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Calories")
                                .font(.callout)
                                .bold()
                                .foregroundColor(.red)
                            Text("123 kcal")
                                .bold()
                        }
                        .padding(.bottom)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Active")
                                .font(.callout)
                                .bold()
                                .foregroundColor(.green)
                            Text("45 mins")
                                .bold()
                        }
                        .padding(.bottom)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Stand")
                                .font(.callout)
                                .bold()
                                .foregroundColor(.blue)
                            Text("8 hours")
                                .bold()
                        }
                        .padding(.bottom)
                        
                    }
                    Spacer()
                    
                    ZStack {
                        ProgressCircleView(progress: $calories, goal: 600, color: .red)
                        ProgressCircleView(progress: $active, goal: 60, color: .green)
                            .padding(.all, 20)
                        ProgressCircleView(progress: $stand, goal: 12, color: .blue)
                            .padding(.all, 40)
                        
                    }
                    .padding(.horizontal)
                    Spacer()
                }
                .padding()
            }
            
        }
    }
}

#Preview {
    HomeView()
}
