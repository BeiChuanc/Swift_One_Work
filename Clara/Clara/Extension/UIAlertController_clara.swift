import Foundation
import UIKit

extension UIAlertController {
    
    /// 登出
    static func logout_Clara(completion_Clara: @escaping() -> Void) {
        let alert_Clara = UIAlertController(title: "Prompt", message: "Are you sure you want to log out of the current account?", preferredStyle: .alert)
        let confirm_Clara = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Clara()
        })
        let cancel_Clara = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Clara.addAction(confirm_Clara)
        alert_Clara.addAction(cancel_Clara)
        UIViewController.currentViewController_Clara()?.present(alert_Clara, animated: true, completion: nil)
    }
    
    /// 删除
    static func delete_Clara(completion_Clara: @escaping() -> Void) {
        let alert_Clara = UIAlertController(title: "Prompt", message: "Are you sure you want to delete the current account?", preferredStyle: .alert)
        let confirm_Clara = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Clara()
        })
        let cancel_Clara = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Clara.addAction(confirm_Clara)
        alert_Clara.addAction(cancel_Clara)
        UIViewController.currentViewController_Clara()?.present(alert_Clara, animated: true, completion: nil)
    }
    
    /// 举报
    static func report_Clara(with isUser: Bool = false, completeBlock: @escaping () -> Void) {
        var reportAlter_Clara: UIAlertController!
        reportAlter_Clara = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
        
        let reportCommon : (UIAlertAction) -> Void = { action in
            completeBlock()
        }
        
        let report1_Clara = UIAlertAction(title: NSLocalizedString("Report Sexually Explicit Material", comment: ""), style: .default,handler: reportCommon)
        let report2_Clara = UIAlertAction(title: NSLocalizedString("Report spam", comment: ""), style: .default,handler: reportCommon)
        let report3_Clara = UIAlertAction(title: NSLocalizedString("Report something else", comment: ""), style: .default,handler: reportCommon)
        let report4_Clara = UIAlertAction(title: NSLocalizedString(isUser ? "Block" : "Report", comment: ""), style: .default,handler: reportCommon)
        let cancel_Clara = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel,handler: nil)
        reportAlter_Clara.addAction(report1_Clara)
        reportAlter_Clara.addAction(report2_Clara)
        reportAlter_Clara.addAction(report3_Clara)
        reportAlter_Clara.addAction(report4_Clara)
        reportAlter_Clara.addAction(cancel_Clara)
        reportAlter_Clara.modalPresentationStyle = .overFullScreen
        UIViewController.currentViewController_Clara()?.present(reportAlter_Clara, animated: true, completion: nil)
    }
}
