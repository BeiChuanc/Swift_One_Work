import Foundation
import UIKit

extension UIViewController {
    
    static func currentViewController_Niche(view_Niche: UIViewController? = nil) -> UIViewController? {
        var baseViewContrller_Niche = view_Niche
        if baseViewContrller_Niche == nil {
            if #available(iOS 13.0, *) {
                let windowScene = UIApplication.shared.connectedScenes
                   .first { $0.activationState == .foregroundActive } as? UIWindowScene
                baseViewContrller_Niche = windowScene?.windows.first?.rootViewController
            } else {
                baseViewContrller_Niche = UIApplication.shared.keyWindow?.rootViewController
            }
        }
        if let UINav_Niche = baseViewContrller_Niche as? UINavigationController {
            return currentViewController_Niche(view_Niche: UINav_Niche.visibleViewController)
        } else if let UITab_Niche = baseViewContrller_Niche as? UITabBarController {
            return currentViewController_Niche(view_Niche: UITab_Niche.selectedViewController)
        } else if let preView_Niche = baseViewContrller_Niche?.presentedViewController {
            return currentViewController_Niche(view_Niche: preView_Niche)
        }
        return baseViewContrller_Niche
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
