import Foundation
import UIKit

extension String {
    
    func distance_Base_one(str_Base_one: String) -> Int {
        guard let range_Base_one = self.range(of: str_Base_one) else { return -1 }
        return distance(from: self.startIndex, to: range_Base_one.lowerBound)
    }
}
