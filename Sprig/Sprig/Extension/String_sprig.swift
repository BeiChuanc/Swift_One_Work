import Foundation
import UIKit

extension String {
    
    func distance_Sprig(str_Sprig: String) -> Int {
        guard let range_Sprig = self.range(of: str_Sprig) else { return -1 }
        return distance(from: self.startIndex, to: range_Sprig.lowerBound)
    }
}
