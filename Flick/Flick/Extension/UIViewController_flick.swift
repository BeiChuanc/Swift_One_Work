import Foundation
import UIKit

extension UIViewController {
    
    static func currentViewController_Flick(view_Flick: UIViewController? = nil) -> UIViewController? {
        var baseViewContrller_Flick = view_Flick
        if baseViewContrller_Flick == nil {
            if #available(iOS 13.0, *) {
                let windowScene = UIApplication.shared.connectedScenes
                   .first { $0.activationState == .foregroundActive } as? UIWindowScene
                baseViewContrller_Flick = windowScene?.windows.first?.rootViewController
            } else {
                baseViewContrller_Flick = UIApplication.shared.keyWindow?.rootViewController
            }
        }
        if let UINav_Flick = baseViewContrller_Flick as? UINavigationController {
            return currentViewController_Flick(view_Flick: UINav_Flick.visibleViewController)
        } else if let UITab_Flick = baseViewContrller_Flick as? UITabBarController {
            return currentViewController_Flick(view_Flick: UITab_Flick.selectedViewController)
        } else if let preView_Flick = baseViewContrller_Flick?.presentedViewController {
            return currentViewController_Flick(view_Flick: preView_Flick)
        }
        return baseViewContrller_Flick
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
