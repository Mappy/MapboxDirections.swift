import Foundation


struct ResponseDisposition: Decodable {
    var code: String?
    var message: String?
    var error: String?
    var mappyError: MappyServerError?
    
    private enum CodingKeys: CodingKey {
        case code, message, error
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        code = try container.decodeIfPresent(String.self, forKey: .code)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        error = try? container.decodeIfPresent(String.self, forKey: .error)
        mappyError = try? container.decodeIfPresent(MappyServerError.self, forKey: .error)
    }
}
