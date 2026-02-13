import Foundation
import UIKit

extension UIViewController {
    
    static func currentViewController_Glasspaint(view_Glasspaint: UIViewController? = nil) -> UIViewController? {
        var baseViewContrller_Glasspaint = view_Glasspaint
        if baseViewContrller_Glasspaint == nil {
            if #available(iOS 13.0, *) {
                let windowScene = UIApplication.shared.connectedScenes
                   .first { $0.activationState == .foregroundActive } as? UIWindowScene
                baseViewContrller_Glasspaint = windowScene?.windows.first?.rootViewController
            } else {
                baseViewContrller_Glasspaint = UIApplication.shared.keyWindow?.rootViewController
            }
        }
        if let UINav_Glasspaint = baseViewContrller_Glasspaint as? UINavigationController {
            return currentViewController_Glasspaint(view_Glasspaint: UINav_Glasspaint.visibleViewController)
        } else if let UITab_Glasspaint = baseViewContrller_Glasspaint as? UITabBarController {
            return currentViewController_Glasspaint(view_Glasspaint: UITab_Glasspaint.selectedViewController)
        } else if let preView_Glasspaint = baseViewContrller_Glasspaint?.presentedViewController {
            return currentViewController_Glasspaint(view_Glasspaint: preView_Glasspaint)
        }
        return baseViewContrller_Glasspaint
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
