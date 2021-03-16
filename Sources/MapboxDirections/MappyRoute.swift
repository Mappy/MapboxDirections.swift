import Foundation

/**
 A `MappyRouteType` indentifies the type of a route object returned by the Mappy Directions API.
 */
public enum MappyRouteType: String, Codable
{
    /**
     The route is an updated version (durations, traffic, etc) of a previous route following a given itinerary.
     */
    case current
    /**
     The route is a faster alternative to a route of type `current` returned in the same Directions response.

     The route starts and ends at the same waypoints than the `current` route returned along in the same response.
     */
    case best
}

/**
 A `MapppyRoute` object is a normal `Route` object with additionnal data specific to Mappy API.
 */
public class MappyRoute: Route {
    private enum CodingKeys: String, CodingKey {
        case routeType = "mappy_designation"
        case signature = "mappy_signature"
        case isInLowEmissionZone = "route_in_low_emission_zone"
    }

    public let routeType: MappyRouteType
    public let signature: String
    public let isInLowEmissionZone: Bool
    public var congestionColors: [String: String]?

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(routeType, forKey: .routeType)
        try container.encode(signature, forKey: .signature)
        try container.encode(isInLowEmissionZone, forKey: .isInLowEmissionZone)

        try super.encode(to: encoder)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        routeType = (try? container.decodeIfPresent(MappyRouteType.self, forKey: .routeType)) ?? .current
        signature = try container.decodeIfPresent(String.self, forKey: .signature) ?? ""
        isInLowEmissionZone = try container.decodeIfPresent(Bool.self, forKey: .isInLowEmissionZone) ?? false
        congestionColors = nil // assigned from parsing of RouteResponse

        try super.init(from: decoder)
    }
}

// MARK: - Equatable
extension MappyRoute {
    public static func == (lhs: MappyRoute, rhs: MappyRoute) -> Bool {
        let isSuperEqual = ((lhs as Route) == (rhs as Route))
        return isSuperEqual &&
            lhs.routeType == rhs.routeType &&
            lhs.signature == rhs.signature &&
            lhs.isInLowEmissionZone == rhs.isInLowEmissionZone &&
            lhs.congestionColors == rhs.congestionColors
    }
}
