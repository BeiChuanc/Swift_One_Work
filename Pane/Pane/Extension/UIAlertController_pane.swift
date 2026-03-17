import Foundation
import UIKit

extension UIAlertController {
    
    /// 登出
    static func logout_Pane(completion_Pane: @escaping() -> Void) {
        let alert_Pane = UIAlertController(title: "Prompt", message: "Are you sure you want to log out of the current account?", preferredStyle: .alert)
        let confirm_Pane = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Pane()
        })
        let cancel_Pane = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Pane.addAction(confirm_Pane)
        alert_Pane.addAction(cancel_Pane)
        UIViewController.currentViewController_Pane()?.present(alert_Pane, animated: true, completion: nil)
    }
    
    /// 删除
    static func delete_Pane(completion_Pane: @escaping() -> Void) {
        let alert_Pane = UIAlertController(title: "Prompt", message: "Are you sure you want to delete the current account?", preferredStyle: .alert)
        let confirm_Pane = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Pane()
        })
        let cancel_Pane = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Pane.addAction(confirm_Pane)
        alert_Pane.addAction(cancel_Pane)
        UIViewController.currentViewController_Pane()?.present(alert_Pane, animated: true, completion: nil)
    }
    
    /// 举报
    static func report_Pane(with isUser: Bool = false, completeBlock: @escaping () -> Void) {
        var reportAlter_Pane: UIAlertController!
        reportAlter_Pane = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
        
        let reportCommon : (UIAlertAction) -> Void = { action in
            completeBlock()
        }
        
        let report1_Pane = UIAlertAction(title: NSLocalizedString("Report Sexually Explicit Material", comment: ""), style: .default,handler: reportCommon)
        let report2_Pane = UIAlertAction(title: NSLocalizedString("Report spam", comment: ""), style: .default,handler: reportCommon)
        let report3_Pane = UIAlertAction(title: NSLocalizedString("Report something else", comment: ""), style: .default,handler: reportCommon)
        let report4_Pane = UIAlertAction(title: NSLocalizedString(isUser ? "Block" : "Report", comment: ""), style: .default,handler: reportCommon)
        let cancel_Pane = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel,handler: nil)
        reportAlter_Pane.addAction(report1_Pane)
        reportAlter_Pane.addAction(report2_Pane)
        reportAlter_Pane.addAction(report3_Pane)
        reportAlter_Pane.addAction(report4_Pane)
        reportAlter_Pane.addAction(cancel_Pane)
        reportAlter_Pane.modalPresentationStyle = .overFullScreen
        UIViewController.currentViewController_Pane()?.present(reportAlter_Pane, animated: true, completion: nil)
    }
}
