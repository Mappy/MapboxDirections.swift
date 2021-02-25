import Foundation

/**
 The contents of an additional instruction that can be displayed to inform the user about a zone along which controls of his driving can occur.
 */
open class MappyControlZoneInstruction: VisualInstruction {

    private enum CodingKeys: String, CodingKey {
        case controlZoneType
        case distanceAlongRoute = "distanceUntilEndOfControlZone"
    }

    // MARK: Displaying a Control Zone banner

    /**
     The type of controls that can occur in the control zone.
     */
    public let controlZoneType: MappyControlZoneType

    /**
     The distance the user will be navigating inside the control zone if he keeps following the associated Route, measured in meters from the beginning of the control zone.
     */
    public let distanceAlongRoute: CLLocationDistance

    /**
     Initializes a new control zone instruction banner object that displays the given information.
     */
    public init(text: String?, maneuverType: ManeuverType?, maneuverDirection: ManeuverDirection?, components: [Component], controlZoneType: MappyControlZoneType, distanceAlongRoute: CLLocationDistance) {
        self.controlZoneType = controlZoneType
        self.distanceAlongRoute = distanceAlongRoute
        super.init(text: text, maneuverType: maneuverType, maneuverDirection: maneuverDirection, components: components)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(controlZoneType, forKey: .controlZoneType)
        try container.encode(distanceAlongRoute, forKey: .distanceAlongRoute)

        try super.encode(to: encoder)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        controlZoneType = (try? container.decodeIfPresent(MappyControlZoneType.self, forKey: .controlZoneType)) ?? .other
        distanceAlongRoute = try container.decode(CLLocationDistance.self, forKey: .distanceAlongRoute)

        try super.init(from: decoder)
    }
}

// MARK: - Equatable
extension MappyControlZoneInstruction {
    public static func == (lhs: MappyControlZoneInstruction, rhs: MappyControlZoneInstruction) -> Bool {
        let isSuperEqual = ((lhs as VisualInstruction) == (rhs as VisualInstruction))
        return isSuperEqual &&
            lhs.controlZoneType == rhs.controlZoneType &&
            lhs.distanceAlongRoute == rhs.distanceAlongRoute
    }
}
