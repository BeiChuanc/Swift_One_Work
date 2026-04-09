import Foundation
import UIKit

extension UIAlertController {
    
    /// 登出
    static func logout_Tidy(completion_Tidy: @escaping() -> Void) {
        let alert_Tidy = UIAlertController(title: "Prompt", message: "Are you sure you want to log out of the current account?", preferredStyle: .alert)
        let confirm_Tidy = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Tidy()
        })
        let cancel_Tidy = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Tidy.addAction(confirm_Tidy)
        alert_Tidy.addAction(cancel_Tidy)
        UIViewController.currentViewController_Tidy()?.present(alert_Tidy, animated: true, completion: nil)
    }
    
    /// 删除
    static func delete_Tidy(completion_Tidy: @escaping() -> Void) {
        let alert_Tidy = UIAlertController(title: "Prompt", message: "Are you sure you want to delete the current account?", preferredStyle: .alert)
        let confirm_Tidy = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Tidy()
        })
        let cancel_Tidy = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Tidy.addAction(confirm_Tidy)
        alert_Tidy.addAction(cancel_Tidy)
        UIViewController.currentViewController_Tidy()?.present(alert_Tidy, animated: true, completion: nil)
    }
    
    /// 举报
    static func report_Tidy(with isUser: Bool = false, completeBlock: @escaping () -> Void) {
        var reportAlter_Tidy: UIAlertController!
        reportAlter_Tidy = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
        
        let reportCommon : (UIAlertAction) -> Void = { action in
            completeBlock()
        }
        
        let report1_Tidy = UIAlertAction(title: NSLocalizedString("Report Sexually Explicit Material", comment: ""), style: .default,handler: reportCommon)
        let report2_Tidy = UIAlertAction(title: NSLocalizedString("Report spam", comment: ""), style: .default,handler: reportCommon)
        let report3_Tidy = UIAlertAction(title: NSLocalizedString("Report something else", comment: ""), style: .default,handler: reportCommon)
        let report4_Tidy = UIAlertAction(title: NSLocalizedString(isUser ? "Block" : "Report", comment: ""), style: .default,handler: reportCommon)
        let cancel_Tidy = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel,handler: nil)
        reportAlter_Tidy.addAction(report1_Tidy)
        reportAlter_Tidy.addAction(report2_Tidy)
        reportAlter_Tidy.addAction(report3_Tidy)
        reportAlter_Tidy.addAction(report4_Tidy)
        reportAlter_Tidy.addAction(cancel_Tidy)
        UIViewController.currentViewController_Tidy()?.present(reportAlter_Tidy, animated: true, completion: nil)
    }
}
