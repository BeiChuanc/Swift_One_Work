import Foundation
import UIKit

extension UIViewController {
    
    static func currentViewController_Doze(view_Doze: UIViewController? = nil) -> UIViewController? {
        var baseViewContrller_Doze = view_Doze
        if baseViewContrller_Doze == nil {
            if #available(iOS 13.0, *) {
                let windowScene = UIApplication.shared.connectedScenes
                   .first { $0.activationState == .foregroundActive } as? UIWindowScene
                baseViewContrller_Doze = windowScene?.windows.first?.rootViewController
            } else {
                baseViewContrller_Doze = UIApplication.shared.keyWindow?.rootViewController
            }
        }
        if let UINav_Doze = baseViewContrller_Doze as? UINavigationController {
            return currentViewController_Doze(view_Doze: UINav_Doze.visibleViewController)
        } else if let UITab_Doze = baseViewContrller_Doze as? UITabBarController {
            return currentViewController_Doze(view_Doze: UITab_Doze.selectedViewController)
        } else if let preView_Doze = baseViewContrller_Doze?.presentedViewController {
            return currentViewController_Doze(view_Doze: preView_Doze)
        }
        return baseViewContrller_Doze
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
