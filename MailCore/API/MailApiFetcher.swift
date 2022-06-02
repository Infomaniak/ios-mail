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

import Alamofire
import Foundation
import InfomaniakCore
import InfomaniakLogin
import Sentry
import UIKit

public extension ApiFetcher {
    convenience init(token: ApiToken, delegate: RefreshTokenDelegate) {
        self.init()
        setToken(token, authenticator: SyncedAuthenticator(refreshTokenDelegate: delegate))
    }
}

public class MailApiFetcher: ApiFetcher {
    public static let clientId = "E90BC22D-67A8-452C-BE93-28DA33588CA4"

    private let itemsPerPage = 50

    override public init() {
        super.init()
        ApiFetcher.decoder.dateDecodingStrategy = .iso8601
    }

    override public func perform<T: Decodable>(request: DataRequest) async throws -> (data: T, responseAt: Int?) {
        do {
            return try await super.perform(request: request)
        } catch let InfomaniakError.apiError(apiError) {
            throw MailError.apiError(apiError)
        } catch let InfomaniakError.serverError(statusCode: statusCode) {
            throw MailError.serverError(statusCode: statusCode)
        }
    }

    // MARK: - API methods

    public func mailboxes() async throws -> [Mailbox] {
        try await perform(request: authenticatedRequest(.mailboxes)).data
    }

    func contacts() async throws -> [Contact] {
        try await perform(request: authenticatedRequest(.contacts)).data
    }

    func addressBooks() async throws -> AddressBookResult {
        try await perform(request: authenticatedRequest(.addressBooks)).data
    }

    func signatures(mailbox: Mailbox) async throws -> SignatureResponse {
        try await perform(request: authenticatedRequest(.signatures(hostingId: mailbox.hostingId, mailboxName: mailbox.mailbox)))
            .data
    }

    func folders(mailbox: Mailbox) async throws -> [Folder] {
        try await perform(request: authenticatedRequest(.folders(uuid: mailbox.uuid))).data
    }

    func threads(mailbox: Mailbox, folder: Folder, page: Int, filter: Filter = .all) async throws -> ThreadResult {
        try await perform(request: authenticatedRequest(.threads(
            uuid: mailbox.uuid,
            folderId: folder._id,
            offset: (page - 1) * itemsPerPage,
            filter: filter == .all ? nil : filter.rawValue
        ))).data
    }

    func message(mailbox: Mailbox, message: Message) async throws -> Message {
        try await perform(request: authenticatedRequest(.resource(message.resource,
                                                                  queryItems: [
                                                                      URLQueryItem(name: "prefered_format", value: "html")
                                                                  ]))).data
    }

    func markAsSeen(mailbox: Mailbox, messages: [Message]) async throws -> SeenResult {
        try await perform(request: authenticatedRequest(.messageSeen(uuid: mailbox.uuid),
                                                        method: .post,
                                                        parameters: ["uids": messages.map(\.uid)])).data
    }

    func markAsUnseen(mailbox: Mailbox, messages: [Message]) async throws -> SeenResult {
        try await perform(request: authenticatedRequest(.messageUnseen(uuid: mailbox.uuid),
                                                        method: .post,
                                                        parameters: ["uids": messages.map(\.uid)])).data
    }

    func move(mailbox: Mailbox, messages: [Message], destinationId: String) async throws -> Empty {
        try await perform(request: authenticatedRequest(.moveMessages(uuid: mailbox.uuid),
                                                        method: .post,
                                                        parameters: ["uids": messages.map(\.uid), "to": destinationId])).data
    }

    func delete(mailbox: Mailbox, messages: [Message]) async throws -> Empty {
        try await perform(request: authenticatedRequest(.deleteMessages(uuid: mailbox.uuid),
                                                        method: .post,
                                                        parameters: ["uids": messages.map(\.uid)])).data
    }

    func attachment(attachment: Attachment) async throws -> Data {
        guard let resource = attachment.resource else {
            throw MailError.resourceError
        }
        let request = authenticatedRequest(.resource(resource))
        return try await request.serializingData().value
    }

    public func quotas(mailbox: Mailbox) async throws -> Quotas {
        try await perform(request: authenticatedRequest(.quotas(mailbox: mailbox.mailbox, productId: mailbox.hostingId))).data
    }

    func draft(mailbox: Mailbox, draftUuid: String) async throws -> Draft {
        try await perform(request: authenticatedRequest(.draft(uuid: mailbox.uuid, draftUuid: draftUuid))).data
    }

    func draft(from message: Message) async throws -> Draft {
        guard let resource = message.draftResource else {
            throw MailError.resourceError
        }
        return try await perform(request: authenticatedRequest(.resource(resource))).data
    }

    func send(mailbox: Mailbox, draft: Draft) async throws -> Bool {
        try await perform(request: authenticatedRequest(
            draft.uuid.isEmpty ? .draft(uuid: mailbox.uuid) : .draft(uuid: mailbox.uuid, draftUuid: draft.uuid),
            method: draft.uuid.isEmpty ? .post : .put,
            parameters: draft
        )).data
    }

