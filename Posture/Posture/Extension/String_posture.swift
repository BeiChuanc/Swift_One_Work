import Foundation
import UIKit

extension String {
    
    func distance_Posture(str_Posture: String) -> Int {
        guard let range_Posture = self.range(of: str_Posture) else { return -1 }
        return distance(from: self.startIndex, to: range_Posture.lowerBound)
    }
}
