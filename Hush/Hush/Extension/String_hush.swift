import Foundation
import UIKit

extension String {
    
    func distance_Hush(str_Hush: String) -> Int {
        guard let range_Hush = self.range(of: str_Hush) else { return -1 }
        return distance(from: self.startIndex, to: range_Hush.lowerBound)
    }
}
