import Foundation
import UIKit

extension String {
    
    func distance_Trace(str_Trace: String) -> Int {
        guard let range_Trace = self.range(of: str_Trace) else { return -1 }
        return distance(from: self.startIndex, to: range_Trace.lowerBound)
    }
}
