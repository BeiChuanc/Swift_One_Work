import Foundation
import UIKit

extension String {
    
    func distance_Epoch(str_Epoch: String) -> Int {
        guard let range_Epoch = self.range(of: str_Epoch) else { return -1 }
        return distance(from: self.startIndex, to: range_Epoch.lowerBound)
    }
}
