//
//  MailView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 24/02/2025.
//

import SwiftUI
import MessageUI

struct MailView: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    
    var recipientEmail: String
    var subject: String
    var body: String
    var senderEmail: String // Add sender's email
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailView
        
        init(parent: MailView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        
        // Set the recipient email
        vc.setToRecipients([recipientEmail])
        
        // Set the subject
        vc.setSubject(subject)
        
        // Include the sender's email in the body
        vc.setMessageBody("From: \(senderEmail)\n\n\(body)", isHTML: false)
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}

