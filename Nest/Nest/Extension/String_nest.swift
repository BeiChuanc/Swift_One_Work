import Foundation
import UIKit

extension String {
    
    func distance_Nest(str_Nest: String) -> Int {
        guard let range_Nest = self.range(of: str_Nest) else { return -1 }
        return distance(from: self.startIndex, to: range_Nest.lowerBound)
    }
}
