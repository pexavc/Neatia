import Granite
import SwiftUI
import AuthenticationServices
import SandKit

extension Config: View {
    
    public var view: some View {
        VStack {
            if session.isLoggedIn {
                mainView
            } else {
                signInView
                    .toolbar {
                    ToolbarItem(placement: .principal) {
                        Button {
                        } label: {
                            Label {
                                Text("General")
                            } icon: {
                                Image (systemName: "gearshape")
                            }//custom label style
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var mainView: some View {
        NavigationView {
            List {
                Label(windowVisibility.isVisible ? "Hide" : "Show",
                      systemImage: windowVisibility.isVisible ? "eye.slash" : "eye")
                    .onTapGesture {
                        let nc = NotificationCenter.default
                        nc.post(name: Notification.Name("nyc.stoic.Neatia.ShowHideMount"), object: nil)
                    }
                Spacer()
                
                //Caption
                Text("General")
                //Navigation links
                //Replace "ContentView" with your destination
                Group{
                    NavigationLink(destination:
                                    AccountConfigView()
                        .attach(account.center.subscribe, at: \.subscribe), isActive: center.$state.binding.isAccountTabActive) {
                        Label("Account", systemImage: "person")
                    }
                    NavigationLink(destination: GeneralConfigView()) {
                        Label("Settings", systemImage: "gear")
                    }
                    NavigationLink(destination: AboutConfigView()) {
                        Label("About", systemImage: "questionmark.circle")
                    }
                }
                Spacer()
                Text("Customize")
                Group {
                    NavigationLink(destination: PromptConfigView()) {
                        Label("Prompts", systemImage: "note.text")
                    }
                    
                    NavigationLink(destination: ShortcutConfigView()) {
                        Label("Shortcuts", systemImage: "option")
                    }
                }
                //Add some space again!
                Spacer()
                //Divider also looks great!
                Divider()
                Group {
                    Label("Logout", systemImage: "togglepower")
                        .onTapGesture(account.center.logout)
                    
                    Label("Quit", systemImage: "power")
                        .onTapGesture { NSApp.terminate(self) }
                }
            }
            .listStyle(SidebarListStyle())
            //Set Sidebar Width (and height)
            .frame(minWidth: 150, idealWidth: 250, maxWidth: 300)
        }
    }
    
    var signInView: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 16) {
                    LogoView()
                        .frame(width: 120, height: 120)
                    
                    VStack {
                        AppBlurView(size: .init(0, 80),
                                    tintColor: Brand.Colors.black.opacity(0.3)) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Neatia")
                                    .font(Fonts.live(.title2, .bold))
                                    .foregroundColor(.foreground)
                                
                                Text("New sight.")
                                    .font(Fonts.live(.headline, .regular))
                                    .foregroundColor(.foreground)
                            }
                        }
                        .environment(\.colorScheme, .dark)
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
                .padding(.top, WindowComponent.Style.defaultComponentOuterPadding)
                .padding(.horizontal, WindowComponent.Style.defaultComponentOuterPadding)
                
//                AppBlurView(size: .init(0, 200),
//                            tintColor: Brand.Colors.black.opacity(0.3)) {
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Neatia turns the world of AI chat bots into an easy to access shortcut on your Mac.\n\n(⌥ + N) and get an answer that could jump start a workflow, remove writer's block, or help with that job hunt.\n")
//                            .font(Fonts.live(.headline, .regular))
//                            .foregroundColor(.foreground)
//
//                        Text("Sign-in and pick a membership plan to get started.")
//                            .font(Fonts.live(.headline, .regular))
//                            .foregroundColor(.foreground)
//                    }
//                }
//                .environment(\.colorScheme, .dark)
                
                
                
                FeatureImageSliderView()
                
                
                Spacer()
                
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [ .email, .fullName ]
                    request.nonce = account.sha256(account.randomNonceString())
                    MenuBarManager.shared.maintainPopover = true
                } onCompletion: { result in
                    switch result {
                    case .success(let authResults):
                        account.center.login.send(AccountService.Login.Meta(authResults: authResults))
                    default:
                        break
                    }
                    
                    MenuBarManager.shared.maintainPopover = false
                }
                .padding(.horizontal, WindowComponent.Style.defaultComponentOuterPadding)
                .padding(.bottom, WindowComponent.Style.defaultComponentOuterPadding)
            }
            
            VStack {
                MarqueeTextView(
                    text: Prompts.allCases.map({ "/"+$0.rawValue.capitalized+"..." }).joined(separator: "   "),
                    fontSize: .headline,
                    fontWeight: .bold,
                    leftFade: 16,
                    rightFade: 16,
                    startDelay: 3
                )
                .frame(width: 360)
                Spacer()
            }
            .rotationEffect(.degrees(90))
        }
    }
}
