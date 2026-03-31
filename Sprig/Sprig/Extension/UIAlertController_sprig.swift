import Foundation
import UIKit

extension UIAlertController {
    
    /// 登出
    static func logout_Sprig(completion_Sprig: @escaping() -> Void) {
        let alert_Sprig = UIAlertController(title: "Prompt", message: "Are you sure you want to log out of the current account?", preferredStyle: .alert)
        let confirm_Sprig = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Sprig()
        })
        let cancel_Sprig = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Sprig.addAction(confirm_Sprig)
        alert_Sprig.addAction(cancel_Sprig)
        UIViewController.currentViewController_Sprig()?.present(alert_Sprig, animated: true, completion: nil)
    }
    
    /// 删除
    static func delete_Sprig(completion_Sprig: @escaping() -> Void) {
        let alert_Sprig = UIAlertController(title: "Prompt", message: "Are you sure you want to delete the current account?", preferredStyle: .alert)
        let confirm_Sprig = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Sprig()
        })
        let cancel_Sprig = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Sprig.addAction(confirm_Sprig)
        alert_Sprig.addAction(cancel_Sprig)
        UIViewController.currentViewController_Sprig()?.present(alert_Sprig, animated: true, completion: nil)
    }
    
    /// 举报
    static func report_Sprig(with isUser: Bool = false, completeBlock: @escaping () -> Void) {
        var reportAlter_Sprig: UIAlertController!
        reportAlter_Sprig = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
        
        let reportCommon : (UIAlertAction) -> Void = { action in
            completeBlock()
        }
        
        let report1_Sprig = UIAlertAction(title: NSLocalizedString("Report Sexually Explicit Material", comment: ""), style: .default,handler: reportCommon)
        let report2_Sprig = UIAlertAction(title: NSLocalizedString("Report spam", comment: ""), style: .default,handler: reportCommon)
        let report3_Sprig = UIAlertAction(title: NSLocalizedString("Report something else", comment: ""), style: .default,handler: reportCommon)
        let report4_Sprig = UIAlertAction(title: NSLocalizedString(isUser ? "Block" : "Report", comment: ""), style: .default,handler: reportCommon)
        let cancel_Sprig = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel,handler: nil)
        reportAlter_Sprig.addAction(report1_Sprig)
        reportAlter_Sprig.addAction(report2_Sprig)
        reportAlter_Sprig.addAction(report3_Sprig)
        reportAlter_Sprig.addAction(report4_Sprig)
        reportAlter_Sprig.addAction(cancel_Sprig)
        reportAlter_Sprig.modalPresentationStyle = .overFullScreen
        UIViewController.currentViewController_Sprig()?.present(reportAlter_Sprig, animated: true, completion: nil)
    }
}
