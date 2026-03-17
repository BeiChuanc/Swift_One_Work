import Foundation
import UIKit

extension String {
    
    func distance_Pane(str_Pane: String) -> Int {
        guard let range_Pane = self.range(of: str_Pane) else { return -1 }
        return distance(from: self.startIndex, to: range_Pane.lowerBound)
    }
}
