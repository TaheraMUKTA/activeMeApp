//
//  BoardPageView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 07/02/2025.
//

import SwiftUI

struct BoardPageView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("userName") var userName: String?
    @State var name = ""
    @State var accepted = false
    
    var body: some View {
        VStack {
            Text("Champions")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            Spacer()
            
            TextField("Enter your name", text: $name)
                .padding()
                .padding(.horizontal, 30)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(style: StrokeStyle(lineWidth: 2))
                        .foregroundColor(.green))
                .padding(.bottom, 30)
            
            HStack(alignment: .top) {
                Button {
                    withAnimation {
                        accepted.toggle()
                    }
                } label: {
                    if accepted {
                        Image(systemName: "checkmark.square.fill")
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "square")
                            .foregroundColor(.green)
                    }
                }
                
                Text("By checking this box you agree to the terms and conditions to enter into the Champions competition.")
                    .padding(.horizontal, 10)
            }
            
            Spacer()
            
            Button {
                if accepted && name.count > 2 {
                    userName = name
                    dismiss()
                    
                }
                    
                
            } label: {
                Text("Continue")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .background(Color.green)
                    .cornerRadius(10)
                    .padding()
                    
                    
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 50)
        
    }
}

#Preview {
    BoardPageView()
}
