import SwiftUI
import Combine

struct MoodEntryScreen: View {

    @EnvironmentObject private var launch: MoodLaunchStore
    @EnvironmentObject private var session: MoodSessionState
    @EnvironmentObject private var orientation: MoodOrientationManager

    private enum Mode: Equatable {
        case checking
        case native
        case web
    }

    @State private var mode: Mode = .checking

    @State private var showLoading: Bool = true
    @State private var minTimePassed: Bool = false
    @State private var surfaceReady: Bool = false
    @State private var pendingPoint: URL? = nil
    @State private var didApplyRotationRule: Bool = false
    @State private var didDecide: Bool = false

    var body: some View {
        ZStack {
            if mode == .native, showLoading == false {
                AppRouter()
            } else {
                MoodPlayContainer {
                    surfaceReady = true
                    applyRotationIfPossible()
                    tryDecideAndFinishLoading()
                }
                .opacity(showLoading ? 0 : 1)
                .animation(.easeOut(duration: 0.35), value: showLoading)
            }

            if showLoading {
                MoodLoadingScreen()
                    .transition(.opacity)
            }
        }
        .onAppear {
            orientation.allowFlexible()

            mode = .checking
            showLoading = true
            minTimePassed = false
            surfaceReady = false
            pendingPoint = nil
            didApplyRotationRule = false
            didDecide = false

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                minTimePassed = true
                applyRotationIfPossible()
                tryDecideAndFinishLoading()
            }
        }
        .onReceive(orientation.$activeValue) { next in
            pendingPoint = next
            applyRotationIfPossible()
        }
    }

    private func applyRotationIfPossible() {
        guard didApplyRotationRule == false else { return }
        guard minTimePassed && surfaceReady else { return }
        guard let next = pendingPoint else { return }

        if isSame(next, launch.mainPoint) {
            MoodFlowDelegate.shared?.lockPortrait()
        } else {
            MoodFlowDelegate.shared?.allowFlexible()
        }

        didApplyRotationRule = true
    }

    private func tryDecideAndFinishLoading() {
        guard minTimePassed && surfaceReady else { return }
        guard didDecide == false else {
            if showLoading {
                withAnimation(.easeOut(duration: 0.35)) { showLoading = false }
            }
            return
        }

        didDecide = true

        let current = pendingPoint ?? launch.mainPoint
        if isSame(current, launch.mainPoint) {
            mode = .native
        } else {
            mode = .web
        }

        withAnimation(.easeOut(duration: 0.35)) {
            showLoading = false
        }
    }

    private func isSame(_ a: URL, _ b: URL) -> Bool {
        normalize(a) == normalize(b)
    }

    private func normalize(_ u: URL) -> String {
        var s = u.absoluteString
        while s.count > 1, s.hasSuffix("/") { s.removeLast() }
        return s
    }
}
