import Foundation
import UIKit

extension UIAlertController {
    
    /// 登出
    static func logout_Hush(completion_Hush: @escaping() -> Void) {
        let alert_Hush = UIAlertController(title: "Prompt", message: "Are you sure you want to log out of the current account?", preferredStyle: .alert)
        let confirm_Hush = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Hush()
        })
        let cancel_Hush = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Hush.addAction(confirm_Hush)
        alert_Hush.addAction(cancel_Hush)
        UIViewController.currentViewController_Hush()?.present(alert_Hush, animated: true, completion: nil)
    }
    
    /// 删除
    static func delete_Hush(completion_Hush: @escaping() -> Void) {
        let alert_Hush = UIAlertController(title: "Prompt", message: "Are you sure you want to delete the current account?", preferredStyle: .alert)
        let confirm_Hush = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Hush()
        })
        let cancel_Hush = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Hush.addAction(confirm_Hush)
        alert_Hush.addAction(cancel_Hush)
        UIViewController.currentViewController_Hush()?.present(alert_Hush, animated: true, completion: nil)
    }
    
    /// 举报
    static func report_Hush(with isUser: Bool = false, completeBlock: @escaping () -> Void) {
        var reportAlter_Hush: UIAlertController!
        reportAlter_Hush = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
        
        let reportCommon : (UIAlertAction) -> Void = { action in
            completeBlock()
        }
        
        let report1_Hush = UIAlertAction(title: NSLocalizedString("Report Sexually Explicit Material", comment: ""), style: .default,handler: reportCommon)
        let report2_Hush = UIAlertAction(title: NSLocalizedString("Report spam", comment: ""), style: .default,handler: reportCommon)
        let report3_Hush = UIAlertAction(title: NSLocalizedString("Report something else", comment: ""), style: .default,handler: reportCommon)
        let report4_Hush = UIAlertAction(title: NSLocalizedString(isUser ? "Block" : "Report", comment: ""), style: .default,handler: reportCommon)
        let cancel_Hush = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel,handler: nil)
        reportAlter_Hush.addAction(report1_Hush)
        reportAlter_Hush.addAction(report2_Hush)
        reportAlter_Hush.addAction(report3_Hush)
        reportAlter_Hush.addAction(report4_Hush)
        reportAlter_Hush.addAction(cancel_Hush)
        reportAlter_Hush.modalPresentationStyle = .overFullScreen
        UIViewController.currentViewController_Hush()?.present(reportAlter_Hush, animated: true, completion: nil)
    }
}
