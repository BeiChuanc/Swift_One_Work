import Foundation
import UIKit

extension UIViewController {
    
    static func currentViewController_Somnia(view_Somnia: UIViewController? = nil) -> UIViewController? {
        var baseViewContrller_Somnia = view_Somnia
        if baseViewContrller_Somnia == nil {
            if #available(iOS 13.0, *) {
                let windowScene = UIApplication.shared.connectedScenes
                   .first { $0.activationState == .foregroundActive } as? UIWindowScene
                baseViewContrller_Somnia = windowScene?.windows.first?.rootViewController
            } else {
                baseViewContrller_Somnia = UIApplication.shared.keyWindow?.rootViewController
            }
        }
        if let UINav_Somnia = baseViewContrller_Somnia as? UINavigationController {
            return currentViewController_Somnia(view_Somnia: UINav_Somnia.visibleViewController)
        } else if let UITab_Somnia = baseViewContrller_Somnia as? UITabBarController {
            return currentViewController_Somnia(view_Somnia: UITab_Somnia.selectedViewController)
        } else if let preView_Somnia = baseViewContrller_Somnia?.presentedViewController {
            return currentViewController_Somnia(view_Somnia: preView_Somnia)
        }
        return baseViewContrller_Somnia
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
