import Foundation
import UIKit

extension UIAlertController {
    
    /// 登出
    static func logout_Glasspaint(completion_Glasspaint: @escaping() -> Void) {
        let alert_Glasspaint = UIAlertController(title: "Prompt", message: "Are you sure you want to log out of the current account?", preferredStyle: .alert)
        let confirm_Glasspaint = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Glasspaint()
        })
        let cancel_Glasspaint = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Glasspaint.addAction(confirm_Glasspaint)
        alert_Glasspaint.addAction(cancel_Glasspaint)
        UIViewController.currentViewController_Glasspaint()?.present(alert_Glasspaint, animated: true, completion: nil)
    }
    
    /// 删除
    static func delete_Glasspaint(completion_Glasspaint: @escaping() -> Void) {
        let alert_Glasspaint = UIAlertController(title: "Prompt", message: "Are you sure you want to delete the current account?", preferredStyle: .alert)
        let confirm_Glasspaint = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Glasspaint()
        })
        let cancel_Glasspaint = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Glasspaint.addAction(confirm_Glasspaint)
        alert_Glasspaint.addAction(cancel_Glasspaint)
        UIViewController.currentViewController_Glasspaint()?.present(alert_Glasspaint, animated: true, completion: nil)
    }
    
    /// 举报
    static func report_Glasspaint(with isUser: Bool = false, completeBlock: @escaping () -> Void) {
        var reportAlter_Glasspaint: UIAlertController!
        reportAlter_Glasspaint = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
        
        let reportCommon : (UIAlertAction) -> Void = { action in
            completeBlock()
        }
        
        let report1_Glasspaint = UIAlertAction(title: NSLocalizedString("Report Sexually Explicit Material", comment: ""), style: .default,handler: reportCommon)
        let report2_Glasspaint = UIAlertAction(title: NSLocalizedString("Report spam", comment: ""), style: .default,handler: reportCommon)
        let report3_Glasspaint = UIAlertAction(title: NSLocalizedString("Report something else", comment: ""), style: .default,handler: reportCommon)
        let report4_Glasspaint = UIAlertAction(title: NSLocalizedString(isUser ? "Block" : "Report", comment: ""), style: .default,handler: reportCommon)
        let cancel_Glasspaint = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel,handler: nil)
        reportAlter_Glasspaint.addAction(report1_Glasspaint)
        reportAlter_Glasspaint.addAction(report2_Glasspaint)
        reportAlter_Glasspaint.addAction(report3_Glasspaint)
        reportAlter_Glasspaint.addAction(report4_Glasspaint)
        reportAlter_Glasspaint.addAction(cancel_Glasspaint)
        reportAlter_Glasspaint.modalPresentationStyle = .overFullScreen
        UIViewController.currentViewController_Glasspaint()?.present(reportAlter_Glasspaint, animated: true, completion: nil)
    }
}
