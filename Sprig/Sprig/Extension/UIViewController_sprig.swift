import Foundation
import UIKit

extension UIViewController {
    
    static func currentViewController_Sprig(view_Sprig: UIViewController? = nil) -> UIViewController? {
        var baseViewContrller_Sprig = view_Sprig
        if baseViewContrller_Sprig == nil {
            if #available(iOS 13.0, *) {
                let windowScene = UIApplication.shared.connectedScenes
                   .first { $0.activationState == .foregroundActive } as? UIWindowScene
                baseViewContrller_Sprig = windowScene?.windows.first?.rootViewController
            } else {
                baseViewContrller_Sprig = UIApplication.shared.keyWindow?.rootViewController
            }
        }
        if let UINav_Sprig = baseViewContrller_Sprig as? UINavigationController {
            return currentViewController_Sprig(view_Sprig: UINav_Sprig.visibleViewController)
        } else if let UITab_Sprig = baseViewContrller_Sprig as? UITabBarController {
            return currentViewController_Sprig(view_Sprig: UITab_Sprig.selectedViewController)
        } else if let preView_Sprig = baseViewContrller_Sprig?.presentedViewController {
            return currentViewController_Sprig(view_Sprig: preView_Sprig)
        }
        return baseViewContrller_Sprig
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
