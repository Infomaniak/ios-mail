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

import ProjectDescription

let deploymentTarget = DeploymentTarget.iOS(targetVersion: "14.0", devices: [.iphone, .ipad])

let project = Project(name: "Mail",
                      packages: [
                          .package(url: "https://github.com/Infomaniak/ios-login.git", .upToNextMajor(from: "1.4.0")),
                          .package(url: "https://github.com/ProxymanApp/atlantis", .upToNextMajor(from: "1.3.0"))
                      ],
                      targets: [
                          Target(name: "Mail",
                                 platform: .iOS,
                                 product: .app,
                                 bundleId: "com.infomaniak.mail",
                                 deploymentTarget: deploymentTarget,
                                 infoPlist: "Mail/Info.plist",
                                 sources: "Mail/**",
                                 resources: [
                                     "Mail/**/*.storyboard",
                                     "Mail/**/*.xcassets"
//                                     "Mail/**/*.strings",
//                                     "Mail/**/*.stringsdict",
//                                     "Mail/**/*.xib"
//                                     "mail/**/*.json",
//                                     "mail/**/*.css"
                                 ],
                                 scripts: [
                                     .post(path: "scripts/lint.sh", name: "Swiftlint")
                                 ],
                                 dependencies: [
                                     .target(name: "MailCore")
                                 ]),
                          Target(name: "MailTests",
                                 platform: .iOS,
                                 product: .unitTests,
                                 bundleId: "com.infomaniak.mail.tests",
                                 infoPlist: "MailTests/Info.plist",
                                 sources: "MailTests/**",
                                 dependencies: [
                                     .target(name: "Mail")
                                 ]),
                          Target(
                              name: "MailUITests",
                              platform: .iOS,
                              product: .uiTests,
                              bundleId: "com.infomaniak.mail.uitests",
                              infoPlist: "MailTests/Info.plist",
                              sources: "MailUITests/**",
                              dependencies: [
                                  .target(name: "Mail")
                              ]
                          ),
                          Target(
                              name: "MailResources",
                              platform: .iOS,
                              product: .staticLibrary,
                              bundleId: "com.infomaniak.mail.resources",
                              deploymentTarget: deploymentTarget,
                              infoPlist: .default,
                              resources: [
                                  "Mail/**/*.xcassets"
//                                  "Mail/**/*.strings",
//                                  "Mail/**/*.stringsdict"
                              ]
                          ),
                          Target(
                              name: "MailCore",
                              platform: .iOS,
                              product: .framework,
                              bundleId: "com.infomaniak.mail.core",
                              deploymentTarget: deploymentTarget,
                              infoPlist: "MailCore/Info.plist",
                              sources: "MailCore/**",
                              resources: [
                                  "Mail/**/*.xcassets"
//                                  "Mail/**/*.strings",
//                                  "Mail/**/*.stringsdict"
                              ],
                              dependencies: [
                                  .target(name: "MailResources"),
                                  .package(product: "Atlantis"),
                                  .package(product: "InfomaniakLogin")
                              ]
                          )
                      ],
                      fileHeaderTemplate: .file("file-header-template.txt"))
