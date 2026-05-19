import Foundation
import UIKit

extension UIAlertController {
    
    /// 登出
    static func logout_Lumia(completion_Lumia: @escaping() -> Void) {
        let alert_Lumia = UIAlertController(title: "Prompt", message: "Are you sure you want to log out of the current account?", preferredStyle: .alert)
        let confirm_Lumia = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Lumia()
        })
        let cancel_Lumia = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Lumia.addAction(confirm_Lumia)
        alert_Lumia.addAction(cancel_Lumia)
        UIViewController.currentViewController_Lumia()?.present(alert_Lumia, animated: true, completion: nil)
    }
    
    /// 删除
    static func delete_Lumia(completion_Lumia: @escaping() -> Void) {
        let alert_Lumia = UIAlertController(title: "Prompt", message: "Are you sure you want to delete the current account?", preferredStyle: .alert)
        let confirm_Lumia = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Lumia()
        })
        let cancel_Lumia = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Lumia.addAction(confirm_Lumia)
        alert_Lumia.addAction(cancel_Lumia)
        UIViewController.currentViewController_Lumia()?.present(alert_Lumia, animated: true, completion: nil)
    }
    
    /// 举报
    static func report_Lumia(with isUser: Bool = false, completeBlock: @escaping () -> Void) {
        var reportAlter_Lumia: UIAlertController!
        reportAlter_Lumia = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
        
        let reportCommon : (UIAlertAction) -> Void = { action in
            completeBlock()
        }
        
        let report1_Lumia = UIAlertAction(title: NSLocalizedString("Report Sexually Explicit Material", comment: ""), style: .default,handler: reportCommon)
        let report2_Lumia = UIAlertAction(title: NSLocalizedString("Report spam", comment: ""), style: .default,handler: reportCommon)
        let report3_Lumia = UIAlertAction(title: NSLocalizedString("Report something else", comment: ""), style: .default,handler: reportCommon)
        let report4_Lumia = UIAlertAction(title: NSLocalizedString(isUser ? "Block" : "Report", comment: ""), style: .default,handler: reportCommon)
        let cancel_Lumia = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel,handler: nil)
        reportAlter_Lumia.addAction(report1_Lumia)
        reportAlter_Lumia.addAction(report2_Lumia)
        reportAlter_Lumia.addAction(report3_Lumia)
        reportAlter_Lumia.addAction(report4_Lumia)
        reportAlter_Lumia.addAction(cancel_Lumia)
        reportAlter_Lumia.modalPresentationStyle = .overFullScreen
        UIViewController.currentViewController_Lumia()?.present(reportAlter_Lumia, animated: true, completion: nil)
    }
}
