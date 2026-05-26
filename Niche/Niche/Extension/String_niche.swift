import Foundation
import UIKit

extension String {
    
    func distance_Niche(str_Niche: String) -> Int {
        guard let range_Niche = self.range(of: str_Niche) else { return -1 }
        return distance(from: self.startIndex, to: range_Niche.lowerBound)
    }
}
