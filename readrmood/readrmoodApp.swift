import SwiftUI
import Combine

@main
struct ReadrMoodlyticApp: App {

    @UIApplicationDelegateAdaptor(MoodFlowDelegate.self) private var flow

    @StateObject private var theme = AppTheme()
    @StateObject private var persistence = PersistenceStore()
    @StateObject private var settings = SettingsViewModel()
    @StateObject private var readingRepo = ReadingRepository()
    @StateObject private var sessionsRepo = SessionsRepository()
    @StateObject private var achievementsRepo = AchievementsRepository()

    @StateObject private var moodLaunch = MoodLaunchStore()
    @StateObject private var moodSession = MoodSessionState()
    @StateObject private var moodOrientation = MoodOrientationManager()

    var body: some Scene {
        WindowGroup {
            MoodEntryScreen()
                .environmentObject(theme)
                .environmentObject(persistence)
                .environmentObject(settings)
                .environmentObject(readingRepo)
                .environmentObject(sessionsRepo)
                .environmentObject(achievementsRepo)
                .environmentObject(moodLaunch)
                .environmentObject(moodSession)
                .environmentObject(moodOrientation)
                .preferredColorScheme(.dark)
        }
    }
}
