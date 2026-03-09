import Foundation
import UIKit

extension String {
    
    func distance_Moode(str_Moode: String) -> Int {
        guard let range_Moode = self.range(of: str_Moode) else { return -1 }
        return distance(from: self.startIndex, to: range_Moode.lowerBound)
    }
}
