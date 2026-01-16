//
//  ReadEmailView.swift
//  Thunderbird
//
//  Created by Ashley Soucar on 10/20/25.
//

import SwiftUI
import WebKit

struct ReadEmailView: View {
    init(_ email: TempEmail) {

        self.email = email

        self.emailBody = email.bodyText
        self.sender = email.senderText
        self.subject = email.headerText
        self.sentDate = email.dateSent
        self.recipients = email.recipients
        self.attachments = email.attachments
    }
    private var email: TempEmail
    private var emailBody: String
    private var sender: String
    private var recipients: [String]
    private var subject: String
    private var sentDate: Date
    private var attachments: [Data]!


    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text(subject)
                    .font(.title3)
                ScrollView{
                    VStack(alignment: .leading){
                        SenderView(sender, sentDate, recipients)
                        WebView(htmlString: emailBody).scaledToFill()
                        if(attachments != nil){
                            AttachmentBlockView(attachments)
                        }
                    }
                }

            }.padding()
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            AlertManager.shared.showAlert = true
                            AlertManager.shared.alertTitle = "Archive"
                        }) {
                            Image(systemName: "archivebox")
                                .foregroundStyle(.foreground)
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            AlertManager.shared.showAlert = true
                            AlertManager.shared.alertTitle = "More Options"
                        }) {
                            Image(systemName: "ellipsis")
                                .foregroundStyle(.foreground)
                        }
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Button(action: {
                            AlertManager.shared.showAlert = true
                            AlertManager.shared.alertTitle = "Reply"
                        }) {
                            Image(systemName: "arrowshape.turn.up.left")
                                .foregroundStyle(.foreground)
                        }
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Button(action: {
                            AlertManager.shared.showAlert = true
                            AlertManager.shared.alertTitle = "Reply All"
                        }) {
                            Image(systemName: "arrowshape.turn.up.left.2")
                                .foregroundStyle(.foreground)
                        }
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Button(action: {
                            AlertManager.shared.showAlert = true
                            AlertManager.shared.alertTitle = "Trash"
                        }) {
                            Image(systemName: "trash")
                                .foregroundStyle(.foreground)
                        }
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Button(action: {
                            AlertManager.shared.showAlert = true
                            AlertManager.shared.alertTitle = "Forward"
                        }) {
                            Image(systemName: "arrowshape.turn.up.right")
                                .foregroundStyle(.foreground)
                        }
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Button(action: {
                            AlertManager.shared.showAlert = true
                            AlertManager.shared.alertTitle = "More"
                        }) {
                            Image(systemName: "ellipsis")
                                .foregroundStyle(.foreground)
                        }
                    }
                }
        }
    }
}

struct AttachmentBlockView: View {
    init(_ attachments: [Data]) {
        self.attachments = attachments
    }
    private var attachments: [Data]
    var body: some View {
        VStack(alignment:.leading){
            Text("^[\(attachments.count) attachment](inflect: true)")
                .font(.footnote)
            ForEach(attachments, id: \.self){_ in
                SingleAttachment()
            }
        }

    }
}

struct SingleAttachment: View {
    init() {
        //Do Stuff
    }
    var body: some View {
        HStack(){
            Image(systemName: "photo")
                .resizable()
                .frame(width: 56, height: 44)
                .foregroundStyle(.gray)
            VStack(alignment: .leading){
                Text("rockFlying.png")
                Text("1.78 MB")
            }.font(.footnote)
        }
    }
}

struct WebView: UIViewRepresentable {
    let htmlString: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
}

struct SenderView: View {
    init(_ sender: String, _ sentDate: Date, _ recipients: [String]) {
        self.sender = sender
        self.date = sentDate
        self.recipients = recipients
    }
    private var sender: String
    private var recipients:[String]
    private var date: Date
    @State private var showingAlert = false
    @State private var unimplementedFeatureName: String = ""

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack() {
                    Text(sender).font(.title3)
                }
                HStack{
                    Text("To: \(recipients[0])")
                    if(recipients.count > 1) {
                        Text("+\(recipients.count-1)")
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.accent)

            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(date, style: .date)
                    .font(.footnote)
                    .padding(.bottom, 4)
                Button(action: {
                    //Options
                    AlertManager.shared.showAlert = true
                    AlertManager.shared.alertTitle = "More Options"
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(.foreground)
                }
            }

        }
    }
}

