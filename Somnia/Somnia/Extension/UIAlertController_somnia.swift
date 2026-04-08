import Foundation
import UIKit

extension UIAlertController {
    
    /// 登出
    static func logout_Somnia(completion_Somnia: @escaping() -> Void) {
        let alert_Somnia = UIAlertController(title: "Prompt", message: "Are you sure you want to log out of the current account?", preferredStyle: .alert)
        let confirm_Somnia = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Somnia()
        })
        let cancel_Somnia = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Somnia.addAction(confirm_Somnia)
        alert_Somnia.addAction(cancel_Somnia)
        UIViewController.currentViewController_Somnia()?.present(alert_Somnia, animated: true, completion: nil)
    }
    
    /// 删除
    static func delete_Somnia(completion_Somnia: @escaping() -> Void) {
        let alert_Somnia = UIAlertController(title: "Prompt", message: "Are you sure you want to delete the current account?", preferredStyle: .alert)
        let confirm_Somnia = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Somnia()
        })
        let cancel_Somnia = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Somnia.addAction(confirm_Somnia)
        alert_Somnia.addAction(cancel_Somnia)
        UIViewController.currentViewController_Somnia()?.present(alert_Somnia, animated: true, completion: nil)
    }
    
    /// 举报
    static func report_Somnia(with isUser: Bool = false, completeBlock: @escaping () -> Void) {
        var reportAlter_Somnia: UIAlertController!
        reportAlter_Somnia = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
        
        let reportCommon : (UIAlertAction) -> Void = { action in
            completeBlock()
        }
        
        let report1_Somnia = UIAlertAction(title: NSLocalizedString("Report Sexually Explicit Material", comment: ""), style: .default,handler: reportCommon)
        let report2_Somnia = UIAlertAction(title: NSLocalizedString("Report spam", comment: ""), style: .default,handler: reportCommon)
        let report3_Somnia = UIAlertAction(title: NSLocalizedString("Report something else", comment: ""), style: .default,handler: reportCommon)
        let report4_Somnia = UIAlertAction(title: NSLocalizedString(isUser ? "Block" : "Report", comment: ""), style: .default,handler: reportCommon)
        let cancel_Somnia = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel,handler: nil)
        reportAlter_Somnia.addAction(report1_Somnia)
        reportAlter_Somnia.addAction(report2_Somnia)
        reportAlter_Somnia.addAction(report3_Somnia)
        reportAlter_Somnia.addAction(report4_Somnia)
        reportAlter_Somnia.addAction(cancel_Somnia)
        reportAlter_Somnia.modalPresentationStyle = .overFullScreen
        UIViewController.currentViewController_Somnia()?.present(reportAlter_Somnia, animated: true, completion: nil)
    }
}
