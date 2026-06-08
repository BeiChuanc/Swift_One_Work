import Foundation
import UIKit

extension String {
    
    func distance_Vestir(str_Vestir: String) -> Int {
        guard let range_Vestir = self.range(of: str_Vestir) else { return -1 }
        return distance(from: self.startIndex, to: range_Vestir.lowerBound)
    }
}
