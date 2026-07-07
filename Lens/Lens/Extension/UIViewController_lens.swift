import Foundation
import UIKit

extension UIViewController {
    
    static func currentViewController_Lens(view_Lens: UIViewController? = nil) -> UIViewController? {
        var baseViewContrller_Lens = view_Lens
        if baseViewContrller_Lens == nil {
            if #available(iOS 13.0, *) {
                let windowScene = UIApplication.shared.connectedScenes
                   .first { $0.activationState == .foregroundActive } as? UIWindowScene
                baseViewContrller_Lens = windowScene?.windows.first?.rootViewController
            } else {
                baseViewContrller_Lens = UIApplication.shared.keyWindow?.rootViewController
            }
        }
        if let UINav_Lens = baseViewContrller_Lens as? UINavigationController {
            return currentViewController_Lens(view_Lens: UINav_Lens.visibleViewController)
        } else if let UITab_Lens = baseViewContrller_Lens as? UITabBarController {
            return currentViewController_Lens(view_Lens: UITab_Lens.selectedViewController)
        } else if let preView_Lens = baseViewContrller_Lens?.presentedViewController {
            return currentViewController_Lens(view_Lens: preView_Lens)
        }
        return baseViewContrller_Lens
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
