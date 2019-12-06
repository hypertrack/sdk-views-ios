import MapKit
import Combine
import HyperTrackViews

class DeviceAnnotation: NSObject, MKAnnotation {
  dynamic var coordinate: CLLocationCoordinate2D
  @Published var bearing: CGFloat
  
  init(coordinate: CLLocationCoordinate2D, bearing: CGFloat) {
    self.coordinate = coordinate
    self.bearing = bearing
    
    super.init()
  }
}

class DeviceAnnotationView: MKAnnotationView {
  
  var bearing: CGFloat = -1.0
  var cancelBearingSubscription: AnyCancellable?
  
  init(annotation: DeviceAnnotation, reuseIdentifier: String) {
    self.bearing = annotation.bearing
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  func setup() {
    self.frame = CGRect.init(x: 0, y: 0, width: 34, height: 34)
    self.backgroundColor = UIColor.clear
    
    if let annotation = self.annotation as? DeviceAnnotation {
      self.cancelBearingSubscription = annotation.$bearing.sink { bearing in
        self.bearing = bearing
        self.setNeedsDisplay()
      }
    }
  }
  
  override func draw(_ rect: CGRect) {
    //// General Declarations
    let context = UIGraphicsGetCurrentContext()!
    
    //// Color Declarations
    let green = UIColor(red: 0.314, green: 0.890, blue: 0.761, alpha: 1.000)
    let fillColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
    
    //// Variable Declarations
    let rotation: CGFloat = -bearing
    let noCourse = bearing != -1 ? true : false
    
    //// InnerDot
    //// Dot Drawing
    let dotPath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 34, height: 34))
    green.setFill()
    dotPath.fill()
    
    
    if (noCourse) {
      //// Arrow Drawing
      context.saveGState()
      context.translateBy(x: 17, y: 17)
      context.rotate(by: -rotation * CGFloat.pi/180)
      
      let arrowPath = UIBezierPath()
      arrowPath.move(to: CGPoint(x: 0, y: -8))
      arrowPath.addLine(to: CGPoint(x: -7, y: 5))
      arrowPath.addCurve(to: CGPoint(x: 0, y: 3), controlPoint1: CGPoint(x: -7, y: 5), controlPoint2: CGPoint(x: -4, y: 3))
      arrowPath.addCurve(to: CGPoint(x: 7, y: 5), controlPoint1: CGPoint(x: 4, y: 3), controlPoint2: CGPoint(x: 7, y: 5))
      arrowPath.addLine(to: CGPoint(x: 0, y: -8))
      arrowPath.close()
      arrowPath.usesEvenOddFillRule = true
      fillColor.setFill()
      arrowPath.fill()
      
      context.restoreGState()
    }
  }
}

class DestinationAnnotation: NSObject, MKAnnotation {
  let coordinate: CLLocationCoordinate2D
  
  init(coordinate: CLLocationCoordinate2D) {
    self.coordinate = coordinate
    
    super.init()
  }
}

class DestinationAnnotationView: MKAnnotationView {
  
  init(annotation: MKAnnotation, reuseIdentifier: String) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  func setup() {
    self.frame = CGRect.init(x: 0, y: 0, width: 26, height: 28)
    self.backgroundColor = UIColor.clear
  }
  
  override func draw(_ rect: CGRect) {
    //// General Declarations
    let context = UIGraphicsGetCurrentContext()!
    
    //// Color Declarations
    let shadowColor = UIColor(red: 0.290, green: 0.290, blue: 0.290, alpha: 0.500)
    
    //// Shadow Declarations
    let shadow = NSShadow()
    shadow.shadowColor = shadowColor
    shadow.shadowOffset = CGSize(width: 0, height: 1)
    shadow.shadowBlurRadius = 4
    
    //// Rectangle Drawing
    let rectanglePath = UIBezierPath(roundedRect: CGRect(x: 4, y: 5, width: 18, height: 18), cornerRadius: 5)
    context.saveGState()
    context.setShadow(offset: shadow.shadowOffset, blur: shadow.shadowBlurRadius, color: (shadow.shadowColor as! UIColor).cgColor)
    UIColor.black.setFill()
    rectanglePath.fill()
    context.restoreGState()
    
    
    
    //// Oval Drawing
    let ovalPath = UIBezierPath(ovalIn: CGRect(x: 9.5, y: 10.5, width: 7, height: 7))
    UIColor.white.setFill()
    ovalPath.fill()
  }
}

