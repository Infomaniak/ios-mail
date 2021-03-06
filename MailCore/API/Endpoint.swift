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

import Foundation
import InfomaniakCore

// MARK: - Type definition

public extension ApiEnvironment {
    var mailHost: String {
        return "mail.\(host)"
    }
}

// MARK: - Endpoints

public extension Endpoint {
    static func resource(_ resource: String, queryItems: [URLQueryItem]? = nil) -> Endpoint {
        let components = URLComponents(string: resource)
        var mergedQueryItems = components?.queryItems
        if mergedQueryItems == nil {
            mergedQueryItems = queryItems
        } else if let queryItems = queryItems {
            mergedQueryItems?.append(contentsOf: queryItems)
        }
        return Endpoint(hostKeypath: \.mailHost, path: components?.path ?? resource, queryItems: mergedQueryItems)
    }

    private static var baseManager: Endpoint {
        return Endpoint(path: "/1/mail_hostings")
    }

    private static var base: Endpoint {
        return Endpoint(hostKeypath: \.mailHost, path: "/api")
    }

    static var mailboxes: Endpoint {
        return .base.appending(path: "/mailbox", queryItems: [URLQueryItem(name: "with", value: "unseen")])
    }

    private static func mailbox(uuid: String) -> Endpoint {
        return .base.appending(path: "/mail/\(uuid)")
    }

    static func permissions(mailbox: Mailbox) -> Endpoint {
        return .base.appending(path: "/mailbox/permissions",
                               queryItems: [URLQueryItem(name: "user_mailbox_id", value: "\(mailbox.linkId)"),
                                            URLQueryItem(name: "product_id", value: "\(mailbox.hostingId)")])
    }

    static var addressBooks: Endpoint {
        return .base.appending(path: "/pim/addressbook")
    }

    static var contacts: Endpoint {
        return .base.appending(
            path: "/pim/contact/all",
            queryItems: [URLQueryItem(name: "with", value: "emails,details,others,contacted_times")]
        )
    }

    static var addContact: Endpoint {
        return .base.appending(path: "/pim/contact")
    }

    static func backups(hostingId: Int, mailboxName: String) -> Endpoint {
        return .baseManager.appending(path: "/\(hostingId)/mailboxes/\(mailboxName)/backups")
    }

    static func signatures(hostingId: Int, mailboxName: String) -> Endpoint {
        return .baseManager.appending(path: "/\(hostingId)/mailboxes/\(mailboxName)/signatures")
    }

    static func folders(uuid: String) -> Endpoint {
        return .mailbox(uuid: uuid).appending(path: "/folder")
    }

    static func threads(uuid: String, folderId: String, offset: Int = 0, filter: String?) -> Endpoint {
        return .folders(uuid: uuid).appending(path: "/\(folderId)/message", queryItems: [
            URLQueryItem(name: "offset", value: "\(offset)"),
            URLQueryItem(name: "thread", value: "on"),
            URLQueryItem(name: "filters", value: filter)
        ])
    }

    static func quotas(mailbox: String, productId: Int) -> Endpoint {
        return .mailboxes.appending(path: "/quotas", queryItems: [
            URLQueryItem(name: "mailbox", value: mailbox),
            URLQueryItem(name: "product_id", value: "\(productId)")
        ])
    }

    static func draft(uuid: String) -> Endpoint {
        return .mailbox(uuid: uuid).appending(path: "/draft")
    }

    static func draft(uuid: String, draftUuid: String) -> Endpoint {
        return .draft(uuid: uuid).appending(path: "/\(draftUuid)")
    }

    static func messageSeen(uuid: String) -> Endpoint {
        return .mailbox(uuid: uuid).appending(path: "/message/seen")
    }

    static func messageUnseen(uuid: String) -> Endpoint {
        return .mailbox(uuid: uuid).appending(path: "/message/unseen")
    }

    static func moveMessages(uuid: String) -> Endpoint {
        return .mailbox(uuid: uuid).appending(path: "/message/move")
    }

    static func deleteMessages(uuid: String) -> Endpoint {
        return .mailbox(uuid: uuid).appending(path: "/message/delete")
    }

    static func reportSpam(uuid: String) -> Endpoint {
        return .mailbox(uuid: uuid).appending(path: "/message/spam")
    }

    static func nonSpam(uuid: String) -> Endpoint {
        return .mailbox(uuid: uuid).appending(path: "/message/ham")
    }

    static func star(uuid: String) -> Endpoint {
        return .mailbox(uuid: uuid).appending(path: "/message/star")
    }

    static func unstar(uuid: String) -> Endpoint {
        return .mailbox(uuid: uuid).appending(path: "/message/unstar")
    }

    static func blockSender(messageResource: String) -> Endpoint {
        return .resource(messageResource).appending(path: "/blacklist")
    }

    static func report(messageResource: String) -> Endpoint {
        return .resource(messageResource).appending(path: "/report")
    }

    static func createAttachment(uuid: String) -> Endpoint {
        return .draft(uuid: uuid).appending(path: "/attachment")
    }
}
