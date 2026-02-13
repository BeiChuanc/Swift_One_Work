import Foundation
import UIKit

extension String {
    
    func distance_Glasspaint(str_Glasspaint: String) -> Int {
        guard let range_Glasspaint = self.range(of: str_Glasspaint) else { return -1 }
        return distance(from: self.startIndex, to: range_Glasspaint.lowerBound)
    }
}
