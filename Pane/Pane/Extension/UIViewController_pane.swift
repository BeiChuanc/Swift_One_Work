import Foundation
import UIKit

extension UIViewController {
    
    static func currentViewController_Pane(view_Pane: UIViewController? = nil) -> UIViewController? {
        var baseViewContrller_Pane = view_Pane
        if baseViewContrller_Pane == nil {
            if #available(iOS 13.0, *) {
                let windowScene = UIApplication.shared.connectedScenes
                   .first { $0.activationState == .foregroundActive } as? UIWindowScene
                baseViewContrller_Pane = windowScene?.windows.first?.rootViewController
            } else {
                baseViewContrller_Pane = UIApplication.shared.keyWindow?.rootViewController
            }
        }
        if let UINav_Pane = baseViewContrller_Pane as? UINavigationController {
            return currentViewController_Pane(view_Pane: UINav_Pane.visibleViewController)
        } else if let UITab_Pane = baseViewContrller_Pane as? UITabBarController {
            return currentViewController_Pane(view_Pane: UITab_Pane.selectedViewController)
        } else if let preView_Pane = baseViewContrller_Pane?.presentedViewController {
            return currentViewController_Pane(view_Pane: preView_Pane)
        }
        return baseViewContrller_Pane
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
