import Foundation
import UIKit

extension UIViewController {
    
    static func currentViewController_Breeze(view_Breeze: UIViewController? = nil) -> UIViewController? {
        var baseViewContrller_Breeze = view_Breeze
        if baseViewContrller_Breeze == nil {
            if #available(iOS 13.0, *) {
                let windowScene = UIApplication.shared.connectedScenes
                   .first { $0.activationState == .foregroundActive } as? UIWindowScene
                baseViewContrller_Breeze = windowScene?.windows.first?.rootViewController
            } else {
                baseViewContrller_Breeze = UIApplication.shared.keyWindow?.rootViewController
            }
        }
        if let UINav_Breeze = baseViewContrller_Breeze as? UINavigationController {
            return currentViewController_Breeze(view_Breeze: UINav_Breeze.visibleViewController)
        } else if let UITab_Breeze = baseViewContrller_Breeze as? UITabBarController {
            return currentViewController_Breeze(view_Breeze: UITab_Breeze.selectedViewController)
        } else if let preView_Breeze = baseViewContrller_Breeze?.presentedViewController {
            return currentViewController_Breeze(view_Breeze: preView_Breeze)
        }
        return baseViewContrller_Breeze
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
