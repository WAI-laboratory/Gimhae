import UIKit
import Combine

class BaseViewController: UIViewController {
    var subscription = Set<AnyCancellable>()
    
}
