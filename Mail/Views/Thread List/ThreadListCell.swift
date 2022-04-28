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
import SwiftUI

enum ThreadListAppearance: Int {
    case normal, compact, large
}

struct ThreadListCell: View {
    @AppStorage("threadListAppearance") var threadListAppearance: ThreadListAppearance = .normal

    var mailboxManager: MailboxManager
    var thread: Thread

    private var hasUnreadMessages: Bool {
        thread.unseenMessages > 0
    }

    private var textStyle: MailTextStyle {
        hasUnreadMessages ? .primaryHighlighted : .secondary
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .frame(width: Constants.unreadIconSize, height: Constants.unreadIconSize)
                .foregroundColor(hasUnreadMessages ? Color(MailResourcesAsset.mailPinkColor.color) : .clear)
                .padding(.top, threadListAppearance == .large ? 10.5 : 6)

            if threadListAppearance == .large {
                RecipientImage(recipient: thread.from.last, size: 32)
                    .padding(.trailing, 3)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 15) {
                    Text(thread.formattedFrom)
                        .foregroundColor(MailTextStyle.header.color)
                        .font(MailTextStyle.header.font)
                        .fontWeight(hasUnreadMessages ? .semibold : .regular)
                        .lineLimit(1)

                    Spacer()

                    if thread.hasAttachments {
                        Image(uiImage: MailResourcesAsset.attachment.image)
                            .foregroundColor(textStyle.color)
                    }

                    Text(thread.formattedDate)
                        .foregroundColor(textStyle.color)
                        .font(textStyle.font)
                }
                .padding(.bottom, 4)

                HStack(spacing: 3) {
                    VStack(alignment: .leading) {
                        Text(thread.formattedSubject)
                            .foregroundColor(textStyle.color)
                            .font(textStyle.font)
                            .lineLimit(1)

                        if threadListAppearance != .compact {
                            // TODO: Julien Arnoux will modify the API to get a preview of the messages
                            Text("Lorem Ipsum...")
                                .foregroundColor(MailTextStyle.secondary.color)
                                .lineLimit(1)
                        }
                    }

                    Spacer()

                    if thread.flagged {
                        Image(uiImage: MailResourcesAsset.starFilled.image)
                    } else {
                        Image(uiImage: MailResourcesAsset.star.image)
                            .foregroundColor(hasUnreadMessages ? MailResourcesAsset.primaryTextColor : MailResourcesAsset.secondaryTextColor)
                    }
                }
            }
        }
        .padding([.top, .bottom], threadListAppearance == .compact ? 3 : 5)
    }
}

struct ThreadListCell_Previews: PreviewProvider {
    static var previews: some View {
        ThreadListCell(mailboxManager: MailboxManager(mailbox: PreviewHelper.sampleMailbox, apiFetcher: MailApiFetcher()), thread: PreviewHelper.sampleThread)
            .previewLayout(.sizeThatFits)
            .previewDevice("iPhone 13 Pro")
    }
}
