import Foundation
import UIKit

extension String {
    
    func distance_Tidy(str_Tidy: String) -> Int {
        guard let range_Tidy = self.range(of: str_Tidy) else { return -1 }
        return distance(from: self.startIndex, to: range_Tidy.lowerBound)
    }
}
