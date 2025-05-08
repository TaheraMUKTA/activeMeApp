//
//  MailView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 24/02/2025.
//

import SwiftUI
import MessageUI

// A SwiftUI wrapper to present the native iOS Mail Composer
struct MailView: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    
    var recipientEmail: String
    var subject: String
    var body: String
    var senderEmail: String // Add sender's email
    var onMailSent: (() -> Void)?  // Callback when email is sent
    var onMailFailed: (() -> Void)? // Callback when email fails
    
    // Coordinator to handle delegate methods
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailView
        
        init(parent: MailView) {
            self.parent = parent
        }
        
        // Handle result when user finishes mail composer
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            switch result {
            case .sent:
                parent.onMailSent?()  // Notify ProfileView that the email was sent
            case .failed:
                parent.onMailFailed?() // Notify ProfileView that sending failed
            default:
                break
            }
            controller.dismiss(animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    // Create the Mail Composer View
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

