//
//  ChartDataView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 07/02/2025.
//

import SwiftUI

struct ChartDataView: View {
    @State var average: Int
    @State var total: Int
    
    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 15) {
                Text("Average")
                    .font(.title2)
                Text("\(average)")
                    .font(.title3)
            }
            .padding()
            .frame(width: 130)
            .background(Color.gray.opacity(0.1))
            .foregroundColor(.black)
            .cornerRadius(10)
            
            
            Spacer()
            
            VStack(spacing: 15) {
                Text("Total")
                    .font(.title2)
                Text("\(total)")
                    .font(.title3)
            }
            .padding()
            .frame(width: 130)
            .background(Color.gray.opacity(0.1))
            .foregroundColor(.black)
            .cornerRadius(10)
            
            Spacer()
                
        }
        .padding(.bottom, 40)
    }
}

struct ChartDataView_Previews: PreviewProvider {
    static var previews: some View {
        ChartDataView(average: 01243, total: 8968) 
    }
}
