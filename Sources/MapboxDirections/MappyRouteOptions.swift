import Foundation

/**
 The walking speed of the user.

 Only used for pedestrian itineraries.
 */
public enum MappyWalkSpeed: String, Codable {
    case slow, normal, fast
}

/**
 The cycling speed of the user.

 Only used for bike itineraries.
 */
public enum MappyBikeSpeed: String, Codable {
    case slow, normal, fast
}

open class MappyRouteOptions: RouteOptions {
    // MARK: - Initializers

    /**
     Initializes a route options object for routes between the given waypoints

     The calculated route will be optimized for the given provider and respect the route calculation type.
     */
    public init(waypoints: [Waypoint], providers: [String], routeTypes: [String], qid: String) {
        self.providers = providers
        self.routeTypes = routeTypes
        self.qid = qid
        self.additionalQueryParams = [String:String]()

        super.init(waypoints: waypoints, profileIdentifier: .automobileAvoidingTraffic)
        self.commonInit()
    }

    /**
     Initializes a route options object for routes between the given waypoints.

     The calculated route will be optimized for the given provider and respect the route calculation type.

     Known options will be pulled from additionalQueryParams and assigned to their respective properties,
     other keys present in the dictionnary will be sent to the API as URL query parameters.
     */
    public init(waypoints: [Waypoint], providers: String, additionalQueryParams params: [String:String]) {
        self.providers = providers.components(separatedBy: ";")

        self.routeTypes = params["route_type"]?.components(separatedBy: ";") ?? []
        self.qid = params["qid"] ?? ""
        self.carVehicle = params["vehicle"]
        self.motorbikeVehicule = params["motorbike_vehicle"]
        if let walkSpeed = params["walk_speed"] {
            self.walkSpeed = MappyWalkSpeed(rawValue: walkSpeed)
        }
        if let bikeSpeed = params["bike_speed"] {
            self.bikeSpeed = MappyBikeSpeed(rawValue: bikeSpeed)
        }

        var cleanedParams = params
        cleanedParams["route_type"] = nil
        cleanedParams["qid"] = nil
        cleanedParams["vehicle"] = nil
        cleanedParams["motorbike_vehicle"] = nil
        cleanedParams["walk_speed"] = nil
        cleanedParams["bike_speed"] = nil

        self.additionalQueryParams = cleanedParams

        super.init(waypoints: waypoints, profileIdentifier: .automobileAvoidingTraffic)
        self.commonInit()
    }

    public required init(waypoints: [Waypoint], profileIdentifier: DirectionsProfileIdentifier?) {
        fatalError("Please use either init(waypoints:providers:routeTypes:qid:) or init(waypoints:providers:additionalQueryParams:) to create a MappyRouteOptions")
    }

    #if canImport(CoreLocation)
    /**
     Initializes a route options object for routes between the given locations.
     */
    public convenience init(locations: [CLLocation], providers: [String], routeTypes: [String], qid: String) {
        let waypoints = locations.map { Waypoint(location: $0) }
        self.init(waypoints: waypoints, providers: providers, routeTypes: routeTypes, qid: qid)
    }
    #endif

    /**
     Initializes a route options object for routes between the given geographic coordinates.
     */
    public convenience init(coordinates: [CLLocationCoordinate2D], providers: [String], routeTypes: [String], qid: String) {
        let waypoints = coordinates.map { Waypoint(coordinate: $0) }
        self.init(waypoints: waypoints, providers: providers, routeTypes: routeTypes, qid: qid)
    }

    private func commonInit() {
        // DirectionsOptions properties
        includesSteps = true
        shapeFormat = .polyline
        routeShapeResolution = .full
        attributeOptions = []
        locale = Locale.current
        distanceMeasurementSystem = .metric
        includesSpokenInstructions = true
        includesVisualInstructions = true

        // RouteOptions properties
        allowsUTurnAtWaypoint = false
        includesAlternativeRoutes = true
        includesExitRoundaboutManeuver = false
        roadClassesToAvoid = []
    }

    private enum CodingKeys: String, CodingKey {
        case providers
        case routeTypes
        case qid
        case additionalQueryParams
        case routeSignature
        case carVehicle
        case motorbikeVehicule
        case walkSpeed
        case bikeSpeed
        case forceBetterRoute
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(providers, forKey: .providers)
        try container.encode(routeTypes, forKey: .routeTypes)
        try container.encode(qid, forKey: .qid)
        try container.encode(additionalQueryParams, forKey: .additionalQueryParams)
        try container.encodeIfPresent(routeSignature, forKey: .routeSignature)
        try container.encodeIfPresent(carVehicle, forKey: .carVehicle)
        try container.encodeIfPresent(motorbikeVehicule, forKey: .motorbikeVehicule)
        try container.encodeIfPresent(walkSpeed, forKey: .walkSpeed)
        try container.encodeIfPresent(bikeSpeed, forKey: .bikeSpeed)
        try container.encodeIfPresent(forceBetterRoute, forKey: .forceBetterRoute)

