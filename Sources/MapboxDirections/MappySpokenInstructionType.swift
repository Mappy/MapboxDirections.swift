import Foundation

/**
 A `MappySpokenInstructionType` indentifies the type of a SpokenInstruction instruction returned by the Mappy Directions API.
 */
public enum MappySpokenInstructionType: String, Codable {
    /**
     The spoken instruction announces an upcoming maneuver.
     */
    case maneuver

    /**
     The spoken instruction announces the entering into a zone where controls of the user driving can occur.
     */
    case controlZoneEnter

    /**
     The spoken instruction announces the exiting of a zone where controls of the user driving can occur.
     */
    case controlZoneExit
}
