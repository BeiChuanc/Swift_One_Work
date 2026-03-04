import Foundation
import UIKit

extension UIAlertController {
    
    /// 登出
    static func logout_Trace(completion_Trace: @escaping() -> Void) {
        let alert_Trace = UIAlertController(title: "Prompt", message: "Are you sure you want to log out of the current account?", preferredStyle: .alert)
        let confirm_Trace = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Trace()
        })
        let cancel_Trace = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Trace.addAction(confirm_Trace)
        alert_Trace.addAction(cancel_Trace)
        UIViewController.currentViewController_Trace()?.present(alert_Trace, animated: true, completion: nil)
    }
    
    /// 删除
    static func delete_Trace(completion_Trace: @escaping() -> Void) {
        let alert_Trace = UIAlertController(title: "Prompt", message: "Are you sure you want to delete the current account?", preferredStyle: .alert)
        let confirm_Trace = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Trace()
        })
        let cancel_Trace = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Trace.addAction(confirm_Trace)
        alert_Trace.addAction(cancel_Trace)
        UIViewController.currentViewController_Trace()?.present(alert_Trace, animated: true, completion: nil)
    }
    
    /// 举报
    static func report_Trace(with isUser: Bool = false, completeBlock: @escaping () -> Void) {
        var reportAlter_Trace: UIAlertController!
        reportAlter_Trace = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
        
        let reportCommon : (UIAlertAction) -> Void = { action in
            completeBlock()
        }
        
        let report1_Trace = UIAlertAction(title: NSLocalizedString("Report Sexually Explicit Material", comment: ""), style: .default,handler: reportCommon)
        let report2_Trace = UIAlertAction(title: NSLocalizedString("Report spam", comment: ""), style: .default,handler: reportCommon)
        let report3_Trace = UIAlertAction(title: NSLocalizedString("Report something else", comment: ""), style: .default,handler: reportCommon)
        let report4_Trace = UIAlertAction(title: NSLocalizedString(isUser ? "Block" : "Report", comment: ""), style: .default,handler: reportCommon)
        let cancel_Trace = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel,handler: nil)
        reportAlter_Trace.addAction(report1_Trace)
        reportAlter_Trace.addAction(report2_Trace)
        reportAlter_Trace.addAction(report3_Trace)
        reportAlter_Trace.addAction(report4_Trace)
        reportAlter_Trace.addAction(cancel_Trace)
        reportAlter_Trace.modalPresentationStyle = .overFullScreen
        UIViewController.currentViewController_Trace()?.present(reportAlter_Trace, animated: true, completion: nil)
    }
}
