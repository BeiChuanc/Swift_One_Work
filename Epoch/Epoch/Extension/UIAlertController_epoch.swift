import Foundation
import UIKit

extension UIAlertController {
    
    /// 登出
    static func logout_Epoch(completion_Epoch: @escaping() -> Void) {
        let alert_Epoch = UIAlertController(title: "Prompt", message: "Are you sure you want to log out of the current account?", preferredStyle: .alert)
        let confirm_Epoch = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Epoch()
        })
        let cancel_Epoch = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Epoch.addAction(confirm_Epoch)
        alert_Epoch.addAction(cancel_Epoch)
        UIViewController.currentViewController_Epoch()?.present(alert_Epoch, animated: true, completion: nil)
    }
    
    /// 删除
    static func delete_Epoch(completion_Epoch: @escaping() -> Void) {
        let alert_Epoch = UIAlertController(title: "Prompt", message: "Are you sure you want to delete the current account?", preferredStyle: .alert)
        let confirm_Epoch = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Epoch()
        })
        let cancel_Epoch = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Epoch.addAction(confirm_Epoch)
        alert_Epoch.addAction(cancel_Epoch)
        UIViewController.currentViewController_Epoch()?.present(alert_Epoch, animated: true, completion: nil)
    }
    
    /// 举报
    static func report_Epoch(with isUser: Bool = false, completeBlock: @escaping () -> Void) {
        var reportAlter_Epoch: UIAlertController!
        reportAlter_Epoch = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
        
        let reportCommon : (UIAlertAction) -> Void = { action in
            completeBlock()
        }
        
        let report1_Epoch = UIAlertAction(title: NSLocalizedString("Report Sexually Explicit Material", comment: ""), style: .default,handler: reportCommon)
        let report2_Epoch = UIAlertAction(title: NSLocalizedString("Report spam", comment: ""), style: .default,handler: reportCommon)
        let report3_Epoch = UIAlertAction(title: NSLocalizedString("Report something else", comment: ""), style: .default,handler: reportCommon)
        let report4_Epoch = UIAlertAction(title: NSLocalizedString(isUser ? "Block" : "Report", comment: ""), style: .default,handler: reportCommon)
        let cancel_Epoch = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel,handler: nil)
        reportAlter_Epoch.addAction(report1_Epoch)
        reportAlter_Epoch.addAction(report2_Epoch)
        reportAlter_Epoch.addAction(report3_Epoch)
        reportAlter_Epoch.addAction(report4_Epoch)
        reportAlter_Epoch.addAction(cancel_Epoch)
        reportAlter_Epoch.modalPresentationStyle = .overFullScreen
        UIViewController.currentViewController_Epoch()?.present(reportAlter_Epoch, animated: true, completion: nil)
    }
}
