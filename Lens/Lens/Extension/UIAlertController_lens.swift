import Foundation
import UIKit

extension UIAlertController {
    
    /// 登出
    static func logout_Lens(completion_Lens: @escaping() -> Void) {
        let alert_Lens = UIAlertController(title: "Prompt", message: "Are you sure you want to log out of the current account?", preferredStyle: .alert)
        let confirm_Lens = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Lens()
        })
        let cancel_Lens = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Lens.addAction(confirm_Lens)
        alert_Lens.addAction(cancel_Lens)
        UIViewController.currentViewController_Lens()?.present(alert_Lens, animated: true, completion: nil)
    }
    
    /// 删除
    static func delete_Lens(completion_Lens: @escaping() -> Void) {
        let alert_Lens = UIAlertController(title: "Prompt", message: "Are you sure you want to delete the current account?", preferredStyle: .alert)
        let confirm_Lens = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Lens()
        })
        let cancel_Lens = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Lens.addAction(confirm_Lens)
        alert_Lens.addAction(cancel_Lens)
        UIViewController.currentViewController_Lens()?.present(alert_Lens, animated: true, completion: nil)
    }
    
    /// 举报
    static func report_Lens(
        with isUser_Lens: Bool = false,
        completeBlock_Lens: @escaping () -> Void,
        cancelBlock_Lens: (() -> Void)? = nil
    ) {
        var reportAlter_Lens: UIAlertController!
        reportAlter_Lens = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)

        let reportCommon_Lens: (UIAlertAction) -> Void = { _ in
            completeBlock_Lens()
        }

        let report1_Lens = UIAlertAction(title: NSLocalizedString("Report Sexually Explicit Material", comment: ""), style: .default, handler: reportCommon_Lens)
        let report2_Lens = UIAlertAction(title: NSLocalizedString("Report spam", comment: ""), style: .default, handler: reportCommon_Lens)
        let report3_Lens = UIAlertAction(title: NSLocalizedString("Report something else", comment: ""), style: .default, handler: reportCommon_Lens)
        let report4_Lens = UIAlertAction(title: NSLocalizedString(isUser_Lens ? "Block" : "Report", comment: ""), style: .default, handler: reportCommon_Lens)
        let cancel_Lens = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
            cancelBlock_Lens?()
        }
        reportAlter_Lens.addAction(report1_Lens)
        reportAlter_Lens.addAction(report2_Lens)
        reportAlter_Lens.addAction(report3_Lens)
        reportAlter_Lens.addAction(report4_Lens)
        reportAlter_Lens.addAction(cancel_Lens)
        resolvePresenter_Lens(preferred_Lens: nil).present(reportAlter_Lens, animated: true)
    }

    /// 解析弹窗展示控制器（优先当前顶层 VC）
    private static func resolvePresenter_Lens(preferred_Lens: UIViewController?) -> UIViewController {
        preferred_Lens ?? UIViewController.currentViewController_Lens() ?? UIViewController()
    }
}
