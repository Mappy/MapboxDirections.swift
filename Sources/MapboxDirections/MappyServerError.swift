import Foundation

/**
 Information about an error that occured on Mappy servers while calculating directions.
 */
public struct MappyServerError: Decodable {
    public let errorId: String
    public let message: String
    public let status: Int

    enum CodingKeys: String, CodingKey {
        case errorId = "id"
        case message
        case status
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        errorId = try container.decodeIfPresent(String.self, forKey: .errorId) ?? "no id"
        message = try container.decodeIfPresent(String.self, forKey: .message) ?? "no message"
        status = try container.decodeIfPresent(Int.self, forKey: .status) ?? -1
    }
}

//MARK: - Equatable
extension MappyServerError: Equatable {
    public static func == (lhs: MappyServerError, rhs: MappyServerError) -> Bool {
        return lhs.errorId == rhs.errorId &&
            lhs.message == rhs.message &&
            lhs.status == rhs.status
    }
}