    func save(mailbox: Mailbox, draft: Draft) async throws -> DraftResponse {
        try await perform(request: authenticatedRequest(
            draft.hasLocalUuid ? .draft(uuid: mailbox.uuid) : .draft(uuid: mailbox.uuid, draftUuid: draft.uuid),
            method: draft.hasLocalUuid ? .post : .put,
            parameters: draft
        )).data
    }
}

class SyncedAuthenticator: OAuthAuthenticator {
    override func refresh(
        _ credential: OAuthAuthenticator.Credential,
        for session: Session,
        completion: @escaping (Result<OAuthAuthenticator.Credential, Error>) -> Void
    ) {
        AccountManager.instance.refreshTokenLockedQueue.async {
            SentrySDK
                .addBreadcrumb(crumb: (credential as ApiToken)
                    .generateBreadcrumb(level: .info, message: "Refreshing token - Starting"))
            if !KeychainHelper.isKeychainAccessible {
                SentrySDK
                    .addBreadcrumb(crumb: (credential as ApiToken)
                        .generateBreadcrumb(level: .error, message: "Refreshing token failed - Keychain unaccessible"))
                completion(.failure(MailError.noToken))
                return
            }

            // Maybe someone else refreshed our token
            AccountManager.instance.reloadTokensAndAccounts()
            if let token = AccountManager.instance.getTokenForUserId(credential.userId),
               token.expirationDate > credential.expirationDate {
                SentrySDK
                    .addBreadcrumb(crumb: token
                        .generateBreadcrumb(level: .info, message: "Refreshing token - Success with local"))

                completion(.success(token))
                return
            }

            let group = DispatchGroup()
            group.enter()
            var taskIdentifier: UIBackgroundTaskIdentifier = .invalid
            if !Bundle.main.isExtension {
                // It is absolutely necessary that the app stays awake while we refresh the token
                taskIdentifier = UIApplication.shared.beginBackgroundTask(withName: "Refresh token") {
                    SentrySDK
                        .addBreadcrumb(crumb: (credential as ApiToken)
                            .generateBreadcrumb(level: .error, message: "Refreshing token failed - Background task expired"))
                    // If we didn't fetch the new token in the given time there is not much we can do apart from hoping that it wasn't revoked
                    if taskIdentifier != .invalid {
                        UIApplication.shared.endBackgroundTask(taskIdentifier)
                        taskIdentifier = .invalid
                    }
                }

                if taskIdentifier == .invalid {
                    // We couldn't request additional time to refresh token maybe try later...
                    completion(.failure(MailError.noToken))
                    return
                }
            }
            InfomaniakLogin.refreshToken(token: credential) { token, error in
                // New token has been fetched correctly
                if let token = token {
                    SentrySDK
                        .addBreadcrumb(crumb: token
                            .generateBreadcrumb(level: .info, message: "Refreshing token - Success with remote"))
                    self.refreshTokenDelegate?.didUpdateToken(newToken: token, oldToken: credential)
                    completion(.success(token))
                } else {
                    // Couldn't refresh the token, API says it's invalid
                    if let error = error as NSError?, error.domain == "invalid_grant" {
                        SentrySDK
                            .addBreadcrumb(crumb: (credential as ApiToken)
                                .generateBreadcrumb(level: .error, message: "Refreshing token failed - Invalid grant"))
                        self.refreshTokenDelegate?.didFailRefreshToken(credential)
                        completion(.failure(error))
                    } else {
                        // Couldn't refresh the token, keep the old token and fetch it later. Maybe because of bad network ?
                        SentrySDK
                            .addBreadcrumb(crumb: (credential as ApiToken)
                                .generateBreadcrumb(level: .error,
                                                    message: "Refreshing token failed - Other \(error.debugDescription)"))
                        completion(.success(credential))
                    }
                }
                if taskIdentifier != .invalid {
                    UIApplication.shared.endBackgroundTask(taskIdentifier)
                    taskIdentifier = .invalid
                }
                group.leave()
            }
            group.wait()
        }
    }
}

class NetworkRequestRetrier: RequestInterceptor {
    let maxRetry: Int
    private var retriedRequests: [String: Int] = [:]
    let timeout = -1001
    let connectionLost = -1005

    init(maxRetry: Int = 3) {
        self.maxRetry = maxRetry
    }

    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard request.task?.response == nil,
              let url = request.request?.url?.absoluteString else {
            removeCachedUrlRequest(url: request.request?.url?.absoluteString)
            completion(.doNotRetry)
            return
        }

        let errorGenerated = error as NSError
        switch errorGenerated.code {
        case timeout, connectionLost:
            guard let retryCount = retriedRequests[url] else {
                retriedRequests[url] = 1
                completion(.retryWithDelay(0.5))
                return
            }

            if retryCount < maxRetry {
                retriedRequests[url] = retryCount + 1
                completion(.retryWithDelay(0.5))
            } else {
                removeCachedUrlRequest(url: url)
                completion(.doNotRetry)
            }

        default:
            removeCachedUrlRequest(url: url)
            completion(.doNotRetry)
        }
    }

    private func removeCachedUrlRequest(url: String?) {
        guard let url = url else {
            return
        }
        retriedRequests.removeValue(forKey: url)
    }
}
