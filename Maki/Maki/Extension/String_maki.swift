import Foundation
import UIKit

extension String {
    
    func distance_Maki(str_Maki: String) -> Int {
        guard let range_Maki = self.range(of: str_Maki) else { return -1 }
        return distance(from: self.startIndex, to: range_Maki.lowerBound)
    }
}
