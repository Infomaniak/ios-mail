/*
 Infomaniak Mail - iOS App
 Copyright (C) 2022 Infomaniak Network SA

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import BottomSheet
import Foundation
import MailResources
import SwiftUI

public struct URLConstants {
    public static let feedback = URLConstants(urlString: "https://feedback.userreport.com/9f60b46d-7299-4887-b79d-c756cf474c4d#ideas/popular")
    public static let importMails = URLConstants(urlString: "https://import-email.infomaniak.com")
    public static let matomo = URLConstants(urlString: "https://analytics.infomaniak.com/matomo.php")
    public static let faq = URLConstants(urlString: "https://www.infomaniak.com/\(Locale.current.languageCode ?? "fr")/support/faq/admin2/service-mail")
    public static let chatbot = URLConstants(urlString: "https://www.infomaniak.com/chatbot")

    public static let schemeUrl = "http"

    private var urlString: String

    public var url: URL {
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
        }
        return url
    }
}

public enum Constants {
    public static let sizeLimit = 21_474_836_480 // 20 Go
    public static let minimumQuotasProgressionToDisplay = 0.03

    public static let onboardingLogoHeight: CGFloat = 72
    public static let onboardingButtonHeight: CGFloat = 100
    public static let onboardingVerticalPadding: CGFloat = 16

    public static let menuDrawerHorizontalPadding: CGFloat = 24
    public static let menuDrawerVerticalPadding: CGFloat = 12
    public static let menuDrawerSubFolderPadding: CGFloat = 10

    public static let unreadIconSize: CGFloat = 8

    public static let bottomSheetOptions: [BottomSheet.Options] = [
        .background { AnyView(MailResourcesAsset.backgroundBottomSheetColor.swiftUiColor) },
        .backgroundBlur(effect: .dark),
        .cornerRadius(20),
        .dragIndicatorColor(MailResourcesAsset.menuActionColor.swiftUiColor),
        .noBottomPosition,
        .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.1), radius: 30, x: 0, y: -10),
        .swipeToDismiss,
        .tapToDismiss
    ]

    public static let mailRegex = "(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"

    public static func forwardQuote(message: Message) -> String {
        let date = DateFormatter.localizedString(from: message.date, dateStyle: .medium, timeStyle: .short)
        let to = ListFormatter.localizedString(byJoining: message.to.map(\.htmlDescription))
        return """
        <div class=\"forwardContentMessage\">
        <div>---------- \(MailResourcesStrings.Localizable.messageForwardHeader) ---------<br></div>
        <div>\(MailResourcesStrings.Localizable.fromTitle) \(message.from.first?.htmlDescription ?? "")<br></div>
        <div>\(MailResourcesStrings.Localizable.dateTitle) \(date)<br></div>
        <div>\(MailResourcesStrings.Localizable.subjectTitle) \(message.formattedSubject)<br></div>
        <div>\(MailResourcesStrings.Localizable.toTitle) \(to)<br></div>
        <div><br></div>
        <div><br></div>
        <div class=\"ws-ng-mail-style--6094eJzz9HPyjwAABGYBgQ\">
        \(message.body?.value.replacingOccurrences(of: "'", with: "???") ?? "")
        </div>
        </div>
        """
    }

    public static func replyQuote(message: Message) -> String {
        let headerText = MailResourcesStrings.Localizable.messageReplyHeader(
            DateFormatter.localizedString(from: message.date, dateStyle: .medium, timeStyle: .short),
            message.from.first?.htmlDescription ?? ""
        )
        return """
        <div id=\"answerContentMessage\" class=\"ik_mail_quote\" >
        <div>\(headerText)</div>
        <blockquote class=\"ws-ng-quote\">
        <div class=\"ik_mail_quote-6057eJzz9HPyjwAABGYBgQ\">
        \(message.body?.value.replacingOccurrences(of: "'", with: "???") ?? "")
        </div>
        </blockquote>
        </div>
        """
    }

    public static let defaultSwipeShortRight = SwipeAction.none
    public static let defaultSwipeLongRight = SwipeAction.readUnread
    public static let defaultSwipeShortLeft = SwipeAction.quickAction
    public static let defaultSwipeLongLeft = SwipeAction.delete

    public static let bottomSheetHorizontalPadding: CGFloat = 24

    // To delete: alert to facilitate tests for beta version
    public static let workInProgress = "This feature is currently under development."
}
