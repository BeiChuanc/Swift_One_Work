import Foundation
import UIKit

extension UIViewController {
    
    static func currentViewController_Nest(view_Nest: UIViewController? = nil) -> UIViewController? {
        var baseViewContrller_Nest = view_Nest
        if baseViewContrller_Nest == nil {
            if #available(iOS 13.0, *) {
                let windowScene = UIApplication.shared.connectedScenes
                   .first { $0.activationState == .foregroundActive } as? UIWindowScene
                baseViewContrller_Nest = windowScene?.windows.first?.rootViewController
            } else {
                baseViewContrller_Nest = UIApplication.shared.keyWindow?.rootViewController
            }
        }
        if let UINav_Nest = baseViewContrller_Nest as? UINavigationController {
            return currentViewController_Nest(view_Nest: UINav_Nest.visibleViewController)
        } else if let UITab_Nest = baseViewContrller_Nest as? UITabBarController {
            return currentViewController_Nest(view_Nest: UITab_Nest.selectedViewController)
        } else if let preView_Nest = baseViewContrller_Nest?.presentedViewController {
            return currentViewController_Nest(view_Nest: preView_Nest)
        }
        return baseViewContrller_Nest
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
