import UIKit
import MapKit
import HyperTrackViews

class DeviceAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        
        super.init()
    }
}

let publishableKey = "<#Paste your Publishable Key here#>"
let deviceID = "<#Paste your Device ID here#>"

class ViewController: UIViewController {

    let hyperTrackViews = HyperTrackViews(publishableKey: publishableKey)
    var deviceAnnotation: DeviceAnnotation?
    var cancelSubscription: Cancel = {}
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cancelSubscription = hyperTrackViews.subscribeToMovementStatusUpdates(for: deviceID) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(movementStatus):
                dump(movementStatus)
                
                let coordinate = movementStatus.location.coordinate
               
                if let deviceAnnotation = self.deviceAnnotation {
                    deviceAnnotation.coordinate = coordinate
                } else {
                    let device = DeviceAnnotation(coordinate: coordinate)
                    self.deviceAnnotation = device
                    self.mapView.addAnnotation(device)
                }
                
                let regionRadius: CLLocationDistance = 1000
                let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
                self.mapView.setRegion(coordinateRegion, animated: true)
            case .failure(let error):
                dump(error)
            }
        }
    }
}
