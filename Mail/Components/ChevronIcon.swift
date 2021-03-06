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

struct ChevronIcon: View {
    enum Style {
        case up, right, left, down

        var rotationAngle: Angle {
            switch self {
            case .up:
                return .zero
            case .right:
                return .radians(.pi / 2)
            case .down:
                return .radians(.pi)
            case .left:
                return .radians(3 * .pi / 2)
            }
        }
    }

    enum Color {
        case primary, secondary

        var color: MailResourcesColors {
            switch self {
            case .primary:
                return MailResourcesAsset.primaryTextColor
            case .secondary:
                return MailResourcesAsset.secondaryTextColor
            }
        }
    }

    let style: Style
    let color: Color

    init(style: Style, color: Color = .secondary) {
        self.style = style
        self.color = color
    }

    var body: some View {
        Image(resource: MailResourcesAsset.arrowUp)
            .resizable()
            .frame(width: 12, height: 12)
            .foregroundColor(color.color)
            .padding(.vertical, 2)
            .padding(.horizontal, 1.5)
            .rotationEffect(style.rotationAngle)
    }
}

struct ChevronButton: View {
    @Binding var isExpanded: Bool

    var body: some View {
        Button {
            withAnimation {
                isExpanded.toggle()
            }
        } label: {
            ChevronIcon(style: isExpanded ? .up : .down)
        }
    }
}

struct ChevronIcon_Previews: PreviewProvider {
    static var previews: some View {
        ChevronIcon(style: .up)
        ChevronIcon(style: .down)
    }
}
