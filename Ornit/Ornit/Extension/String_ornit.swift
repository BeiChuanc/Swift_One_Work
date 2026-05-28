import Foundation
import UIKit

extension String {
    
    func distance_Ornit(str_Ornit: String) -> Int {
        guard let range_Ornit = self.range(of: str_Ornit) else { return -1 }
        return distance(from: self.startIndex, to: range_Ornit.lowerBound)
    }
}
