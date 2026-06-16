import Foundation
import UIKit

extension UIViewController {
    
    static func currentViewController_Retrs(view_Retrs: UIViewController? = nil) -> UIViewController? {
        var baseViewContrller_Retrs = view_Retrs
        if baseViewContrller_Retrs == nil {
            if #available(iOS 13.0, *) {
                let windowScene = UIApplication.shared.connectedScenes
                   .first { $0.activationState == .foregroundActive } as? UIWindowScene
                baseViewContrller_Retrs = windowScene?.windows.first?.rootViewController
            } else {
                baseViewContrller_Retrs = UIApplication.shared.keyWindow?.rootViewController
            }
        }
        if let UINav_Retrs = baseViewContrller_Retrs as? UINavigationController {
            return currentViewController_Retrs(view_Retrs: UINav_Retrs.visibleViewController)
        } else if let UITab_Retrs = baseViewContrller_Retrs as? UITabBarController {
            return currentViewController_Retrs(view_Retrs: UITab_Retrs.selectedViewController)
        } else if let preView_Retrs = baseViewContrller_Retrs?.presentedViewController {
            return currentViewController_Retrs(view_Retrs: preView_Retrs)
        }
        return baseViewContrller_Retrs
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
