import Granite
import SwiftUI
import AuthenticationServices

extension Config: View {
    public var view: some View {
        VStack {
            if account.state.isLoggedIn {
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
                Label(state.isMountClosed ? "Show" : "Hide",
                      systemImage: state.isMountClosed ? "eye" : "eye.slash")
                    .onTapGesture {
                        let nc = NotificationCenter.default
                        nc.post(name: Notification.Name("ShowHideMount"), object: nil)
                        center.$state.binding.isMountClosed.wrappedValue.toggle()
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
        SignInWithAppleButton(.signIn) { request in
            request.requestedScopes = [ .email, .fullName ]
            request.nonce = account.sha256(account.randomNonceString())
            MenuBarManager.shared.maintainPopover = true
        } onCompletion: { result in
            switch result {
            case .success(let authResults):
                account.center.login.send(AccountService.Login.Meta(authResults: authResults))
                
                print("Authorisation successful")
            default:
                print("{TEST} failed")
            }
            
            MenuBarManager.shared.maintainPopover = false
        }
    }
    
    
}

struct ContentView: View {
    var body: some View {
        Text("Hello World")
    }
}
