import Foundation

/**
 `MappyControlZoneType` describes the type of `MappyControlZoneInstruction`.
 */
public enum MappyControlZoneType: String, Codable {
    /**
     The controls that can occur in the zone refer to the user driving speed.
     */
    case speed

    /**
     The controls that can occur in the zone refer to unknown or undisclosed aspects of the user driving.
     */
    case other = "miscellanous"
}
