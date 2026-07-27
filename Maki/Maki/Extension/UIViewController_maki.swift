import Foundation
import UIKit

extension UIViewController {
    
    static func currentViewController_Maki(view_Maki: UIViewController? = nil) -> UIViewController? {
        var baseViewContrller_Maki = view_Maki
        if baseViewContrller_Maki == nil {
            if #available(iOS 13.0, *) {
                let windowScene = UIApplication.shared.connectedScenes
                   .first { $0.activationState == .foregroundActive } as? UIWindowScene
                baseViewContrller_Maki = windowScene?.windows.first?.rootViewController
            } else {
                baseViewContrller_Maki = UIApplication.shared.keyWindow?.rootViewController
            }
        }
        if let UINav_Maki = baseViewContrller_Maki as? UINavigationController {
            return currentViewController_Maki(view_Maki: UINav_Maki.visibleViewController)
        } else if let UITab_Maki = baseViewContrller_Maki as? UITabBarController {
            return currentViewController_Maki(view_Maki: UITab_Maki.selectedViewController)
        } else if let preView_Maki = baseViewContrller_Maki?.presentedViewController {
            return currentViewController_Maki(view_Maki: preView_Maki)
        }
        return baseViewContrller_Maki
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
