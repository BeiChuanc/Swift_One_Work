import Foundation
import UIKit

extension UIViewController {
    
    static func currentViewController_Epoch(view_Epoch: UIViewController? = nil) -> UIViewController? {
        var baseViewContrller_Epoch = view_Epoch
        if baseViewContrller_Epoch == nil {
            if #available(iOS 13.0, *) {
                let windowScene = UIApplication.shared.connectedScenes
                   .first { $0.activationState == .foregroundActive } as? UIWindowScene
                baseViewContrller_Epoch = windowScene?.windows.first?.rootViewController
            } else {
                baseViewContrller_Epoch = UIApplication.shared.keyWindow?.rootViewController
            }
        }
        if let UINav_Epoch = baseViewContrller_Epoch as? UINavigationController {
            return currentViewController_Epoch(view_Epoch: UINav_Epoch.visibleViewController)
        } else if let UITab_Epoch = baseViewContrller_Epoch as? UITabBarController {
            return currentViewController_Epoch(view_Epoch: UITab_Epoch.selectedViewController)
        } else if let preView_Epoch = baseViewContrller_Epoch?.presentedViewController {
            return currentViewController_Epoch(view_Epoch: preView_Epoch)
        }
        return baseViewContrller_Epoch
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
