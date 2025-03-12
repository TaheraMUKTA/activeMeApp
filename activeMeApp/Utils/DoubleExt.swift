//
//  DoubleExt.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 12/03/2025.
//

import Foundation

extension Double {
    
    func formattedNumberString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        
        return formatter.string(from: NSNumber(value: self)) ?? "0"
    }
}
