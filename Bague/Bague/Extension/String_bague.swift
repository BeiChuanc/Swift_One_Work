import Foundation
import UIKit

extension String {
    
    func distance_Bague(str_Bague: String) -> Int {
        guard let range_Bague = self.range(of: str_Bague) else { return -1 }
        return distance(from: self.startIndex, to: range_Bague.lowerBound)
    }
}
