import Foundation
import UIKit

extension UIViewController {
    
    static func currentViewController_Trace(view_Trace: UIViewController? = nil) -> UIViewController? {
        var baseViewContrller_Trace = view_Trace
        if baseViewContrller_Trace == nil {
            if #available(iOS 13.0, *) {
                let windowScene = UIApplication.shared.connectedScenes
                   .first { $0.activationState == .foregroundActive } as? UIWindowScene
                baseViewContrller_Trace = windowScene?.windows.first?.rootViewController
            } else {
                baseViewContrller_Trace = UIApplication.shared.keyWindow?.rootViewController
            }
        }
        if let UINav_Trace = baseViewContrller_Trace as? UINavigationController {
            return currentViewController_Trace(view_Trace: UINav_Trace.visibleViewController)
        } else if let UITab_Trace = baseViewContrller_Trace as? UITabBarController {
            return currentViewController_Trace(view_Trace: UITab_Trace.selectedViewController)
        } else if let preView_Trace = baseViewContrller_Trace?.presentedViewController {
            return currentViewController_Trace(view_Trace: preView_Trace)
        }
        return baseViewContrller_Trace
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
