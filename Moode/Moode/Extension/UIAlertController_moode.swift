import Foundation
import UIKit

extension UIAlertController {
    
    /// 登出
    static func logout_Moode(completion_Moode: @escaping() -> Void) {
        let alert_Moode = UIAlertController(title: "Prompt", message: "Are you sure you want to log out of the current account?", preferredStyle: .alert)
        let confirm_Moode = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Moode()
        })
        let cancel_Moode = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Moode.addAction(confirm_Moode)
        alert_Moode.addAction(cancel_Moode)
        UIViewController.currentViewController_Moode()?.present(alert_Moode, animated: true, completion: nil)
    }
    
    /// 删除
    static func delete_Moode(completion_Moode: @escaping() -> Void) {
        let alert_Moode = UIAlertController(title: "Prompt", message: "Are you sure you want to delete the current account?", preferredStyle: .alert)
        let confirm_Moode = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Moode()
        })
        let cancel_Moode = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Moode.addAction(confirm_Moode)
        alert_Moode.addAction(cancel_Moode)
        UIViewController.currentViewController_Moode()?.present(alert_Moode, animated: true, completion: nil)
    }
    
    /// 举报
    static func report_Moode(with isUser: Bool = false, completeBlock: @escaping () -> Void) {
        var reportAlter_Moode: UIAlertController!
        reportAlter_Moode = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
        
        let reportCommon : (UIAlertAction) -> Void = { action in
            completeBlock()
        }
        
        let report1_Moode = UIAlertAction(title: NSLocalizedString("Report Sexually Explicit Material", comment: ""), style: .default,handler: reportCommon)
        let report2_Moode = UIAlertAction(title: NSLocalizedString("Report spam", comment: ""), style: .default,handler: reportCommon)
        let report3_Moode = UIAlertAction(title: NSLocalizedString("Report something else", comment: ""), style: .default,handler: reportCommon)
        let report4_Moode = UIAlertAction(title: NSLocalizedString(isUser ? "Block" : "Report", comment: ""), style: .default,handler: reportCommon)
        let cancel_Moode = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel,handler: nil)
        reportAlter_Moode.addAction(report1_Moode)
        reportAlter_Moode.addAction(report2_Moode)
        reportAlter_Moode.addAction(report3_Moode)
        reportAlter_Moode.addAction(report4_Moode)
        reportAlter_Moode.addAction(cancel_Moode)
        reportAlter_Moode.modalPresentationStyle = .overFullScreen
        UIViewController.currentViewController_Moode()?.present(reportAlter_Moode, animated: true, completion: nil)
    }
}
