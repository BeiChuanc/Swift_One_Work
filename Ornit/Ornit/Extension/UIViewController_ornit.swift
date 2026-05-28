import Foundation
import UIKit

extension UIViewController {
    
    static func currentViewController_Ornit(view_Ornit: UIViewController? = nil) -> UIViewController? {
        var baseViewContrller_Ornit = view_Ornit
        if baseViewContrller_Ornit == nil {
            if #available(iOS 13.0, *) {
                let windowScene = UIApplication.shared.connectedScenes
                   .first { $0.activationState == .foregroundActive } as? UIWindowScene
                baseViewContrller_Ornit = windowScene?.windows.first?.rootViewController
            } else {
                baseViewContrller_Ornit = UIApplication.shared.keyWindow?.rootViewController
            }
        }
        if let UINav_Ornit = baseViewContrller_Ornit as? UINavigationController {
            return currentViewController_Ornit(view_Ornit: UINav_Ornit.visibleViewController)
        } else if let UITab_Ornit = baseViewContrller_Ornit as? UITabBarController {
            return currentViewController_Ornit(view_Ornit: UITab_Ornit.selectedViewController)
        } else if let preView_Ornit = baseViewContrller_Ornit?.presentedViewController {
            return currentViewController_Ornit(view_Ornit: preView_Ornit)
        }
        return baseViewContrller_Ornit
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
