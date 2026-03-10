import Foundation
import UIKit

extension UIAlertController {
    
    /// 登出
    static func logout_Doze(completion_Doze: @escaping() -> Void) {
        let alert_Doze = UIAlertController(title: "Prompt", message: "Are you sure you want to log out of the current account?", preferredStyle: .alert)
        let confirm_Doze = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Doze()
        })
        let cancel_Doze = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Doze.addAction(confirm_Doze)
        alert_Doze.addAction(cancel_Doze)
        UIViewController.currentViewController_Doze()?.present(alert_Doze, animated: true, completion: nil)
    }
    
    /// 删除
    static func delete_Doze(completion_Doze: @escaping() -> Void) {
        let alert_Doze = UIAlertController(title: "Prompt", message: "Are you sure you want to delete the current account?", preferredStyle: .alert)
        let confirm_Doze = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Doze()
        })
        let cancel_Doze = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Doze.addAction(confirm_Doze)
        alert_Doze.addAction(cancel_Doze)
        UIViewController.currentViewController_Doze()?.present(alert_Doze, animated: true, completion: nil)
    }
    
    /// 举报
    static func report_Doze(with isUser: Bool = false, completeBlock: @escaping () -> Void) {
        var reportAlter_Doze: UIAlertController!
        reportAlter_Doze = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
        
        let reportCommon : (UIAlertAction) -> Void = { action in
            completeBlock()
        }
        
        let report1_Doze = UIAlertAction(title: NSLocalizedString("Report Sexually Explicit Material", comment: ""), style: .default,handler: reportCommon)
        let report2_Doze = UIAlertAction(title: NSLocalizedString("Report spam", comment: ""), style: .default,handler: reportCommon)
        let report3_Doze = UIAlertAction(title: NSLocalizedString("Report something else", comment: ""), style: .default,handler: reportCommon)
        let report4_Doze = UIAlertAction(title: NSLocalizedString(isUser ? "Block" : "Report", comment: ""), style: .default,handler: reportCommon)
        let cancel_Doze = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel,handler: nil)
        reportAlter_Doze.addAction(report1_Doze)
        reportAlter_Doze.addAction(report2_Doze)
        reportAlter_Doze.addAction(report3_Doze)
        reportAlter_Doze.addAction(report4_Doze)
        reportAlter_Doze.addAction(cancel_Doze)
        reportAlter_Doze.modalPresentationStyle = .overFullScreen
        UIViewController.currentViewController_Doze()?.present(reportAlter_Doze, animated: true, completion: nil)
    }
}
