import Foundation
import UIKit

extension UIViewController {
    
    static func currentViewController_Sylva(view_Sylva: UIViewController? = nil) -> UIViewController? {
        var baseViewContrller_Sylva = view_Sylva
        if baseViewContrller_Sylva == nil {
            if #available(iOS 13.0, *) {
                let windowScene = UIApplication.shared.connectedScenes
                   .first { $0.activationState == .foregroundActive } as? UIWindowScene
                baseViewContrller_Sylva = windowScene?.windows.first?.rootViewController
            } else {
                baseViewContrller_Sylva = UIApplication.shared.keyWindow?.rootViewController
            }
        }
        if let UINav_Sylva = baseViewContrller_Sylva as? UINavigationController {
            return currentViewController_Sylva(view_Sylva: UINav_Sylva.visibleViewController)
        } else if let UITab_Sylva = baseViewContrller_Sylva as? UITabBarController {
            return currentViewController_Sylva(view_Sylva: UITab_Sylva.selectedViewController)
        } else if let preView_Sylva = baseViewContrller_Sylva?.presentedViewController {
            return currentViewController_Sylva(view_Sylva: preView_Sylva)
        }
        return baseViewContrller_Sylva
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
