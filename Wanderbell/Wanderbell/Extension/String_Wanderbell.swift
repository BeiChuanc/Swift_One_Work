import Foundation
import UIKit

extension String {
    
    func distance_Wanderbell(str_Wanderbell: String) -> Int {
        guard let range_Wanderbell = self.range(of: str_Wanderbell) else { return -1 }
        return distance(from: self.startIndex, to: range_Wanderbell.lowerBound)
    }
}
