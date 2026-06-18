import Foundation
import UIKit

extension UIAlertController {
    
    /// 登出
    static func logout_Sylva(completion_Sylva: @escaping() -> Void) {
        let alert_Sylva = UIAlertController(title: "Prompt", message: "Are you sure you want to log out of the current account?", preferredStyle: .alert)
        let confirm_Sylva = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Sylva()
        })
        let cancel_Sylva = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Sylva.addAction(confirm_Sylva)
        alert_Sylva.addAction(cancel_Sylva)
        UIViewController.currentViewController_Sylva()?.present(alert_Sylva, animated: true, completion: nil)
    }
    
    /// 删除
    static func delete_Sylva(completion_Sylva: @escaping() -> Void) {
        let alert_Sylva = UIAlertController(title: "Prompt", message: "Are you sure you want to delete the current account?", preferredStyle: .alert)
        let confirm_Sylva = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Sylva()
        })
        let cancel_Sylva = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Sylva.addAction(confirm_Sylva)
        alert_Sylva.addAction(cancel_Sylva)
        UIViewController.currentViewController_Sylva()?.present(alert_Sylva, animated: true, completion: nil)
    }
    
    /// 举报
    static func report_Sylva(with isUser: Bool = false, completeBlock: @escaping () -> Void) {
        var reportAlter_Sylva: UIAlertController!
        reportAlter_Sylva = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
        
        let reportCommon : (UIAlertAction) -> Void = { action in
            completeBlock()
        }
        
        let report1_Sylva = UIAlertAction(title: NSLocalizedString("Report Sexually Explicit Material", comment: ""), style: .default,handler: reportCommon)
        let report2_Sylva = UIAlertAction(title: NSLocalizedString("Report spam", comment: ""), style: .default,handler: reportCommon)
        let report3_Sylva = UIAlertAction(title: NSLocalizedString("Report something else", comment: ""), style: .default,handler: reportCommon)
        let report4_Sylva = UIAlertAction(title: NSLocalizedString(isUser ? "Block" : "Report", comment: ""), style: .default,handler: reportCommon)
        let cancel_Sylva = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel,handler: nil)
        reportAlter_Sylva.addAction(report1_Sylva)
        reportAlter_Sylva.addAction(report2_Sylva)
        reportAlter_Sylva.addAction(report3_Sylva)
        reportAlter_Sylva.addAction(report4_Sylva)
        reportAlter_Sylva.addAction(cancel_Sylva)
        reportAlter_Sylva.modalPresentationStyle = .overFullScreen
        UIViewController.currentViewController_Sylva()?.present(reportAlter_Sylva, animated: true, completion: nil)
    }
}
