import Foundation

final class AppUpdateManager {
    struct StoreInfo: Equatable {
        let version: String
        let storeURL: URL
    }

    enum CheckResult: Equatable {
        case upToDate
        case updateAvailable(StoreInfo)
        case unavailable
    }

    typealias DataLoader = (URLRequest) async throws -> (Data, URLResponse)

    private let bundleIdentifier: String
    private let currentVersion: String
    private let loadData: DataLoader

    init(
        bundleIdentifier: String = Bundle.main.bundleIdentifier ?? "",
        currentVersion: String = Bundle.main.object(
            forInfoDictionaryKey: "CFBundleShortVersionString"
        ) as? String ?? "",
        loadData: @escaping DataLoader = { request in
            try await URLSession.shared.data(for: request)
        }
    ) {
        self.bundleIdentifier = bundleIdentifier
        self.currentVersion = currentVersion
        self.loadData = loadData
    }

    func checkForUpdate() async -> CheckResult {
        guard
            let storeInfo = await fetchStoreInfo(),
            let comparison = Self.compareVersions(storeInfo.version, currentVersion)
        else {
            return .unavailable
        }

        return comparison == .orderedDescending ? .updateAvailable(storeInfo) : .upToDate
    }

    static func compareVersions(_ lhs: String, _ rhs: String) -> ComparisonResult? {
        let lhsComponents = lhs.split(separator: ".", omittingEmptySubsequences: false)
        let rhsComponents = rhs.split(separator: ".", omittingEmptySubsequences: false)

        guard
            lhsComponents.count == 3,
            rhsComponents.count == 3,
            let lhsNumbers = numericComponents(lhsComponents),
            let rhsNumbers = numericComponents(rhsComponents)
        else {
            return nil
        }

        for (lhsNumber, rhsNumber) in zip(lhsNumbers, rhsNumbers) {
            if lhsNumber < rhsNumber { return .orderedAscending }
            if lhsNumber > rhsNumber { return .orderedDescending }
        }
        return .orderedSame
    }

    private func fetchStoreInfo() async -> StoreInfo? {
        guard
            !bundleIdentifier.isEmpty,
            var components = URLComponents(string: "https://itunes.apple.com/lookup")
        else {
            return nil
        }

        components.queryItems = [URLQueryItem(name: "bundleId", value: bundleIdentifier)]
        guard let url = components.url else { return nil }

        do {
            let (data, response) = try await loadData(URLRequest(url: url))
            guard
                let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode),
                let payload = try? JSONDecoder().decode(LookupResponse.self, from: data),
                let result = payload.results.first,
                let storeURL = URL(string: result.trackViewUrl)
            else {
                return nil
            }
            return StoreInfo(version: result.version, storeURL: storeURL)
        } catch {
            return nil
        }
    }

    private static func numericComponents(_ components: [Substring]) -> [Int]? {
        let values = components.compactMap { Int($0) }
        return values.count == components.count ? values : nil
    }
}

private struct LookupResponse: Decodable {
    let results: [LookupResult]
}

private struct LookupResult: Decodable {
    let version: String
    let trackViewUrl: String
}
