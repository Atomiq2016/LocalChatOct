import UIKit
import BackgroundTasks

class AppDelegate: NSObject, UIApplicationDelegate {
    private var cleanupTimer: Timer?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        if #available(iOS 13.0, *) {
            BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.localchat.cleanup", using: nil) { task in
                self.handleCleanup(task: task as! BGProcessingTask)
            }
        } else {
            // Fallback for iOS 11-12
            cleanupTimer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { _ in
                self.handleCleanupLegacy()
            }
        }
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if #available(iOS 13.0, *) {
            scheduleCleanup()
        }
    }

    @available(iOS 13.0, *)
    func scheduleCleanup() {
        let request = BGProcessingTaskRequest(identifier: "com.localchat.cleanup")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 3600)
        request.requiresNetworkConnectivity = false
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Scheduled cleanup task")
        } catch {
            print("Failed to schedule cleanup: \(error)")
        }
    }

    @available(iOS 13.0, *)
    func handleCleanup(task: BGProcessingTask) {
        scheduleCleanup()
        DatabaseManager.shared.deleteOldMessages()
        task.setTaskCompleted(success: true)
        print("Completed cleanup task")
    }

    @available(iOS 11.0, *)
    func handleCleanupLegacy() {
        DatabaseManager.shared.deleteOldMessages()
        print("Completed legacy cleanup task")
    }
}
