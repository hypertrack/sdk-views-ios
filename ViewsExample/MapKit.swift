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
  case movementStatus(MovementStatus)
  case movementStatusWithTrip(MovementStatus, MovementStatus.Trip)
}

func putDevice(withCoordinate coordinate: CLLocationCoordinate2D, bearing: CGFloat, accuracy: CLLocationAccuracy, onMapView mapView: MKMapView) {
  
  if let deviceAnnotation = mapView.annotations.first(ofType: DeviceAnnotation.self) {
    deviceAnnotation.coordinate = coordinate
    deviceAnnotation.bearing = bearing
  } else {
    mapView.addAnnotation(DeviceAnnotation(coordinate: coordinate, bearing: bearing))
  }
  
  remove(overlay: MKCircle.self, fromMapView: mapView)
  if accuracy > 0 {
    let accuracyCircleOverlay = MKCircle(center: coordinate, radius: accuracy)
    if let polylineOverlay = mapView.overlays.first(ofType: MKPolyline.self) {
      mapView.insertOverlay(accuracyCircleOverlay, above: polylineOverlay)
    } else {
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
    let combinedPolyline = [coordinate] + polyline + [destinationCoordinate]
    mapView.addOverlay(MKPolyline(coordinates: combinedPolyline, count: combinedPolyline.count))
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

enum ZoomTarget {
  case device
  case trip
  case coordinate(CLLocationCoordinate2D)
}

func zoom(on target: ZoomTarget, paddingRadius: UInt16?, onMapView mapView:MKMapView, animated: Bool = true) {
  switch target {
  case .device:
    if let deviceAnnotation = mapView.annotations.first(ofType: DeviceAnnotation.self) {
      
      let regionRadius = CLLocationDistance(paddingRadius ?? 400)
      let coordinateRegion = MKCoordinateRegion(center: deviceAnnotation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
      
      mapView.setRegion(coordinateRegion, animated: animated)
    }
  case .trip:
    if let deviceAnnotation = mapView.annotations.first(ofType: DeviceAnnotation.self) {
      if let polylineOverlay = mapView.overlays.first(ofType: MKPolyline.self) {
        break
      } else {
        let regionRadius = CLLocationDistance(paddingRadius ?? 400)
        let coordinateRegion = MKCoordinateRegion(center: deviceAnnotation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        
        mapView.setRegion(coordinateRegion, animated: animated)
      }
    }
  case .coordinate(_):
    break
  }
}

func put(_ hyperTrackView: HyperTrackView, onMapView mapView: MKMapView) {
  switch hyperTrackView {
  case let .movementStatus(movementStatus):
    
    removeTripFrom(mapView: mapView)
    
    putDevice(
      withCoordinate: movementStatus.location.coordinate,
      bearing: CGFloat(movementStatus.location.course),
      accuracy: movementStatus.location.horizontalAccuracy,
      onMapView: mapView)
    
  case let .movementStatusWithTrip(movementStatus, trip):
    
    let coordinate = movementStatus.location.coordinate
    
    putDevice(
      withCoordinate: coordinate,
      bearing: CGFloat(movementStatus.location.course),
      accuracy: movementStatus.location.horizontalAccuracy,
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
