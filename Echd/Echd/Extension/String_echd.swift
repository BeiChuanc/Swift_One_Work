import Foundation
import UIKit

extension String {
    
    func distance_Echd(str_Echd: String) -> Int {
        guard let range_Echd = self.range(of: str_Echd) else { return -1 }
        return distance(from: self.startIndex, to: range_Echd.lowerBound)
    }
}
