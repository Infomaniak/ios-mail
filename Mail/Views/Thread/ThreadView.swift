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

import MailCore
import MailResources
import RealmSwift
import SwiftUI

class MessageSheet: SheetState<MessageSheet.State> {
    enum State: Equatable {
        case attachment(Attachment)
    }
}

class MessageCard: CardState<MessageCard.State> {
    enum State: Equatable {
        case contact(Recipient)
    }
}

struct ThreadView: View {
    @ObservedRealmObject var thread: Thread
    private var mailboxManager: MailboxManager

    @ObservedObject private var sheet = MessageSheet()
    @ObservedObject private var card = MessageCard()

    private let trashId: String

    private var isTrashFolder: Bool {
        return thread.parent?._id == trashId
    }

    private var messages: [Message] {
        return Array(thread.messages
            .where { $0.isDuplicate != true }
            .sorted(by: \.date, ascending: true))
            .filter { isTrashFolder || $0.folderId != trashId }
    }

    init(mailboxManager: MailboxManager, thread: Thread) {
        self.mailboxManager = mailboxManager
        self.thread = thread
        trashId = mailboxManager.getFolder(with: .trash)?._id ?? ""
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(messages.indices, id: \.self) { index in
                        MessageView(message: messages[index])
                        if index < messages.count - 1 {
                            MessageSeparatorView()
                        }
                    }
                }
            }
            .navigationTitle(thread.formattedSubject)
            .onAppear {
                MatomoUtils.track(view: ["MessageView"])
            }

            if card.cardShown {
                switch card.state {
                case let .contact(recipient):
                    BottomCard(cardShown: $card.cardShown, cardDismissal: $card.cardDismissal, height: 285) {
                        ContactView(recipient: recipient)
                    }
                case .none:
                    EmptyView()
                }
            }
        }
        .environmentObject(mailboxManager)
        .environmentObject(card)
        .environmentObject(sheet)
        .sheet(isPresented: $sheet.isShowing) {
            switch sheet.state {
            case let .attachment(attachment):
                AttachmentPreview(isPresented: $sheet.isShowing, attachment: attachment)
            case .none:
                EmptyView()
            }
        }
    }
}

struct ThreadView_Previews: PreviewProvider {
    static var previews: some View {
        ThreadView(
            mailboxManager: MailboxManager(mailbox: PreviewHelper.sampleMailbox, apiFetcher: MailApiFetcher()),
            thread: PreviewHelper.sampleThread
        )
    }
}