#Preview {
    var tempEmail = TempEmail(
        sender: "Sender@sender.com",
        recipients: ["Rhea Thunderbird", "Roc"],
        headerText: "This is the subject line of the email",
        bodyText: """
            <!DOCTYPE html>
            <html style=3D"width: 100%;
            =09=09=09background-color: #fff;">

            <head>
                <meta charset=3D"UTF-8">
            </head>

            <body style=3D"width: 100%;
                             margin: 0;
                             padding: 0;
                             font-family: Helvetica, Arial, sans-serif;
                             font-size: 16px;
                             line-height: 19px;">
                <div style=3D"text-align: left; margin: 72px 0 24px 0; padding: 0 6%">
                    <img src=3D"https://cdn.zeplin.io/assets/webapp/img/emailAssets/log=
            oZeplin@96w.png" style=3D"width: 66px;">
                </div>
                <div style=3D"padding: 0 6%">
                    <p style=3D"margin: 0 0 48px 0;
            color: #574751; font-size: 36px; line-height: 42px; font-weight: 300;">Appr=
            oval requested</p>
                    <p style=3D"margin: 24px 0 0; color: #574751;">
                        Laurel has requested an approval from you for a group of screen=
            s.
                    </p>

                    <div style=3D"
                    margin: 48px 0;
                    width: 456px;
                    height: auto;
                    background-color: #f7f7f7;
                    padding: 24px;
                    overflow: hidden;
                    border-width: 1px;
                    border-radius: 4px;">
                        <div>
                            <div style=3D"display: flex; flex-wrap: wrap; height: 26px;=
            ">
                                <p style=3D"margin-top: 0;">
                                    <span style=3D"color: #554d56; font-weight: 600;">i=
            OS Alpha screens</span>
                                </p>
                                <div
                                    style=3D"display:flex; align-items: center; margin-=
            left: auto; margin-right: 0; background-color: #fff; border-radius: 40px; b=
            order: solid 1px #71717a26; padding: 3px 8px 3px 4px; box-sizing: border-bo=
            x; max-height: 26px;">
                                    <span
                                        style=3D"display: block; width: 17px; height: 1=
            7px; border-radius: 50%; background-color: #fec60b; margin-right: 6px;"></s=
            pan>
                                    <span
                                        style=3D"color: #3f3f46; font-size: 15px; font-=
            weight: 500; line-height: 20px; font-family: Roboto, Helvetica, Arial, sans=
            -serif;">Pending
                                        review</span>
                                </div>
                            </div>
                            <p style=3D"color: #979197;">
                                16 screens =E2=80=A2 7 PM UTC, Dec 3, 2025
                            </p>
                        </div>
                        <table style=3D"margin:16px 0 0; width: 456px; table-layout: fi=
            xed;">
                            <tr style=3D"display: flex; background-color: #edeced; marg=
            in-top: 8px; padding: 12px 16px;">
                                <td
                                    style=3D"color: #3f3f46; margin: 0; text-overflow: =
            ellipsis; overflow: hidden; white-space: nowrap;">
                                    manual set up combined</td>
                            </tr>
                            <tr style=3D"display: flex; background-color: #edeced; marg=
            in-top: 8px; padding: 12px 16px;">
                                <td
                                    style=3D"color: #3f3f46; margin: 0; text-overflow: =
            ellipsis; overflow: hidden; white-space: nowrap;">
                                    manual set up complete</td>
                            </tr>
                            <tr style=3D"display: flex; background-color: #edeced; marg=
            in-top: 8px; padding: 12px 16px;">
                                <td
                                    style=3D"color: #3f3f46; margin: 0; text-overflow: =
            ellipsis; overflow: hidden; white-space: nowrap;">
                                    manual set up protocol</td>
                            </tr>
                            <tr style=3D"display: flex; background-color: #edeced; marg=
            in-top: 8px; padding: 12px 16px;">
                                <td
                                    style=3D"color: #3f3f46; margin: 0; text-overflow: =
            ellipsis; overflow: hidden; white-space: nowrap;">
                                    lrg/WelcomeiOS_v01</td>
                            </tr>
                            <tr style=3D"display: flex; background-color: #edeced; marg=
            in-top: 8px; padding: 12px 16px;">
                                <td
                                    style=3D"color: #3f3f46; margin: 0; text-overflow: =
            ellipsis; overflow: hidden; white-space: nowrap;">
                                    manual set up complete (dark mode)</td>
                            </tr>
                            <tr style=3D"display: flex; background-color: #edeced; marg=
            in-top: 8px; padding: 12px 16px;">
                                <td
                                    style=3D"color: #3f3f46; margin: 0; text-overflow: =
            ellipsis; overflow: hidden; white-space: nowrap;">
                                    lrg/WelcomeiOS_v01 (dark mode)</td>
                            </tr>
                            <tr style=3D"display: flex; background-color: #edeced; marg=
            in-top: 8px; padding: 12px 16px;">
                                <td
                                    style=3D"color: #3f3f46; margin: 0; text-overflow: =
            ellipsis; overflow: hidden; white-space: nowrap;">
                                    manual set up combined (dark mode)</td>
                            </tr>
                            <tr style=3D"display: flex; background-color: #edeced; marg=
            in-top: 8px; padding: 12px 16px;">
                                <td
                                    style=3D"color: #3f3f46; margin: 0; text-overflow: =
            ellipsis; overflow: hidden; white-space: nowrap;">
                                    manual set up protocol (dark mode)</td>
                            </tr>
                            <tr style=3D"display: flex; background-color: #edeced; marg=
            in-top: 8px; padding: 12px 16px;">
                                <td
                                    style=3D"color: #3f3f46; margin: 0; text-overflow: =
            ellipsis; overflow: hidden; white-space: nowrap;">
                                    message-view-threaded v01</td>
                            </tr>
                            <tr style=3D"display: flex; background-color: #edeced; marg=
            in-top: 8px; padding: 12px 16px;">
                                <td
                                    style=3D"color: #3f3f46; margin: 0; text-overflow: =
            ellipsis; overflow: hidden; white-space: nowrap;">
                                    message-view v01</td>
                            </tr>
                            <tr style=3D"display: flex; background-color: #edeced; marg=
            in-top: 8px; padding: 12px 16px;">
                                <td
                                    style=3D"color: #3f3f46; margin: 0; text-overflow: =
            ellipsis; overflow: hidden; white-space: nowrap;">
                                    message-list-v01</td>
                            </tr>
                            <tr style=3D"display: flex; background-color: #edeced; marg=
            in-top: 8px; padding: 12px 16px;">
                                <td
                                    style=3D"color: #3f3f46; margin: 0; text-overflow: =
            ellipsis; overflow: hidden; white-space: nowrap;">
                                    account-drawer-v01</td>
                            </tr>
                            <tr style=3D"display: flex; background-color: #edeced; marg=
            in-top: 8px; padding: 12px 16px;">
                                <td
                                    style=3D"color: #3f3f46; margin: 0; text-overflow: =
            ellipsis; overflow: hidden; white-space: nowrap;">
                                    manual set up: email &amp; password</td>
                                <td style=3D"color: #71717a; margin: 0; white-space: no=
            wrap;">&nbsp;(with 2
                                    variants)</td>
                            </tr>
                            <tr style=3D"display: flex; background-color: #edeced; marg=
            in-top: 8px; padding: 12px 16px;">
                                <td
                                    style=3D"color: #3f3f46; margin: 0; text-overflow: =
            ellipsis; overflow: hidden; white-space: nowrap;">
                                    manual set up: email &amp; password</td>
                                <td style=3D"color: #71717a; margin: 0; white-space: no=
            wrap;">&nbsp;(with 2
                                    variants)</td>
                            </tr>
                        </table>
                    <div style=3D"margin: 24px 0px 0px 0px;">
                        <a href=3D"https://app.zeplin.io/project/66dd0f2b2fe8f1b63cda36=
            f1/screen/693082ba2d6d9960aa30f1fc/approval/69308e7ffe73eae3a622c2bc?aprid&=
            #x3D;68011de527d5e80e5879c010" style=3D"display: inline-block;
                                            text-decoration: none;
                                            text-align: center;
                                            font-weight: 500;
                                            color: #fff;
                                            line-height: 21px;
                                            background-color: #419bf9;
                                            padding: 8px 16px;
                                            border-radius: 4px;
                                            font-size: 18px">
                            Start review
                        </a>
                    </div>
                    </div>
                    <div style=3D"width: 456px; padding: 0 24px; margin-bottom: 12px;">
                        <img src=3D"https://cdn.zeplin.io/assets/webapp/img/emailAssets=
            /divider.png" alt=3D"divider" style=3D"display: block; margin: 0 auto;"/>
                    </div>
                    <p style=3D"margin-top: 36px;
                                        line-height: 17px;
                                        font-size: 14px;
                                        color: #574751;">
                        Let us know if you have any questions:
                        <a href=3D"mailto:support@zeplin.io" style=3D"text-decoration: =
            none;
                color: #419bf9;">support@zeplin.io</a>
                    </p>
                    <p style=3D"margin-top: 6px;
                                        color: #bcb5b9;
                                        font-weight: 300;
                                        line-height: 17px;
                                        font-size: 14px;">
                        Zeplin Crew
                    </p>
                    </p>
                    </div>
                </div>
                <div itemscope=3D"" itemtype=3D"http://schema.org/EmailMessage">
                    <div itemprop=3D"potentialAction" itemscope itemtype=3D"http://sche=
            ma.org/ViewAction">
                        <meta itemprop=3D"name" content=3D"View Approval" />
                        <link itemprop=3D"target"
                            href=3D"https://app.zeplin.io/project/66dd0f2b2fe8f1b63cda3=
            6f1/screen/693082ba2d6d9960aa30f1fc/approval/69308e7ffe73eae3a622c2bc?aprid=
            &#x3D;68011de527d5e80e5879c010" />
                        <link itemprop=3D"url"
                            href=3D"https://app.zeplin.io/project/66dd0f2b2fe8f1b63cda3=
            6f1/screen/693082ba2d6d9960aa30f1fc/approval/69308e7ffe73eae3a622c2bc?aprid=
            &#x3D;68011de527d5e80e5879c010" />
                    </div>
                    <meta itemprop=3D"description" content=3D"Laurel requested a new ap=
            proval" />
                </div>
            <img src=3D"https://ea.pstmrk.it/open?m=3Dv3_1.prYEbRu-rFYkA-lXRGfptA.7K_MD=
            w7phkMmsnY5q9C81S3yDJtlboaBtg7TCAHTLoORT24neThoLwTbbjyrwmEQpWQyAis5SNgwKig3=
            fFdPdDNYfZsOwM4FSljGdaD1g3i69kOhnXs2NKJnvS_U8ckFluLyBZqoUzLmruaP18XhEqmHtAE=
            Cm6fVdlrX_UklmvmTRmARIOlczXke_xB8QUKgfaEUBhih3VQ3IjTzj8Mu7WpSEYaukAYmH-jdW8=
            XiITGtyPXPksNdIrWyFvtX_oKDMxumm2yT1XN-dU3S_JcCKSnG6EnouNiLC9N258c5IP7Tp-shJ=
            KfUD3DNt37T0M-261aY5upbXnz0ebyEu5I5sFV48jPH4prJzSrAwkso4u6vX5Uv8jFe0cmyvbDw=
            AeTxroLWUD6aWb0LaM5LuLL-kOLB6QOE9DvioUNqmxT8LEO8dUr1xHjvru-beXaXe3GpDod4JGI=
            q7kaO5GrVA1m_srjA9P1vniBr3pO_rF6cXxHIQnMZkxVLaZUuxEjCx_5A321Ix75dTVTRPOkhl7=
            o5cPdFT0hh17vW4C-Sygnh4FedQ2oWF6Iox4AK6t__tv2nkHtGjySSegodKhD3fIhP923ytUPty=
            mDBW50_itmnHCI" width=3D"1" height=3D"1" border=3D"0" alt=3D"" /></body>

            </html>

            """,
        dateSent: Date(),
        unread: false,
        newEmail: false,
        attachments: [Data(), Data()],
        isThread: false
    )
    ReadEmailView(
        tempEmail
    )

}
