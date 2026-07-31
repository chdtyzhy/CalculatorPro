import Foundation

final class AppReviewManager {
    private enum Keys {
        static let launchCount = "appReview.launchCount"
        static let lastAutomaticRequestDate = "appReview.lastAutomaticRequestDate"
    }

    private static let initialRequestLaunchCount = 5
    private static let automaticRequestInterval: TimeInterval = 30 * 24 * 60 * 60

    private let userDefaults: UserDefaults
    private let now: () -> Date
    private var hasRecordedLaunch = false

    init(
        userDefaults: UserDefaults = .standard,
        now: @escaping () -> Date = Date.init
    ) {
        self.userDefaults = userDefaults
        self.now = now
    }

    func recordLaunchAndShouldRequestAutomaticReview() -> Bool {
        guard !hasRecordedLaunch else { return false }
        hasRecordedLaunch = true

        let launchCount = userDefaults.integer(forKey: Keys.launchCount) + 1
        userDefaults.set(launchCount, forKey: Keys.launchCount)

        guard launchCount >= Self.initialRequestLaunchCount else {
            return false
        }

        let requestDate = now()
        if let lastAutomaticRequestDate = userDefaults.object(
            forKey: Keys.lastAutomaticRequestDate
        ) as? Date,
           requestDate.timeIntervalSince(lastAutomaticRequestDate) < Self.automaticRequestInterval {
            return false
        }

        userDefaults.set(requestDate, forKey: Keys.lastAutomaticRequestDate)
        return true
    }
}
