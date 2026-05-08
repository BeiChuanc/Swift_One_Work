import Foundation
import UIKit

extension UIViewController {
    
    static func currentViewController_Posture(view_Posture: UIViewController? = nil) -> UIViewController? {
        var baseViewContrller_Posture = view_Posture
        if baseViewContrller_Posture == nil {
            if #available(iOS 13.0, *) {
                let windowScene = UIApplication.shared.connectedScenes
                   .first { $0.activationState == .foregroundActive } as? UIWindowScene
                baseViewContrller_Posture = windowScene?.windows.first?.rootViewController
            } else {
                baseViewContrller_Posture = UIApplication.shared.keyWindow?.rootViewController
            }
        }
        if let UINav_Posture = baseViewContrller_Posture as? UINavigationController {
            return currentViewController_Posture(view_Posture: UINav_Posture.visibleViewController)
        } else if let UITab_Posture = baseViewContrller_Posture as? UITabBarController {
            return currentViewController_Posture(view_Posture: UITab_Posture.selectedViewController)
        } else if let preView_Posture = baseViewContrller_Posture?.presentedViewController {
            return currentViewController_Posture(view_Posture: preView_Posture)
        }
        return baseViewContrller_Posture
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