func rendererForOverlay(_ overlay: MKOverlay) -> MKOverlayRenderer? {
  if overlay is MKCircle {
    let circleRenderer = MKCircleRenderer(circle: overlay as! MKCircle)
    circleRenderer.fillColor = UIColor(red: 80.0/255.0, green: 227.0/255.0, blue: 194.0/255.0, alpha: 0.3)
    circleRenderer.strokeColor = UIColor(red: 80.0/255.0, green: 227.0/255.0, blue: 194.0/255.0, alpha: 0.1)
    circleRenderer.lineWidth = 1.5
    return circleRenderer
  } else if overlay is MKPolyline {
    let polylineRenderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
    polylineRenderer.strokeColor = UIColor.black
    polylineRenderer.lineWidth = 4.0
    polylineRenderer.lineJoin = .miter
    return polylineRenderer
  } else {
    return nil
  }
}

func annotationViewForAnnotation(_ annotation: MKAnnotation, onMapView mapView: MKMapView) -> MKAnnotationView? {
  if let deviceAnnotation = annotation as? DeviceAnnotation {
    let reuseIdentifier = "DeviceAnnotation"
    if let deviceAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) {
      return deviceAnnotationView
    } else {
      return DeviceAnnotationView(annotation: deviceAnnotation, reuseIdentifier: reuseIdentifier)
    }
  } else if let destinationAnnotation = annotation as? DestinationAnnotation {
    let reuseIdentifier = "DestinationAnnotation"
    if let destinationAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) {
      return destinationAnnotationView
    } else {
      return DestinationAnnotationView(annotation: destinationAnnotation, reuseIdentifier: reuseIdentifier)
    }
  } else {
    return nil
  }
}

enum HyperTrackView {
  case location(CLLocation)
  case locationWithTrip(CLLocation, MovementStatus.Trip)
}

func putDevice(withCoordinate coordinate: CLLocationCoordinate2D, bearing: CGFloat, accuracy: CLLocationAccuracy, onMapView mapView: MKMapView) {
  
  if let deviceAnnotation = device(fromMapView: mapView) {
    deviceAnnotation.coordinate = coordinate
    deviceAnnotation.bearing = bearing
  } else {
    mapView.addAnnotation(DeviceAnnotation(coordinate: coordinate, bearing: bearing))
  }
  
  if accuracy > 0 {
    let accuracyCircleOverlay = MKCircle(center: coordinate, radius: accuracy)
    if let polylineOverlay = polyline(fromMapView: mapView) {
      remove(overlay: MKCircle.self, fromMapView: mapView)
      mapView.insertOverlay(accuracyCircleOverlay, above: polylineOverlay)
    } else {
      remove(overlay: MKCircle.self, fromMapView: mapView)
      mapView.addOverlay(accuracyCircleOverlay)
    }
  }
  
}

extension Array where Element: AnyObject {
  func first<T: AnyObject>(ofType _: T.Type) -> T? {
    return self.lazy.compactMap { $0 as? T }.first
  }
}

enum HyperTrackViewComponent {
  case device
  case deviceWithTrip
  case everything
}

func remove(component: HyperTrackViewComponent, fromMapView mapView: MKMapView) {
  switch component {
  case .device:
    removeDeviceFrom(mapView: mapView)
  case .deviceWithTrip:
    removeDeviceFrom(mapView: mapView)
    removeTripFrom(mapView: mapView)
  case .everything:
    removeEverythingFrom(mapView: mapView)
  }
}

func removeDeviceFrom(mapView: MKMapView) {
  remove(annotation: DeviceAnnotation.self, fromMapView: mapView)
  remove(overlay: MKCircle.self, fromMapView: mapView)
}

