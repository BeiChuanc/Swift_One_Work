import Foundation
import UIKit

extension String {
    
    func distance_Sylva(str_Sylva: String) -> Int {
        guard let range_Sylva = self.range(of: str_Sylva) else { return -1 }
        return distance(from: self.startIndex, to: range_Sylva.lowerBound)
    }
}
