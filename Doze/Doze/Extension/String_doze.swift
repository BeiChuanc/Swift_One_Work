import Foundation
import UIKit

extension String {
    
    func distance_Doze(str_Doze: String) -> Int {
        guard let range_Doze = self.range(of: str_Doze) else { return -1 }
        return distance(from: self.startIndex, to: range_Doze.lowerBound)
    }
}