func removeTripFrom(mapView: MKMapView) {
  remove(annotation: DestinationAnnotation.self, fromMapView: mapView)
  remove(overlay: MKPolyline.self, fromMapView: mapView)
}

func removeEverythingFrom(mapView: MKMapView) {
  removeDeviceFrom(mapView: mapView)
  removeTripFrom(mapView: mapView)
}

func putTrip(
  withDeviceCoordinate coordinate: CLLocationCoordinate2D,
  destinationCoordinate: CLLocationCoordinate2D,
  polyline: [CLLocationCoordinate2D]?,
  onMapView mapView: MKMapView) {
  
  if mapView.annotations.first(ofType: DestinationAnnotation.self) == nil {
    mapView.addAnnotation(DestinationAnnotation(coordinate: destinationCoordinate))
  }
  
  remove(overlay: MKPolyline.self, fromMapView: mapView)
  if let polyline = polyline {
    let connectedCurrentLocation = connect(currentCoordinate: coordinate, toEstimatePolyline: polyline)
    let combinedPolyline = connectedCurrentLocation + [destinationCoordinate]
    mapView.addOverlay(MKPolyline(coordinates: combinedPolyline, count: combinedPolyline.count))
  }
  
}

func connect(
  currentCoordinate coordinate:CLLocationCoordinate2D,
  toEstimatePolyline polyline: [CLLocationCoordinate2D]
) -> [CLLocationCoordinate2D] {
  if polyline.count <= 1 {
    return [coordinate]
  } else {
    let minimumPosition = polyline.enumerated().map { ($0, MKMapPoint(coordinate).distance(to: MKMapPoint($1))) }.min { $0.1 < $1.1 }
    if let minimumPosition = minimumPosition {
      var mutPolyline = polyline
      let position = minimumPosition.0
      mutPolyline[position] = coordinate
      let newPolyline = mutPolyline.suffix(from: position)
      return Array(newPolyline)
    } else {
      // What does it even mean?
      return [coordinate] + polyline
    }
  }
}

func remove<Overlay: MKOverlay>(overlay: Overlay.Type, fromMapView mapView: MKMapView) {
  if let overlay = mapView.overlays.first(ofType: Overlay.self) {
    mapView.removeOverlay(overlay)
  }
}

func remove<Annotation: MKAnnotation>(annotation: Annotation.Type, fromMapView mapView: MKMapView) {
  if let annotation = mapView.annotations.first(ofType: Annotation.self) {
    mapView.removeAnnotation(annotation)
  }
}

enum Edges {
  typealias Amount = UInt16
  
  case all(Amount)
  case bottom(Amount)
  case custom(top: Amount, leading: Amount, bottom: Amount, trailing: Amount)
  case horizontal(Amount)
  case leading(Amount)
  case top(Amount)
  case trailing(Amount)
  case vertical(Amount)
  
  func unpack() -> (top: Amount, leading: Amount, bottom: Amount, trailing: Amount) {
    switch self {
    case let .all(amount):
      return (amount, amount, amount, amount)
    case let .bottom(amount):
      return (0, 0, amount, 0)
    case let .custom(top, leading, bottom, trailing):
      return (top, leading, bottom, trailing)
    case let .horizontal(amount):
      return (0, amount, 0, amount)
    case let .leading(amount):
      return (0, amount, 0, 0)
    case let .top(amount):
      return (amount, 0, 0, 0)
    case let .trailing(amount):
      return (0, 0, 0, amount)
    case let .vertical(amount):
      return (amount, 0, amount, 0)
    }
  }
}


func mapRectFromCoordinates(_ coordinates: [CLLocationCoordinate2D]) -> MKMapRect {
  let rects = coordinates.lazy.map { MKMapRect(origin: MKMapPoint($0), size: MKMapSize()) }
  return rects.reduce(MKMapRect.null) { $0.union($1) }
}

