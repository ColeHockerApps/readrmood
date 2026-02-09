import UIKit
import SwiftUI

final class MoodFlowDelegate: NSObject, UIApplicationDelegate {

    static weak var shared: MoodFlowDelegate?

    private var forcedMask: UIInterfaceOrientationMask = [.portrait]

    override init() {
        super.init()
        MoodFlowDelegate.shared = self
    }

    func lockPortrait() {
        forcedMask = [.portrait]
        UIViewController.attemptRotationToDeviceOrientation()
    }

    func allowFlexible() {
        forcedMask = [.portrait, .landscapeLeft, .landscapeRight]
        UIViewController.attemptRotationToDeviceOrientation()
    }

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        forcedMask
    }
}
