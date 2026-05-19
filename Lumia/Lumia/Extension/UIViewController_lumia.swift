import Foundation
import UIKit

extension UIViewController {
    
    static func currentViewController_Lumia(view_Lumia: UIViewController? = nil) -> UIViewController? {
        var baseViewContrller_Lumia = view_Lumia
        if baseViewContrller_Lumia == nil {
            if #available(iOS 13.0, *) {
                let windowScene = UIApplication.shared.connectedScenes
                   .first { $0.activationState == .foregroundActive } as? UIWindowScene
                baseViewContrller_Lumia = windowScene?.windows.first?.rootViewController
            } else {
                baseViewContrller_Lumia = UIApplication.shared.keyWindow?.rootViewController
            }
        }
        if let UINav_Lumia = baseViewContrller_Lumia as? UINavigationController {
            return currentViewController_Lumia(view_Lumia: UINav_Lumia.visibleViewController)
        } else if let UITab_Lumia = baseViewContrller_Lumia as? UITabBarController {
            return currentViewController_Lumia(view_Lumia: UITab_Lumia.selectedViewController)
        } else if let preView_Lumia = baseViewContrller_Lumia?.presentedViewController {
            return currentViewController_Lumia(view_Lumia: preView_Lumia)
        }
        return baseViewContrller_Lumia
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
