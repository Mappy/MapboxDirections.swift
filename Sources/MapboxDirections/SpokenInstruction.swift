import Foundation
#if canImport(CoreLocation)
import CoreLocation
#else
import Turf
#endif

/**
 An instruction about an upcoming `RouteStep`’s maneuver, optimized for speech synthesis.

 The instruction is provided in two formats: plain text and text marked up according to the [Speech Synthesis Markup Language](https://en.wikipedia.org/wiki/Speech_Synthesis_Markup_Language) (SSML). Use a speech synthesizer such as `AVSpeechSynthesizer` or Amazon Polly to read aloud the instruction.

 The `distanceAlongStep` property is measured from the beginning of the step associated with this object. By contrast, the `text` and `ssmlText` properties refer to the details in the following step. It is also possible for the instruction to refer to two following steps simultaneously when needed for safe navigation.
 */
open class SpokenInstruction: Codable {
    private enum CodingKeys: String, CodingKey {
        case distanceAlongStep = "distanceAlongGeometry"
        case text = "announcement"
        case ssmlText = "ssmlAnnouncement"
        case mappyType = "instructionType"
    }
    
    // MARK: Creating a Spoken Instruction
    
    /**
     Initialize a spoken instruction.

     - parameter distanceAlongStep: A distance along the associated `RouteStep` at which to read the instruction aloud.
     - parameter text: A plain-text representation of the speech-optimized instruction.
     - parameter ssmlText: A formatted representation of the speech-optimized instruction.
     */
    public init(distanceAlongStep: CLLocationDistance, text: String, ssmlText: String, mappyType: MappySpokenInstructionType = .maneuver) {
        self.distanceAlongStep = distanceAlongStep
        self.text = text
        self.ssmlText = ssmlText
        self.mappyType = mappyType
	}

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(distanceAlongStep, forKey: .distanceAlongStep)
        try container.encode(text, forKey: .text)
        try container.encode(ssmlText, forKey: .ssmlText)
        // Don't encode spoken instruction type for default value
        if mappyType != .maneuver {
        	try container.encode(mappyType, forKey: .mappyType)
        }
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        distanceAlongStep = try container.decode(CLLocationDistance.self, forKey: .distanceAlongStep)
        text = try container.decode(String.self, forKey: .text)
        ssmlText = try container.decodeIfPresent(String.self, forKey: .ssmlText) ?? ""
        mappyType = (try? container.decodeIfPresent(MappySpokenInstructionType.self, forKey: .mappyType)) ?? .maneuver
    }
    
    // MARK: Timing When to Say the Instruction
    
    /**
     A distance along the associated `RouteStep` at which to read the instruction aloud.

     The distance is measured in meters from the beginning of the associated step.
     */
    public let distanceAlongStep: CLLocationDistance
    
    // MARK: Getting the Instruction to Say
    
    /**
     A plain-text representation of the speech-optimized instruction.

     This representation is appropriate for speech synthesizers that lack support for the [Speech Synthesis Markup Language](https://en.wikipedia.org/wiki/Speech_Synthesis_Markup_Language) (SSML), such as `AVSpeechSynthesizer`. For speech synthesizers that support SSML, use the `ssmlText` property instead.
     */
    public let text: String

    /**
     A formatted representation of the speech-optimized instruction.
     
     This representation is appropriate for speech synthesizers that support the [Speech Synthesis Markup Language](https://en.wikipedia.org/wiki/Speech_Synthesis_Markup_Language) (SSML), such as [Amazon Polly](https://aws.amazon.com/polly/). Numbers and names are marked up to ensure correct pronunciation. For speech synthesizers that lack SSML support, use the `text` property instead.
     */
    public let ssmlText: String

    /**
     The type of the instruction when returned by the Mappy Directions API.

     The default value for non-Mappy API is .maneuver.
     */
    public let mappyType: MappySpokenInstructionType
}

extension SpokenInstruction: Equatable {
    public static func == (lhs: SpokenInstruction, rhs: SpokenInstruction) -> Bool {
        return lhs.distanceAlongStep == rhs.distanceAlongStep &&
            lhs.text == rhs.text &&
            lhs.ssmlText == rhs.ssmlText &&
            lhs.mappyType == rhs.mappyType
    }
}
