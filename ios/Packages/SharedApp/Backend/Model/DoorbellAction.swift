import Foundation

enum DoorbellActionType: String, Codable {
    case buzzer
    case unlatch
}

struct DoorbellAction: Codable {
    let timeout: Double
    let type: DoorbellActionType
}

extension DoorbellAction {
    var timeoutDate: Date {
        Date(timeIntervalSince1970: timeout)
    }
}

extension DoorbellAction {
    static func getActiveType(_ action: DoorbellAction?) -> DoorbellActionType? {
        guard let action else {
            return nil
        }

        guard action.timeoutDate > Date() else {
            return nil
        }

        return action.type
    }
}
