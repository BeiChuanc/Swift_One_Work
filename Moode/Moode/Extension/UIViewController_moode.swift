import Foundation
import UIKit

extension UIViewController {
    
    static func currentViewController_Moode(view_Moode: UIViewController? = nil) -> UIViewController? {
        var baseViewContrller_Moode = view_Moode
        if baseViewContrller_Moode == nil {
            if #available(iOS 13.0, *) {
                let windowScene = UIApplication.shared.connectedScenes
                   .first { $0.activationState == .foregroundActive } as? UIWindowScene
                baseViewContrller_Moode = windowScene?.windows.first?.rootViewController
            } else {
                baseViewContrller_Moode = UIApplication.shared.keyWindow?.rootViewController
            }
        }
        if let UINav_Moode = baseViewContrller_Moode as? UINavigationController {
            return currentViewController_Moode(view_Moode: UINav_Moode.visibleViewController)
        } else if let UITab_Moode = baseViewContrller_Moode as? UITabBarController {
            return currentViewController_Moode(view_Moode: UITab_Moode.selectedViewController)
        } else if let preView_Moode = baseViewContrller_Moode?.presentedViewController {
            return currentViewController_Moode(view_Moode: preView_Moode)
        }
        return baseViewContrller_Moode
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
