import Foundation
import UIKit

extension UIViewController {
    
    static func currentViewController_Tidy(view_Tidy: UIViewController? = nil) -> UIViewController? {
        var baseViewContrller_Tidy = view_Tidy
        if baseViewContrller_Tidy == nil {
            if #available(iOS 13.0, *) {
                let windowScene = UIApplication.shared.connectedScenes
                   .first { $0.activationState == .foregroundActive } as? UIWindowScene
                baseViewContrller_Tidy = windowScene?.windows.first?.rootViewController
            } else {
                baseViewContrller_Tidy = UIApplication.shared.keyWindow?.rootViewController
            }
        }
        if let UINav_Tidy = baseViewContrller_Tidy as? UINavigationController {
            return currentViewController_Tidy(view_Tidy: UINav_Tidy.visibleViewController)
        } else if let UITab_Tidy = baseViewContrller_Tidy as? UITabBarController {
            return currentViewController_Tidy(view_Tidy: UITab_Tidy.selectedViewController)
        } else if let preView_Tidy = baseViewContrller_Tidy?.presentedViewController {
            return currentViewController_Tidy(view_Tidy: preView_Tidy)
        }
        return baseViewContrller_Tidy
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
