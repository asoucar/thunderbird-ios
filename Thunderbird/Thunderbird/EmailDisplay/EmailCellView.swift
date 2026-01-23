//
//  EmailCell.swift
//  Thunderbird
//
//  Created by Ashley Soucar on 10/17/25.
//

import SwiftUI

struct EmailCellView: View {
    let senderText: String
    let headerText: String
    let bodyText: String
    let dateSent: Date

    // For alignment, bool check likely not final
    let unread: Bool
    let newEmail: Bool
    let hasAttachment: Bool
    let isThread: Bool

    init(email: TempEmail) {
        self.senderText = email.senderText
        self.headerText = email.headerText
        self.bodyText = email.bodyText
        self.dateSent = email.dateSent
        self.unread = email.unread
        self.newEmail = email.newEmail
        self.hasAttachment = email.attachments != nil
        self.isThread = email.isThread
    }

    //Doesn't display times properly yes
    func dateFormatter(date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return date.formatted(date: .omitted, time: .shortened)
        } else {
            let relativeDateFormatter = DateFormatter()
            relativeDateFormatter.timeStyle = .none
            relativeDateFormatter.dateStyle = .medium
            relativeDateFormatter.doesRelativeDateFormatting = true
            return relativeDateFormatter.string(from: date)
        }

    }

    var body: some View {
        HStack {
            if newEmail {
                Image(systemName: "circle")
                    .foregroundStyle(.accent)
                    .font(.system(size: 8))
            } else if unread {
                Image(systemName: "circle.fill")
                    .foregroundStyle(.accent)
                    .font(.system(size: 8))
            } else {
                Spacer(minLength: 20)
            }
            VStack(alignment: .leading) {
                HStack {
                    Text(senderText)
                        .lineLimit(1)
                        .font(.headline)
                        .fontWeight(unread ? .semibold : .regular)
                    Spacer()
                    Text(dateFormatter(date: dateSent))
                        .lineLimit(1)
                        .font(.footnote)
                        .truncationMode(.tail)
                        .foregroundColor(.muted)
                }
                HStack {
                    Text(headerText)
                        .lineLimit(1)
                        .font(.subheadline)
                        .fontWeight(unread ? .semibold : .regular)
                    Spacer()
                    if hasAttachment {
                        Image(systemName: "paperclip")
                            .foregroundColor(.muted)
                    }
                    if isThread {
                        Text("99+")
                            .font(.caption2)
                            .padding(.horizontal, 5)
                            .foregroundColor(.muted)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(lineWidth: 1)
                                    .foregroundColor(.muted)
                            )

                    }

                }

                Text(bodyText)
                    .lineLimit(1)
                    .foregroundColor(.muted)
                    .font(.footnote)
            }
        }

    }
}

#Preview("Email Cell") {
    let tempEmail = TempEmail(
        sender: "Sender5",
        recipients: ["Rhea"],
        headerText: "Email four with a longer set of text",
        bodyText: "This is some nice long text",
        dateSent: Date(),
        unread: true,
        newEmail: false,
        attachments: nil,
        isThread: true
    )
    EmailCellView(email: tempEmail)

}
