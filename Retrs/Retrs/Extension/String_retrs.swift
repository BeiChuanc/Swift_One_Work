import Foundation
import UIKit

extension String {
    
    func distance_Retrs(str_Retrs: String) -> Int {
        guard let range_Retrs = self.range(of: str_Retrs) else { return -1 }
        return distance(from: self.startIndex, to: range_Retrs.lowerBound)
    }
}
