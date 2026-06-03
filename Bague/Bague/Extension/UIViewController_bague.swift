import Foundation
import UIKit

extension UIViewController {
    
    static func currentViewController_Bague(view_Bague: UIViewController? = nil) -> UIViewController? {
        var baseViewContrller_Bague = view_Bague
        if baseViewContrller_Bague == nil {
            if #available(iOS 13.0, *) {
                let windowScene = UIApplication.shared.connectedScenes
                   .first { $0.activationState == .foregroundActive } as? UIWindowScene
                baseViewContrller_Bague = windowScene?.windows.first?.rootViewController
            } else {
                baseViewContrller_Bague = UIApplication.shared.keyWindow?.rootViewController
            }
        }
        if let UINav_Bague = baseViewContrller_Bague as? UINavigationController {
            return currentViewController_Bague(view_Bague: UINav_Bague.visibleViewController)
        } else if let UITab_Bague = baseViewContrller_Bague as? UITabBarController {
            return currentViewController_Bague(view_Bague: UITab_Bague.selectedViewController)
        } else if let preView_Bague = baseViewContrller_Bague?.presentedViewController {
            return currentViewController_Bague(view_Bague: preView_Bague)
        }
        return baseViewContrller_Bague
    }
}

// 拓展Xcode中可视化的属性设置
extension UIView {

    @IBInspectable
    var radius: CGFloat{
        get{
            return layer.cornerRadius
        }
        set{

            clipsToBounds = true
            self.layer.cornerRadius = newValue
        }

    }
}
