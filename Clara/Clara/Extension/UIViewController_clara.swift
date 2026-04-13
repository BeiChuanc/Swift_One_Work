import Foundation
import UIKit

extension UIViewController {
    
    static func currentViewController_Clara(view_Clara: UIViewController? = nil) -> UIViewController? {
        var baseViewContrller_Clara = view_Clara
        if baseViewContrller_Clara == nil {
            if #available(iOS 13.0, *) {
                let windowScene = UIApplication.shared.connectedScenes
                   .first { $0.activationState == .foregroundActive } as? UIWindowScene
                baseViewContrller_Clara = windowScene?.windows.first?.rootViewController
            } else {
                baseViewContrller_Clara = UIApplication.shared.keyWindow?.rootViewController
            }
        }
        if let UINav_Clara = baseViewContrller_Clara as? UINavigationController {
            return currentViewController_Clara(view_Clara: UINav_Clara.visibleViewController)
        } else if let UITab_Clara = baseViewContrller_Clara as? UITabBarController {
            return currentViewController_Clara(view_Clara: UITab_Clara.selectedViewController)
        } else if let preView_Clara = baseViewContrller_Clara?.presentedViewController {
            return currentViewController_Clara(view_Clara: preView_Clara)
        }
        return baseViewContrller_Clara
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
