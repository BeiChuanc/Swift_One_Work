import Foundation
import UIKit

extension String {
    
    func distance_Lens(str_Lens: String) -> Int {
        guard let range_Lens = self.range(of: str_Lens) else { return -1 }
        return distance(from: self.startIndex, to: range_Lens.lowerBound)
    }
}
