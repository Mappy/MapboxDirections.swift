import UIKit
import CoreLocation
import MapboxDirections
import Mapbox

class ViewController: UIViewController, MBDrawingViewDelegate {
    @IBOutlet var mapView: MGLMapView!
    var drawingView: MBDrawingView?
    var segmentedControl: UISegmentedControl!
    static let initialMapCenter = CLLocationCoordinate2D(latitude: 37.3300, longitude: -122.0312)
    static let initialZoom: Double = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(ViewController.initialMapCenter, animated: false)
        mapView.setZoomLevel(ViewController.initialZoom, animated: false)
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        view.addSubview(mapView)
        
        setUpSegmentedControls()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setUpSegmentedControls() {
        let items = ["Move", "Draw", "Directions"]
        segmentedControl = UISegmentedControl(items: items)
        let frame = UIScreen.main.bounds
        segmentedControl.frame = CGRect(x: frame.minX + 10, y: frame.minY + 50, width: frame.width - 20, height: 30)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = .white
        segmentedControl.addTarget(self, action: #selector(segmentedValueChanged(_:)), for: .valueChanged)
        self.view.addSubview(segmentedControl)
    }
    
    @objc func segmentedValueChanged(_ sender: UISegmentedControl) {
        resetDrawingView()
        
        switch sender.selectedSegmentIndex {
        case 1:
            setupDrawingView()
        case 2:
            setupDirections()
        default:
            return
        }
    }
    
    func resetDrawingView() {
        if let annotations = mapView.annotations {
            mapView.removeAnnotations(annotations)
        }
        drawingView?.reset()
        drawingView?.removeFromSuperview()
        drawingView = nil
        mapView.isUserInteractionEnabled = true
    }
    
    func setupDirections() {
        let makeParisBordeauxWaypoints: (() -> [Waypoint]) = {
            let Paris = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 48.86, longitude: 2.34), name: "Paris")
            Paris.heading = 78.0001
            let Bordeaux = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 44.845177, longitude: -0.471071), name: "Bordeaux")
            return [Paris, Bordeaux]
        }
        let makeMultiStopsWaypoint: (() -> [Waypoint]) = {
            let Nation = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 48.848812, longitude: 2.395277), name: "Nation")
            let Bastille = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 48.853316, longitude: 2.369254), name: "Bastille")
            let Opera = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 48.870733, longitude: 2.332281), name: "Opéra")
            let Invalides = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 48.857437, longitude: 2.312888), name: "Invalides")
            return [Nation, Bastille, Opera, Invalides]
        }
        let makeRoundaboutWaypoints: (() -> [Waypoint]) = {
            let departure = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 49.013763, longitude: 1.195359))
            let arrival = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 49.015516, longitude: 1.184420))
            return [departure, arrival]
        }

        let makeMapboxOptions: (() -> RouteOptions) = {
            let wp1 = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 38.9131752, longitude: -77.0324047), name: "Mapbox")
            let wp2 = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 38.8977, longitude: -77.0365), name: "White House")
            let options = RouteOptions(waypoints: [wp1, wp2])
            options.includesSteps = true
            options.routeShapeResolution = .full
            options.attributeOptions = [.congestionLevel, .maximumSpeedLimit]
            return options
        }

        let makeMapboxErrorOptions: (() -> RouteOptions) = {
            let wpError1 = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 48.8579928719904, longitude: 170.35589048867871))
            let wpError2 = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 48.801659749004, longitude: 2.36325313652446))
            let errorOptions = RouteOptions(waypoints: [wpError1, wpError2])
            return errorOptions
        }

        let makeMappyOptions: (() -> MappyRouteOptions) = {
            let options = MappyRouteOptions(
                waypoints: makeParisBordeauxWaypoints(),
//                waypoints: makeRoundaboutWaypoints(),
                providers: ["car"],
                routeTypes: ["fastest"],
                qid: "demoapp-0e87-48f4-d190-a794fbbb6aac",
                additionalQueryParams: ["foo": "bar"])
            options.shapeFormat = .polyline6
            options.carVehicle = "comcar"
            options.motorbikeVehicule = "moto125"
            options.walkSpeed = .fast
            options.bikeSpeed = .slow
//            options.includesAlternativeRoutes = true
//            options.forceBetterRoute = true
            options.routeSignature = nil
            return options
        }

        let makeMultiProvidersOptions: (() -> MappyRouteOptions) = {
            let options = MappyRouteOptions(
                waypoints: makeMultiStopsWaypoint(),
                providers: ["walk", "bike", "bike"],
                routeTypes: ["", "shortest", "bicycle_friendly"],
                qid: "demoapp-0e87-48f4-d190-a794fbbb6aac")
            options.shapeFormat = .polyline6
            options.walkSpeed = .fast
            options.bikeSpeed = .normal
            return options
        }

        let makeRouteUpdateOptions: (() -> MappyRouteOptions) = {
            let options = MappyRouteOptions(
                waypoints: [
                    Waypoint(coordinate: CLLocationCoordinate2D(latitude: 48.8502559, longitude: 2.30837619), name: "Paris - Avenue de Ségur"),
                    Waypoint(coordinate: CLLocationCoordinate2D(latitude: 48.8448336, longitude: 2.3193625), name: "Paris - Rue de Vaugirard")
                ],
                providers: ["car"],
                routeTypes: ["fastest"],
                qid: "demoapp-0e87-48f4-d190-a794fbbb6aac",
                additionalQueryParams: ["dev_foo":"dev_bar"])
            options.shapeFormat = .polyline6
            options.carVehicle = "comcar"
            options.motorbikeVehicule = "moto125"
            options.walkSpeed = .slow
            options.bikeSpeed = .fast
            options.includesAlternativeRoutes = true
            options.routeSignature = "{\"legs\":[{\"start_offset\":0.9680011903,\"end_offset\":0.0060255587,\"path\":[12500001793085,12500001598647,12500001849735,12500001683156,12500001705281,12500001176665,12500019512298,12500019512297,12500001134529,12500001601838,12500001601837,12500001585450,12500001748458,12500001846544,12500001507086,12500015400135,12500015399290,12500001546884,12500015399002,12500015398980,12500015384328,12500015385901,12500015384739,12500001472033,12500001472034,12500001805334,12500001131745,12500015384156,12500015386598,12500001600626,12500001407018,12500015398972,12500015399733,12500001613011,12500001808104,12500001095874,12500001112472,12500000982166,12500001002638,12500001731391,12500001048324,12500019166160,12500019154732,12500001395539,12500001498399,12500001099033,12500001181500,12500015385877]}]}"
            return options
        }

        let mappyOptions = [
            makeMappyOptions(),
            makeMultiProvidersOptions(),
            makeRouteUpdateOptions()
        ][1]

        let useSnapEnv = true
        let host = URL(string: (useSnapEnv ? "https://routemm.mappysnap.net" : "https://routemm.mappyrecette.net"))!
        Directions(credentials: DirectionsCredentials(accessToken: nil, host: host)).calculate(mappyOptions) { (session, result) in
//        Directions.shared.calculate(options) { (session, result) in
            switch result {
            case let .failure(error):
                print("Error calculating directions: \(error)")
            case let .success(response):
                if let route = response.routes?.first {
                    for leg in route.legs {
                    print("\nRoute via \(leg):")
                    
                    let distanceFormatter = LengthFormatter()
                    distanceFormatter.numberFormatter.locale = Locale(identifier: "fr_FR")
                    let formattedDistance = distanceFormatter.string(fromMeters: route.distance)
                    
                    let travelTimeFormatter = DateComponentsFormatter()
                    travelTimeFormatter.unitsStyle = .short
                    let formattedExpectedTravelTime = travelTimeFormatter.string(from: route.expectedTravelTime)
                    var validTypicalTravelTime = "Not available"
                    if let typicalTravelTime = route.typicalTravelTime, let formattedTypicalTravelTime = travelTimeFormatter.string(from: typicalTravelTime) {
                        validTypicalTravelTime = formattedTypicalTravelTime
                    }
                    
                    print("Distance: \(formattedDistance); ETA: \(formattedExpectedTravelTime!); Typical travel time: \(validTypicalTravelTime)")
                    
                    for step in leg.steps {
                        let direction = step.maneuverDirection?.rawValue ?? "none"
                        print("\(step.instructions) [\(step.maneuverType) \(direction)]")
                        if step.distance > 0 {
                            let formattedDistance = distanceFormatter.string(fromMeters: step.distance)
                            print("— \(step.transportType) for \(formattedDistance) —")
                        }
                    }
                    }
                    
                    if var routeCoordinates = route.shape?.coordinates, routeCoordinates.count > 0 {
                        // Convert the route’s coordinates into a polyline.
                        let routeLine = MGLPolyline(coordinates: &routeCoordinates, count: UInt(routeCoordinates.count))

                        // Add the polyline to the map.
                        self.mapView.addAnnotation(routeLine)
                        
                        // Fit the viewport to the polyline.
                        let camera = self.mapView.cameraThatFitsShape(routeLine, direction: 0, edgePadding: .zero)
                        self.mapView.setCamera(camera, animated: true)
                    }
                }
            }
        }
    }
    
    func setupDrawingView() {
        drawingView = MBDrawingView(frame: view.bounds, strokeColor: .red, lineWidth: 1)
        drawingView!.autoresizingMask = mapView.autoresizingMask
        drawingView!.delegate = self
        view.insertSubview(drawingView!, belowSubview: segmentedControl)
        
        mapView.isUserInteractionEnabled = false
        
        let unpitchedCamera = mapView.camera
        unpitchedCamera.pitch = 0
        mapView.setCamera(unpitchedCamera, animated: true)
    }
    
    func drawingView(drawingView: MBDrawingView, didDrawWithPoints points: [CGPoint]) {
        guard points.count > 0 else { return }
        
        let ratio: Double = Double(points.count) / 100.0
        let keepEvery = Int(ratio.rounded(.up))
        
        let abridgedPoints = points.enumerated().compactMap { index, element -> CGPoint? in
            guard index % keepEvery == 0 else { return nil }
            return element
        }
        let coordinates = abridgedPoints.map {
            mapView.convert($0, toCoordinateFrom: mapView)
        }
        makeMatchRequest(locations: coordinates)
    }
    
    func makeMatchRequest(locations: [CLLocationCoordinate2D]) {
        let matchOptions = MatchOptions(coordinates: locations)

        Directions.shared.calculate(matchOptions) { (session, result) in
            
            switch result {
            case let .failure(error):
                let errorString = """
                ⚠️ Error Enountered. ⚠️
                Failure Reason: \(error.failureReason ?? "")
                Recovery Suggestion: \(error.recoverySuggestion ?? "")
                
                Technical Details: \(error)
                """
                print(errorString)
                return
            case let .success(response):
                guard let matches = response.matches, let match = matches.first else { return }
                if let annotations = self.mapView.annotations {
                    self.mapView.removeAnnotations(annotations)
                }
                
                var routeCoordinates = match.shape!.coordinates
                let coordCount = UInt(routeCoordinates.count)
                let routeLine = MGLPolyline(coordinates: &routeCoordinates, count: coordCount)
                self.mapView.addAnnotation(routeLine)
                self.drawingView?.reset()
            }

        }
    }
}
