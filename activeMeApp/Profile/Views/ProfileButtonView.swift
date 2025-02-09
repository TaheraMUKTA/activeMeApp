//
//  ProfileButtonView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 09/02/2025.
//

import SwiftUI

struct ProfileButtonView: View {
    @State var image: String
    @State var title: String
    var action: (() -> Void)
    
    var body: some View {
        VStack {
            Button {
                action()
            } label: {
                HStack {
                    Image(systemName: image)
                        .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                    Text(title)
                        .foregroundColor(.black)
                    
                }
                
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background( RoundedRectangle(cornerRadius: 10)
            .fill(.gray.opacity(0.1)))
        .padding(.horizontal, 5)
        
    }
}

struct ProfileButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileButtonView(image: "square.and.pencil", title: "Edit User Name") {}
    }
}
