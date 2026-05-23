import Foundation
import UIKit

extension UIViewController {
    
    static func currentViewController_Hush(view_Hush: UIViewController? = nil) -> UIViewController? {
        var baseViewContrller_Hush = view_Hush
        if baseViewContrller_Hush == nil {
            if #available(iOS 13.0, *) {
                let windowScene = UIApplication.shared.connectedScenes
                   .first { $0.activationState == .foregroundActive } as? UIWindowScene
                baseViewContrller_Hush = windowScene?.windows.first?.rootViewController
            } else {
                baseViewContrller_Hush = UIApplication.shared.keyWindow?.rootViewController
            }
        }
        if let UINav_Hush = baseViewContrller_Hush as? UINavigationController {
            return currentViewController_Hush(view_Hush: UINav_Hush.visibleViewController)
        } else if let UITab_Hush = baseViewContrller_Hush as? UITabBarController {
            return currentViewController_Hush(view_Hush: UITab_Hush.selectedViewController)
        } else if let preView_Hush = baseViewContrller_Hush?.presentedViewController {
            return currentViewController_Hush(view_Hush: preView_Hush)
        }
        return baseViewContrller_Hush
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
