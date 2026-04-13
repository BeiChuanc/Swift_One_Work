import Foundation
import UIKit

extension String {
    
    func distance_Clara(str_Clara: String) -> Int {
        guard let range_Clara = self.range(of: str_Clara) else { return -1 }
        return distance(from: self.startIndex, to: range_Clara.lowerBound)
    }
}
