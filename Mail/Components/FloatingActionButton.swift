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

import MailResources
import SwiftUI

struct FloatingActionButton: View {
    let icon: Image
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label {
                Text(title)
                    .textStyle(.buttonPill)
            } icon: {
                icon
                    .resizable()
                    .frame(width: 18, height: 18)
            }
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .controlSize(.large)
        .padding(.trailing, 24)
        .padding(.bottom, 40)
    }
}

struct NewMessageButtonView_Previews: PreviewProvider {
    static var previews: some View {
        FloatingActionButton(icon: Image(resource: MailResourcesAsset.edit),
                             title: "New message") { /* Preview */ }
    }
}
