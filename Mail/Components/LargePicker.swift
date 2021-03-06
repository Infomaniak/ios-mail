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

struct LargePicker<SelectionValue, ButtonType>: View where SelectionValue: Hashable, ButtonType: View {
    let title: String?
    let noSelectionText: String
    let items: [Item<SelectionValue>]
    let button: Button<ButtonType>?

    @Binding var selection: SelectionValue

    struct Item<ID>: Identifiable where ID: Hashable {
        let id: ID
        let name: String
    }

    private var selectedItem: Item<SelectionValue>? {
        return items.first { $0.id == selection }
    }

    init(title: String? = nil,
         noSelectionText: String = MailResourcesStrings.Localizable.pickerNoSelection,
         selection: Binding<SelectionValue>,
         items: [Item<SelectionValue>],
         button: Button<ButtonType>?) {
        self.title = title
        self.noSelectionText = noSelectionText
        self.items = items
        self.button = button
        _selection = selection
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let title = title {
                Text(title)
                    .textStyle(.callout)
            }

            Menu {
                button
                Picker(title ?? "", selection: $selection) {
                    ForEach(items) { item in
                        Text(item.name).tag(item.id)
                    }
                }
            } label: {
                HStack {
                    Text(selectedItem?.name ?? noSelectionText)
                        .textStyle(.body)
                    Spacer()
                    ChevronIcon(style: .down)
                }
                .padding(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color(hex: "#E0E0E0"))
                )
            }
        }
    }
}

extension LargePicker where ButtonType == EmptyView {
    init(title: String? = nil,
         noSelectionText: String = MailResourcesStrings.Localizable.pickerNoSelection,
         selection: Binding<SelectionValue>,
         items: [Item<SelectionValue>]) {
        self.title = title
        self.noSelectionText = noSelectionText
        self.items = items
        self.button = nil
        _selection = selection
    }

}

struct LargePicker_Previews: PreviewProvider {
    static var previews: some View {
        LargePicker(title: nil, selection: .constant(0), items: [.init(id: 0, name: "Value")])
        LargePicker(title: "Title", selection: .constant(0), items: [.init(id: 0, name: "Value")])
    }
}
