import Foundation
import UIKit

extension String {
    
    func distance_Lumia(str_Lumia: String) -> Int {
        guard let range_Lumia = self.range(of: str_Lumia) else { return -1 }
        return distance(from: self.startIndex, to: range_Lumia.lowerBound)
    }
}
