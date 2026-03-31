import Foundation
import UIKit

extension String {
    
    func distance_Flick(str_Flick: String) -> Int {
        guard let range_Flick = self.range(of: str_Flick) else { return -1 }
        return distance(from: self.startIndex, to: range_Flick.lowerBound)
    }
}
