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

import AuthenticationServices
import InfomaniakCore
import InfomaniakLogin
import MailCore
import MailResources
import SwiftUI

struct OnboardingView: View {
    @StateObject var viewModel = OnboardingViewModel()
    @State private var selection: Int
    @State private var presentAlert = false
    @State private var isLoading = false

    @Environment(\.window) var window

    var isPresentedModally: Bool

    init(isPresentedModally: Bool = false, page: Int = 1) {
        _selection = State(initialValue: page)
        self.isPresentedModally = isPresentedModally
        UIPageControl.appearance().currentPageIndicatorTintColor = .tintColor
        UIPageControl.appearance().pageIndicatorTintColor = MailResourcesAsset.separatorColor.color
    }

    var body: some View {
        VStack(spacing: 0) {
            // Slides
            ZStack(alignment: .top) {
                TabView(selection: $selection) {
                    ForEach(viewModel.slides) { slide in
                        SlideView(slide: slide)
                            .tag(slide.id)
                    }
                }
                .tabViewStyle(.page)
                .edgesIgnoringSafeArea(.top)

                Image(resource: MailResourcesAsset.logoText)
                    .resizable()
                    .scaledToFit()
                    .frame(height: Constants.onboardingLogoHeight)
                    .padding(.top, isPresentedModally ? 15 : 0)
            }

            // Buttons
            VStack(spacing: 24) {
                if selection == viewModel.slides.count {
                    // Show login button
                    LargeButton(title: MailResourcesStrings.Localizable.buttonLogin, isLoading: isLoading, action: login)
                    Button {
                        // TODO: Create account
                        showWorkInProgressSnackBar()
                    } label: {
                        Text(MailResourcesStrings.Localizable.buttonCreateAccount)
                            .textStyle(.button)
                    }
                } else {
                    Button {
                        withAnimation {
                            selection += 1
                        }
                    } label: {
                        Image(systemName: "arrow.right")
                            .imageScale(.large)
                            .font(.title3.weight(.semibold))
                            .frame(width: 36, height: 46)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                }
            }
            .frame(height: Constants.onboardingButtonHeight + Constants.onboardingVerticalPadding, alignment: .top)
        }
        .alert(MailResourcesStrings.Localizable.errorLoginTitle, isPresented: $presentAlert) {
            // Use default button
        } message: {
            Text(MailResourcesStrings.Localizable.errorLoginDescription)
        }
    }

    // MARK: - Private methods

    private func login() {
        isLoading = true
        InfomaniakLogin.asWebAuthenticationLoginFrom(useEphemeralSession: true) { result in
            switch result {
            case .success(let result):
                loginSuccessful(code: result.code, codeVerifier: result.verifier)
            case .failure(let error):
                loginFailed(error: error)
            }
        }
    }

    private func loginSuccessful(code: String, codeVerifier verifier: String) {
        MatomoUtils.track(eventWithCategory: .account, name: "loggedIn")
        let previousAccount = AccountManager.instance.currentAccount
        Task {
            do {
                _ = try await AccountManager.instance.createAndSetCurrentAccount(code: code, codeVerifier: verifier)
                MatomoUtils.connectUser()
                (self.window?.windowScene?.delegate as? SceneDelegate)?.showMainView()
            } catch {
                if let previousAccount = previousAccount {
                    AccountManager.instance.switchAccount(newAccount: previousAccount)
                }
                IKSnackBar.showSnackBar(message: error.localizedDescription)
            }
            isLoading = false
        }
    }

    private func loginFailed(error: Error) {
        print("Login error: \(error)")
        isLoading = false
        guard (error as? ASWebAuthenticationSessionError)?.code != .canceledLogin else { return }
        presentAlert = true
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
        OnboardingView(isPresentedModally: true)
    }
}
