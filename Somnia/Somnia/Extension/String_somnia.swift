import Foundation
import UIKit

extension String {
    
    func distance_Somnia(str_Somnia: String) -> Int {
        guard let range_Somnia = self.range(of: str_Somnia) else { return -1 }
        return distance(from: self.startIndex, to: range_Somnia.lowerBound)
    }
}
