import Foundation
import UIKit

extension UIAlertController {
    
    /// 登出
    static func logout_Ornit(completion_Ornit: @escaping() -> Void) {
        let alert_Ornit = UIAlertController(title: "Prompt", message: "Are you sure you want to log out of the current account?", preferredStyle: .alert)
        let confirm_Ornit = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Ornit()
        })
        let cancel_Ornit = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Ornit.addAction(confirm_Ornit)
        alert_Ornit.addAction(cancel_Ornit)
        UIViewController.currentViewController_Ornit()?.present(alert_Ornit, animated: true, completion: nil)
    }
    
    /// 删除
    static func delete_Ornit(completion_Ornit: @escaping() -> Void) {
        let alert_Ornit = UIAlertController(title: "Prompt", message: "Are you sure you want to delete the current account?", preferredStyle: .alert)
        let confirm_Ornit = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Ornit()
        })
        let cancel_Ornit = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Ornit.addAction(confirm_Ornit)
        alert_Ornit.addAction(cancel_Ornit)
        UIViewController.currentViewController_Ornit()?.present(alert_Ornit, animated: true, completion: nil)
    }
    
    /// 举报
    static func report_Ornit(with isUser: Bool = false, completeBlock: @escaping () -> Void) {
        var reportAlter_Ornit: UIAlertController!
        reportAlter_Ornit = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
        
        let reportCommon : (UIAlertAction) -> Void = { action in
            completeBlock()
        }
        
        let report1_Ornit = UIAlertAction(title: NSLocalizedString("Report Sexually Explicit Material", comment: ""), style: .default,handler: reportCommon)
        let report2_Ornit = UIAlertAction(title: NSLocalizedString("Report spam", comment: ""), style: .default,handler: reportCommon)
        let report3_Ornit = UIAlertAction(title: NSLocalizedString("Report something else", comment: ""), style: .default,handler: reportCommon)
        let report4_Ornit = UIAlertAction(title: NSLocalizedString(isUser ? "Block" : "Report", comment: ""), style: .default,handler: reportCommon)
        let cancel_Ornit = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel,handler: nil)
        reportAlter_Ornit.addAction(report1_Ornit)
        reportAlter_Ornit.addAction(report2_Ornit)
        reportAlter_Ornit.addAction(report3_Ornit)
        reportAlter_Ornit.addAction(report4_Ornit)
        reportAlter_Ornit.addAction(cancel_Ornit)
        reportAlter_Ornit.modalPresentationStyle = .overFullScreen
        UIViewController.currentViewController_Ornit()?.present(reportAlter_Ornit, animated: true, completion: nil)
    }
}
