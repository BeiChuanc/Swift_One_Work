import Foundation
import UIKit

extension UIViewController {
    
    static func currentViewController_Orna(view_Orna: UIViewController? = nil) -> UIViewController? {
        var baseViewContrller_Orna = view_Orna
        if baseViewContrller_Orna == nil {
            if #available(iOS 13.0, *) {
                let windowScene = UIApplication.shared.connectedScenes
                   .first { $0.activationState == .foregroundActive } as? UIWindowScene
                baseViewContrller_Orna = windowScene?.windows.first?.rootViewController
            } else {
                baseViewContrller_Orna = UIApplication.shared.keyWindow?.rootViewController
            }
        }
        if let UINav_Orna = baseViewContrller_Orna as? UINavigationController {
            return currentViewController_Orna(view_Orna: UINav_Orna.visibleViewController)
        } else if let UITab_Orna = baseViewContrller_Orna as? UITabBarController {
            return currentViewController_Orna(view_Orna: UITab_Orna.selectedViewController)
        } else if let preView_Orna = baseViewContrller_Orna?.presentedViewController {
            return currentViewController_Orna(view_Orna: preView_Orna)
        }
        return baseViewContrller_Orna
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
