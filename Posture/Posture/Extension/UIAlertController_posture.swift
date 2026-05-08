import Foundation
import UIKit

extension UIAlertController {
    
    /// 登出
    static func logout_Posture(completion_Posture: @escaping() -> Void) {
        let alert_Posture = UIAlertController(title: "Prompt", message: "Are you sure you want to log out of the current account?", preferredStyle: .alert)
        let confirm_Posture = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Posture()
        })
        let cancel_Posture = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Posture.addAction(confirm_Posture)
        alert_Posture.addAction(cancel_Posture)
        UIViewController.currentViewController_Posture()?.present(alert_Posture, animated: true, completion: nil)
    }
    
    /// 删除
    static func delete_Posture(completion_Posture: @escaping() -> Void) {
        let alert_Posture = UIAlertController(title: "Prompt", message: "Are you sure you want to delete the current account?", preferredStyle: .alert)
        let confirm_Posture = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Posture()
        })
        let cancel_Posture = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Posture.addAction(confirm_Posture)
        alert_Posture.addAction(cancel_Posture)
        UIViewController.currentViewController_Posture()?.present(alert_Posture, animated: true, completion: nil)
    }
    
    /// 举报
    static func report_Posture(with isUser: Bool = false, completeBlock: @escaping () -> Void) {
        var reportAlter_Posture: UIAlertController!
        reportAlter_Posture = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
        
        let reportCommon : (UIAlertAction) -> Void = { action in
            completeBlock()
        }
        
        let report1_Posture = UIAlertAction(title: NSLocalizedString("Report Sexually Explicit Material", comment: ""), style: .default,handler: reportCommon)
        let report2_Posture = UIAlertAction(title: NSLocalizedString("Report spam", comment: ""), style: .default,handler: reportCommon)
        let report3_Posture = UIAlertAction(title: NSLocalizedString("Report something else", comment: ""), style: .default,handler: reportCommon)
        let report4_Posture = UIAlertAction(title: NSLocalizedString(isUser ? "Block" : "Report", comment: ""), style: .default,handler: reportCommon)
        let cancel_Posture = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel,handler: nil)
        reportAlter_Posture.addAction(report1_Posture)
        reportAlter_Posture.addAction(report2_Posture)
        reportAlter_Posture.addAction(report3_Posture)
        reportAlter_Posture.addAction(report4_Posture)
        reportAlter_Posture.addAction(cancel_Posture)
        reportAlter_Posture.modalPresentationStyle = .overFullScreen
        UIViewController.currentViewController_Posture()?.present(reportAlter_Posture, animated: true, completion: nil)
    }
}
