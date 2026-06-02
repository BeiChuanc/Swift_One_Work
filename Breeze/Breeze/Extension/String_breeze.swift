import Foundation
import UIKit

extension String {
    
    func distance_Breeze(str_Breeze: String) -> Int {
        guard let range_Breeze = self.range(of: str_Breeze) else { return -1 }
        return distance(from: self.startIndex, to: range_Breeze.lowerBound)
    }
}
