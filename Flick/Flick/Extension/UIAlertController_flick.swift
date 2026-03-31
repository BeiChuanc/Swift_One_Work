import Foundation
import UIKit

extension UIAlertController {
    
    /// 登出
    static func logout_Flick(completion_Flick: @escaping() -> Void) {
        let alert_Flick = UIAlertController(title: "Prompt", message: "Are you sure you want to log out of the current account?", preferredStyle: .alert)
        let confirm_Flick = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Flick()
        })
        let cancel_Flick = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Flick.addAction(confirm_Flick)
        alert_Flick.addAction(cancel_Flick)
        UIViewController.currentViewController_Flick()?.present(alert_Flick, animated: true, completion: nil)
    }
    
    /// 删除
    static func delete_Flick(completion_Flick: @escaping() -> Void) {
        let alert_Flick = UIAlertController(title: "Prompt", message: "Are you sure you want to delete the current account?", preferredStyle: .alert)
        let confirm_Flick = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Flick()
        })
        let cancel_Flick = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Flick.addAction(confirm_Flick)
        alert_Flick.addAction(cancel_Flick)
        UIViewController.currentViewController_Flick()?.present(alert_Flick, animated: true, completion: nil)
    }
    
    /// 举报
    static func report_Flick(with isUser: Bool = false, completeBlock: @escaping () -> Void) {
        var reportAlter_Flick: UIAlertController!
        reportAlter_Flick = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
        
        let reportCommon : (UIAlertAction) -> Void = { action in
            completeBlock()
        }
        
        let report1_Flick = UIAlertAction(title: NSLocalizedString("Report Sexually Explicit Material", comment: ""), style: .default,handler: reportCommon)
        let report2_Flick = UIAlertAction(title: NSLocalizedString("Report spam", comment: ""), style: .default,handler: reportCommon)
        let report3_Flick = UIAlertAction(title: NSLocalizedString("Report something else", comment: ""), style: .default,handler: reportCommon)
        let report4_Flick = UIAlertAction(title: NSLocalizedString(isUser ? "Block" : "Report", comment: ""), style: .default,handler: reportCommon)
        let cancel_Flick = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel,handler: nil)
        reportAlter_Flick.addAction(report1_Flick)
        reportAlter_Flick.addAction(report2_Flick)
        reportAlter_Flick.addAction(report3_Flick)
        reportAlter_Flick.addAction(report4_Flick)
        reportAlter_Flick.addAction(cancel_Flick)
        reportAlter_Flick.modalPresentationStyle = .overFullScreen
        UIViewController.currentViewController_Flick()?.present(reportAlter_Flick, animated: true, completion: nil)
    }
}