func zoom(withMapInsets mapInsets: Edges?, interfaceInsets: Edges?, onMapView mapView: MKMapView, animated: Bool = true) {
  if let polyline = polyline(fromMapView: mapView) {
    let deviceAnnotation = device(fromMapView: mapView)
    let polylineCoordinates = coordinatesFromMultiPoint(polyline)
    let coordinates = deviceAnnotation != nil ? polylineCoordinates + [deviceAnnotation!.coordinate] : polylineCoordinates
    var mapRect = mapRectFromCoordinates(coordinates)
    if let mapInsets = mapInsets {
      mapRect = outset(mapRect: mapRect, withEdges: mapInsets)
    }
    if let interfaceInsets = interfaceInsets {
      let (top, leading, bottom, trailing) = interfaceInsets.unpack()
      mapView.setVisibleMapRect(mapRect, edgePadding: UIEdgeInsets(top: CGFloat(top), left: CGFloat(leading), bottom: CGFloat(bottom), right: CGFloat(trailing)), animated: animated)
    } else {
      mapView.setVisibleMapRect(mapRect, animated: animated)
    }
  } else if let device = device(fromMapView: mapView) {
    var mapRect = MKMapRect(origin: MKMapPoint(device.coordinate), size: MKMapSize())
    let edges = mapInsets ?? .all(400)
    mapRect = outset(mapRect: mapRect, withEdges: edges)
    if let interfaceInsets = interfaceInsets {
      let (top, leading, bottom, trailing) = interfaceInsets.unpack()
      mapView.setVisibleMapRect(mapRect, edgePadding: UIEdgeInsets(top: CGFloat(top), left: CGFloat(leading), bottom: CGFloat(bottom), right: CGFloat(trailing)), animated: animated)
    } else {
      mapView.setVisibleMapRect(mapRect, animated: animated)
    }
  }
}

func outset(mapRect: MKMapRect, withEdges edges: Edges) -> MKMapRect {
  let (top, leading, bottom, trailing) = edges.unpack()
  let pointsPerMeter = MKMapPointsPerMeterAtLatitude(mapRect.origin.coordinate.latitude)
  let topPoints = Double(top) * pointsPerMeter
  let leadingPoints = Double(leading) * pointsPerMeter
  let bottomPoints = Double(bottom) * pointsPerMeter
  let trailingPoints = Double(trailing) * pointsPerMeter
  return MKMapRect(
    x: mapRect.minX - leadingPoints,
    y: mapRect.minY - topPoints,
    width: mapRect.width + leadingPoints + trailingPoints,
    height: mapRect.height + topPoints + bottomPoints
  )
}

func device(fromMapView mapView: MKMapView) -> DeviceAnnotation? {
  return mapView.annotations.first(ofType: DeviceAnnotation.self)
}

func polyline(fromMapView mapView: MKMapView) -> MKPolyline? {
  return mapView.overlays.first(ofType: MKPolyline.self)
}

func coordinatesFromMultiPoint(_ multiPoint: MKMultiPoint) -> [CLLocationCoordinate2D] {
  var coordinates = [CLLocationCoordinate2D](
    repeating: kCLLocationCoordinate2DInvalid,
    count: multiPoint.pointCount
  )
  multiPoint.getCoordinates(&coordinates, range: NSRange(location: 0, length: multiPoint.pointCount))
  
  return coordinates
}

typealias CoordinateRange = (minLat: CLLocationDegrees, maxLat: CLLocationDegrees, minLon: CLLocationDegrees, maxLon: CLLocationDegrees)

func put(_ hyperTrackView: HyperTrackView, onMapView mapView: MKMapView) {
  switch hyperTrackView {
  case let .location(location):
    
    removeTripFrom(mapView: mapView)
    putDevice(
      withCoordinate: location.coordinate,
      bearing: CGFloat(location.course),
      accuracy: location.horizontalAccuracy,
      onMapView: mapView)
    
  case let .locationWithTrip(location, trip):
    
    let coordinate = location.coordinate
    
    putDevice(
      withCoordinate: coordinate,
      bearing: CGFloat(location.course),
      accuracy: location.horizontalAccuracy,
      onMapView: mapView)
    
    if let destinationCoordinate = trip.destination?.coordinate {
      putTrip(
        withDeviceCoordinate: coordinate,
        destinationCoordinate: destinationCoordinate,
        polyline: trip.destination?.estimate?.route.polyline,
        onMapView: mapView)
    }
  }
}
