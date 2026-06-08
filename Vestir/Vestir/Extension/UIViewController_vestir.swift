import Foundation
import UIKit

extension UIViewController {
    
    static func currentViewController_Vestir(view_Vestir: UIViewController? = nil) -> UIViewController? {
        var baseViewContrller_Vestir = view_Vestir
        if baseViewContrller_Vestir == nil {
            if #available(iOS 13.0, *) {
                let windowScene = UIApplication.shared.connectedScenes
                   .first { $0.activationState == .foregroundActive } as? UIWindowScene
                baseViewContrller_Vestir = windowScene?.windows.first?.rootViewController
            } else {
                baseViewContrller_Vestir = UIApplication.shared.keyWindow?.rootViewController
            }
        }
        if let UINav_Vestir = baseViewContrller_Vestir as? UINavigationController {
            return currentViewController_Vestir(view_Vestir: UINav_Vestir.visibleViewController)
        } else if let UITab_Vestir = baseViewContrller_Vestir as? UITabBarController {
            return currentViewController_Vestir(view_Vestir: UITab_Vestir.selectedViewController)
        } else if let preView_Vestir = baseViewContrller_Vestir?.presentedViewController {
            return currentViewController_Vestir(view_Vestir: preView_Vestir)
        }
        return baseViewContrller_Vestir
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