        try super.encode(to: encoder)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        providers = try container.decode([String].self, forKey: .providers)
        routeTypes = try container.decode([String].self, forKey: .routeTypes)
        qid = try container.decode(String.self, forKey: .qid)
        additionalQueryParams = try container.decode(Dictionary<String, String>.self, forKey: .additionalQueryParams)
        routeSignature = try container.decodeIfPresent(String.self, forKey: .routeSignature)
        carVehicle = try container.decodeIfPresent(String.self, forKey: .carVehicle)
        motorbikeVehicule = try container.decodeIfPresent(String.self, forKey: .motorbikeVehicule)
        walkSpeed = try? container.decodeIfPresent(MappyWalkSpeed.self, forKey: .walkSpeed)
        bikeSpeed = try? container.decodeIfPresent(MappyBikeSpeed.self, forKey: .bikeSpeed)
        forceBetterRoute = try container.decodeIfPresent(Bool.self, forKey: .forceBetterRoute) ?? false

        try super.init(from: decoder)
    }

    // MARK: - Properties

    public let apiVersion: String = "1.0"

    /**
     The providers used to calculate the itinerary of each leg of the route.

     One value per leg must be provided (N -1 values for N waypoints).
     */
    open var providers: [String]

    /**
     Which type of itinerary should be calculated for each leg of the route.

     The acceptable values depend on the provider specified for the respective leg.
     One value per route leg must be provided (N -1 values for N waypoints).
     */
    open var routeTypes: [String]

    /**
     QID used in initial transport/routes requests.
     */
    open var qid: String

    /**
     Additional params to be passed in request URL.

     Known params are removed from this array and set to the corresponding property.
     */
    open var additionalQueryParams: [String:String]

    /**
     Opaque `Route` signature if requesting the server an updated version of an existing route.
     */
    open var routeSignature: String?

    /**
     Vehicle used for car transportation by the user.
     */
    open var carVehicle: String?

    /**
     Vehicle used for motorbike transportation by the user.
     */
    open var motorbikeVehicule: String?

    /**
     Walking speed of the user (only for pedestrian itineraries).
     */
    open var walkSpeed: MappyWalkSpeed?

    /**
     Cycling speed of the user (only for bike itineraries).
     */
    open var bikeSpeed: MappyBikeSpeed?

    /**
     Debug parameter to force the service to respond with an arbitrary alternative route that will be marked as better.
     */
    open var forceBetterRoute: Bool = false

    // MARK: - Overrides

    internal override var abridgedPath: String {
        let providers = self.providers.joined(separator: ";")
        return "gps/\(apiVersion)/\(providers)"
    }

    /**
     The path of the request URL, not including the hostname or any parameters.
     */
    internal override var path: String {
        return super.path.replacingOccurrences(of: ".json", with: "")
    }

    internal override var coordinates: String? {
        return waypoints.map { $0.coordinate.mappyRequestDescription }.joined(separator: ";")
    }

    internal override var waypointNames: String? {
        return waypoints.map({ $0.name ?? "" }).joined(separator: ";")
    }

    /**
     An array of URL parameters to include in the request URL.
     */
    override open var urlQueryItems: [URLQueryItem] {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "geometries", value: String(describing: shapeFormat)),
            URLQueryItem(name: "lang", value: locale.identifier),
            URLQueryItem(name: "qid", value: qid),
            URLQueryItem(name: "route_type", value: routeTypes.joined(separator: ";"))
        ]

        if self.routeSignature != nil {
            queryItems.append(URLQueryItem(name: "alternatives", value: String(includesAlternativeRoutes)))
            if self.forceBetterRoute == true && self.includesAlternativeRoutes == true {
                queryItems.append(URLQueryItem(name: "dev_better_route_threshold", value: "-1"))
            }
        }

        if let bearing = self.waypoints.first?.heading,
           bearing >= 0 {
            queryItems.append(URLQueryItem(name: "bearing", value: "\(Int(bearing.truncatingRemainder(dividingBy: 360)))"))
        }
        if let carVehicle = carVehicle {
            queryItems.append(URLQueryItem(name: "vehicle", value: carVehicle))
        }
        if let motorbikeVehicule = motorbikeVehicule {
            queryItems.append(URLQueryItem(name: "motorbike_vehicle", value: motorbikeVehicule))
        }
        if let walkSpeed = walkSpeed {
            queryItems.append(URLQueryItem(name: "walk_speed", value: walkSpeed.rawValue))
        }
        if let bikeSpeed = bikeSpeed {
            queryItems.append(URLQueryItem(name: "bike_speed", value: bikeSpeed.rawValue))
        }

        if let names = self.waypointNames {
            queryItems.append(URLQueryItem(name: "waypoint_names", value: names))
        }

        let additionalQueryItems = self.additionalQueryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        queryItems.append(contentsOf: additionalQueryItems)

        return queryItems
    }

    /**
     Data to send in the request body.
     */
    override internal var data: Data? {
        if let signature = self.routeSignature {
            let json = ["mappy_signature": signature]
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            return data
        }
        return nil
    }

    /**
     Content-Type to set for the request if `requestData` is not nil.
     */
    override internal var contentType: String? {
        return "application/json"
    }
}
