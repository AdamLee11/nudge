//
//  ContentView.swift
//  Nudge
//
//  Created by Erik Gomez on 2/2/21.
//

import SwiftUI

// https://stackoverflow.com/a/66039864
// https://gist.github.com/steve228uk/c960b4880480c6ed186d

class ViewState: ObservableObject {
    @Published var shouldExit = false
    @Published var userDeferrals = nudgeDefaults.object(forKey: "userDeferrals") as? Int ?? 0
    @Published var userSessionDeferrals = nudgeDefaults.object(forKey: "userSessionDeferrals") as? Int ?? 0
    @Published var userQuitDeferrals = nudgeDefaults.object(forKey: "userQuitDeferrals") as? Int ?? 0
    @Published var userRequiredMinimumOSVersion = nudgeDefaults.object(forKey: "requiredMinimumOSVersion") as? String ?? "0.0"
    @Published var deferRunUntil = nudgeDefaults.object(forKey: "deferRunUntil") as? Date
    @Published var requireDualQuitButtons = false
    @Published var hasLoggedDeferralCountPastThresholdDualQuitButtons = false
}

// BackgroundView
struct BackgroundView: View {
    @StateObject var viewState = nudgePrimaryState
    var body: some View {
        if simpleMode() {
            SimpleMode(viewObserved: viewState)
        } else {
            StandardMode(viewObserved: viewState)
        }
    }
}

struct ContentView: View {
    var body: some View {
        BackgroundView().background(
            HostingWindowFinder { window in
                window?.standardWindowButton(.closeButton)?.isHidden = true //hides the red close button
                window?.standardWindowButton(.miniaturizeButton)?.isHidden = true //hides the yellow miniaturize button
                window?.standardWindowButton(.zoomButton)?.isHidden = true //this removes the green zoom button
                window?.center() // center
                window?.isMovable = false // not movable
                _ = needToActivateNudge(lastRefreshTimeVar: lastRefreshTime)
            }
        )
        .edgesIgnoringSafeArea(.all)
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        StandardMode(viewObserved: nudgePrimaryState)
            .preferredColorScheme(.light)
        ZStack {
            StandardMode(viewObserved: nudgePrimaryState)
                .preferredColorScheme(.dark)
        }
        SimpleMode(viewObserved: nudgePrimaryState)
            .preferredColorScheme(.light)
        ZStack {
            SimpleMode(viewObserved: nudgePrimaryState)
                .preferredColorScheme(.dark)
        }
    }
}
#endif

struct HostingWindowFinder: NSViewRepresentable {
    var callback: (NSWindow?) -> ()

    func makeNSView(context: Self.Context) -> NSView {
        let view = NSView()
        if Utils().versionArgumentPassed() {
            print(Utils().getNudgeVersion())
            Utils().exitNudge()
        }
        
        DispatchQueue.main.async { [weak view] in
            self.callback(view?.window)
        }
        return view
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}

// Stuff if we ever implement fullscreen
//        let presentationOptions: NSApplication.PresentationOptions = [
//            .hideDock, // Dock is entirely unavailable. Spotlight menu is disabled.
//            // .autoHideMenuBar,           // Menu Bar appears when moused to.
//            // .disableAppleMenu,          // All Apple menu items are disabled.
//            .disableProcessSwitching      // Cmd+Tab UI is disabled. All Exposé functionality is also disabled.
//            // .disableForceQuit,             // Cmd+Opt+Esc panel is disabled.
//            // .disableSessionTermination,    // PowerKey panel and Restart/Shut Down/Log Out are disabled.
//            // .disableHideApplication,       // Application "Hide" menu item is disabled.
//            // .autoHideToolbar,
//            // .fullScreen
//        ]
//        let optionsDictionary = [NSView.FullScreenModeOptionKey.fullScreenModeApplicationPresentationOptions: presentationOptions]
//        if let screen = NSScreen.main {
//            view.enterFullScreenMode(screen, withOptions: [NSView.FullScreenModeOptionKey.fullScreenModeApplicationPresentationOptions:presentationOptions.rawValue])
//        }
//        //view.enterFullScreenMode(NSScreen.main!, withOptions: optionsDictionary)
