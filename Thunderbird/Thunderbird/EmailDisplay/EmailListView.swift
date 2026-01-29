//
//  EmailListView.swift
//  Thunderbird
//
//  Created by Ashley Soucar on 10/20/25.
//

import SwiftUI
import Account

struct EmailListView: View {
    @Environment(Accounts.self) private var accounts: Accounts
    @Environment(\.openURL) private var openURL
    let tempEmails = TempEmail.sampleData

    //Hardcoded for testing
    let attributedString = try? NSMutableAttributedString(
        data: Data(
            """
            <html>
            <body>
            <h2>This is a test email with a bit of text</h2>
            <p>Its doing its best to model how an email might look</p>
            </body>
            </html>
            """.utf8),
        options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil
    )

    func sortEmails() {
        //Not yet implemented
        AlertManager.shared.showAlert = true
        AlertManager.shared.alertTitle = "Sort Emails"
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                if tempEmails.isEmpty {
                    VStack {
                        Text("Your inbox is empty")
                            .padding(.bottom, 5)
                        Text("New messages will appear here as they arrive")
                            .padding(.bottom, 10)
                        Button {

                        } label: {
                            Text("Add another account")
                        }.buttonBorderShape(.capsule)
                            .buttonStyle(.bordered)
                            .foregroundStyle(.black)
                        Spacer()
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(tempEmails) { email in
                        EmailCellView(email: email)
                            .listRowSeparator(.hidden)
                            .background {
                                NavigationLink(value: email) {
                                    EmptyView()
                                }.opacity(0)
                            }
                    }.listStyle(.plain)
                        .navigationDestination(for: TempEmail.self) { tempEmail in
                            //Eventually will pass the email object
                            ReadEmailView(
                                tempEmail
                            )
                        }
                        .scrollContentBackground(.hidden)
                }
                Button {
                    // Action
                } label: {
                    Image("compose")
                        .font(.title.weight(.regular))
                        .padding(.all, 12)
                        .padding(.leading, 5)
                        .background(Color(white: 0.9))
                        .foregroundColor(.muted)
                        .clipShape(Circle())
                }
                .background(.clear)
                .padding()
            }
            .navigationTitle("Inbox")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(
                            "Date",
                            action: {
                                sortEmails()
                            })
                        Button(
                            "Read/unread",
                            action: {
                                sortEmails()
                            })
                        Button(
                            "Attachments",
                            action: {
                                sortEmails()
                            })
                    } label: {
                        Label("Sort", systemImage: "line.3.horizontal.decrease", )
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(
                            "account_sign_out_button",
                            action: {
                                accounts.deleteAccounts()
                            })
                        Button(
                            "donation_support",
                            action: {
                                guard let url = URL(string: "https://www.thunderbird.net/en-US/donate/") else { return }
                                openURL(url)
                            })
                    } label: {
                        Label("Options", systemImage: "ellipsis", )
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink("Settings", destination: FeatureFlagDebugView())
                }
            }
        }

    }
}

#Preview("Email List") {
    @Previewable @State var accounts: Accounts = Accounts()
    EmailListView().environment(accounts)

}
