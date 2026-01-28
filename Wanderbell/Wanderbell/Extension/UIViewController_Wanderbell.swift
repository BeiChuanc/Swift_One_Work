import Foundation
import UIKit

extension UIViewController {
    
    static func currentViewController_Wanderbell(view_Wanderbell: UIViewController? = nil) -> UIViewController? {
        var baseViewContrller_Wanderbell = view_Wanderbell
        if baseViewContrller_Wanderbell == nil {
            if #available(iOS 13.0, *) {
                let windowScene = UIApplication.shared.connectedScenes
                   .first { $0.activationState == .foregroundActive } as? UIWindowScene
                baseViewContrller_Wanderbell = windowScene?.windows.first?.rootViewController
            } else {
                baseViewContrller_Wanderbell = UIApplication.shared.keyWindow?.rootViewController
            }
        }
        if let UINav_Wanderbell = baseViewContrller_Wanderbell as? UINavigationController {
            return currentViewController_Wanderbell(view_Wanderbell: UINav_Wanderbell.visibleViewController)
        } else if let UITab_Wanderbell = baseViewContrller_Wanderbell as? UITabBarController {
            return currentViewController_Wanderbell(view_Wanderbell: UITab_Wanderbell.selectedViewController)
        } else if let preView_Wanderbell = baseViewContrller_Wanderbell?.presentedViewController {
            return currentViewController_Wanderbell(view_Wanderbell: preView_Wanderbell)
        }
        return baseViewContrller_Wanderbell
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
