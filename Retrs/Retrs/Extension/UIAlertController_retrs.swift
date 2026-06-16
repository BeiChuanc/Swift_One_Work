import Foundation
import UIKit

extension UIAlertController {
    
    /// 登出
    static func logout_Retrs(completion_Retrs: @escaping() -> Void) {
        let alert_Retrs = UIAlertController(title: "Prompt", message: "Are you sure you want to log out of the current account?", preferredStyle: .alert)
        let confirm_Retrs = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Retrs()
        })
        let cancel_Retrs = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Retrs.addAction(confirm_Retrs)
        alert_Retrs.addAction(cancel_Retrs)
        UIViewController.currentViewController_Retrs()?.present(alert_Retrs, animated: true, completion: nil)
    }
    
    /// 删除
    static func delete_Retrs(completion_Retrs: @escaping() -> Void) {
        let alert_Retrs = UIAlertController(title: "Prompt", message: "Are you sure you want to delete the current account?", preferredStyle: .alert)
        let confirm_Retrs = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Retrs()
        })
        let cancel_Retrs = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Retrs.addAction(confirm_Retrs)
        alert_Retrs.addAction(cancel_Retrs)
        UIViewController.currentViewController_Retrs()?.present(alert_Retrs, animated: true, completion: nil)
    }
    
    /// 举报
    static func report_Retrs(with isUser: Bool = false, completeBlock: @escaping () -> Void) {
        var reportAlter_Retrs: UIAlertController!
        reportAlter_Retrs = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
        
        let reportCommon : (UIAlertAction) -> Void = { action in
            completeBlock()
        }
        
        let report1_Retrs = UIAlertAction(title: NSLocalizedString("Report Sexually Explicit Material", comment: ""), style: .default,handler: reportCommon)
        let report2_Retrs = UIAlertAction(title: NSLocalizedString("Report spam", comment: ""), style: .default,handler: reportCommon)
        let report3_Retrs = UIAlertAction(title: NSLocalizedString("Report something else", comment: ""), style: .default,handler: reportCommon)
        let report4_Retrs = UIAlertAction(title: NSLocalizedString(isUser ? "Block" : "Report", comment: ""), style: .default,handler: reportCommon)
        let cancel_Retrs = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel,handler: nil)
        reportAlter_Retrs.addAction(report1_Retrs)
        reportAlter_Retrs.addAction(report2_Retrs)
        reportAlter_Retrs.addAction(report3_Retrs)
        reportAlter_Retrs.addAction(report4_Retrs)
        reportAlter_Retrs.addAction(cancel_Retrs)
        reportAlter_Retrs.modalPresentationStyle = .overFullScreen
        UIViewController.currentViewController_Retrs()?.present(reportAlter_Retrs, animated: true, completion: nil)
    }
}
