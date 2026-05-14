import Foundation
import UIKit

extension UIViewController {
    
    static func currentViewController_Echd(view_Echd: UIViewController? = nil) -> UIViewController? {
        var baseViewContrller_Echd = view_Echd
        if baseViewContrller_Echd == nil {
            if #available(iOS 13.0, *) {
                let windowScene = UIApplication.shared.connectedScenes
                   .first { $0.activationState == .foregroundActive } as? UIWindowScene
                baseViewContrller_Echd = windowScene?.windows.first?.rootViewController
            } else {
                baseViewContrller_Echd = UIApplication.shared.keyWindow?.rootViewController
            }
        }
        if let UINav_Echd = baseViewContrller_Echd as? UINavigationController {
            return currentViewController_Echd(view_Echd: UINav_Echd.visibleViewController)
        } else if let UITab_Echd = baseViewContrller_Echd as? UITabBarController {
            return currentViewController_Echd(view_Echd: UITab_Echd.selectedViewController)
        } else if let preView_Echd = baseViewContrller_Echd?.presentedViewController {
            return currentViewController_Echd(view_Echd: preView_Echd)
        }
        return baseViewContrller_Echd
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
