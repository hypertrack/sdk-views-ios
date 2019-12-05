import UIKit
import MapKit
import HyperTrackViews
import Combine

let publishableKey = "<#Paste your Publishable Key here#>"
let deviceID = "<#Paste your Device ID here#>"

class ViewController: UIViewController, MKMapViewDelegate {
  
  let hyperTrackViews = HyperTrackViews(publishableKey: publishableKey)
  var cancelSubscription: Cancel = {}
  
  @IBOutlet var mapView: MKMapView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    mapView.delegate = self
    
    cancelSubscription = hyperTrackViews.subscribeToMovementStatusUpdates(for: deviceID) { [weak self] result in
      guard let self = self else { return }
      
      switch result {
      case let .success(movementStatus):
        
        if let trip = movementStatus.trips.first {
          put(.locationWithTrip(movementStatus.location, trip), onMapView: self.mapView)
        } else {
          put(.location(movementStatus.location), onMapView: self.mapView)
        }
        
        zoom(withMapInsets: .all(100), interfaceInsets: nil, onMapView: self.mapView)
        
      case .failure(let error):
        dump(error)
      }
    }
  }
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    return annotationViewForAnnotation(annotation, onMapView: mapView)
  }
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    return rendererForOverlay(overlay)!
  }
}
