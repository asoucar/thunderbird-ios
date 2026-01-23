public struct Folder: Identifiable {
    public enum Status {

    }

    public let name: String
    public let unreadCount: Int
    public let visibleLimit: Int
    public let status: Status
    public let flaggedCount: Int
    public let integrate: Int
    public let topGroup: Int
    public let isSyncEnabled: Bool
    public let isPushEnabled: Bool
    public let isVisible: Bool
    public let isNotificationsEnabled: Bool
    public let moreMessages: String
    public let serverID: String
    public let isLocalOnly: Bool
    public let type: String

    // MARK: Identifiable
    public let id: String
}
