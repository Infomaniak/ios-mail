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

struct AttachmentPreviewFooter: View {
    var attachment: Attachment
    @State private var isSharePresented = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Spacer()
                Rectangle()
                    .fill(Color(MailResourcesAsset.separatorColor.color))
                    .cornerRadius(5)
                    .frame(width: 44, height: 4)
                Spacer()
            }
            .padding(.bottom, 11)
            Text(attachment.name)
                .textStyle(.body)
            Text(Int64(attachment.size), format: .defaultByteCount)
                .textStyle(.calloutSecondary)

            HStack {
                Button {
                    isSharePresented = true
                } label: {
                    HStack {
                        Image(resource: MailResourcesAsset.share)
                            .frame(width: 24, height: 24)
                        Text(MailResourcesStrings.Localizable.buttonShare)
                            .fontWeight(.semibold)
                    }
                }
                Spacer()
                Button {
                    downloadAttachment()
                } label: {
                    HStack {
                        Image(resource: MailResourcesAsset.downloadWith)
                            .frame(width: 24, height: 24)
                        Text(MailResourcesStrings.Localizable.buttonDownload)
                            .fontWeight(.semibold)
                    }
                }
            }
            .foregroundColor(.accentColor)
            .padding(.top, 22)
        }
        .background(Color(MailResourcesAsset.backgroundColor.color))
        .padding(.top, 12)
        .padding([.bottom, .leading, .trailing], 32)
        .sheet(isPresented: $isSharePresented) {
            if let itemUrl = attachment.localUrl {
                ActivityViewController(activityItems: [itemUrl])
            }
        }
    }

    @MainActor
    private func downloadAttachment() {
        // TODO: Download attachment
        showWorkInProgressSnackBar()
    }
}

struct AttachmentPreviewFooter_Previews: PreviewProvider {
    static var previews: some View {
        AttachmentPreviewFooter(attachment: PreviewHelper.sampleAttachment)
    }
}
