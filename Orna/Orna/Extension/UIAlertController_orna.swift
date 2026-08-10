import Foundation
import UIKit

extension UIAlertController {
    
    /// 登出
    static func logout_Orna(completion_Orna: @escaping() -> Void) {
        let alert_Orna = UIAlertController(title: "Prompt", message: "Are you sure you want to log out of the current account?", preferredStyle: .alert)
        let confirm_Orna = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Orna()
        })
        let cancel_Orna = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Orna.addAction(confirm_Orna)
        alert_Orna.addAction(cancel_Orna)
        UIViewController.currentViewController_Orna()?.present(alert_Orna, animated: true, completion: nil)
    }
    
    /// 删除
    static func delete_Orna(completion_Orna: @escaping() -> Void) {
        let alert_Orna = UIAlertController(title: "Prompt", message: "Are you sure you want to delete the current account?", preferredStyle: .alert)
        let confirm_Orna = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Orna()
        })
        let cancel_Orna = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Orna.addAction(confirm_Orna)
        alert_Orna.addAction(cancel_Orna)
        UIViewController.currentViewController_Orna()?.present(alert_Orna, animated: true, completion: nil)
    }
    
    /// 举报
    static func report_Orna(with isUser: Bool = false, completeBlock: @escaping () -> Void) {
        var reportAlter_Orna: UIAlertController!
        reportAlter_Orna = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
        
        let reportCommon : (UIAlertAction) -> Void = { action in
            completeBlock()
        }
        
        let report1_Orna = UIAlertAction(title: NSLocalizedString("Report Sexually Explicit Material", comment: ""), style: .default,handler: reportCommon)
        let report2_Orna = UIAlertAction(title: NSLocalizedString("Report spam", comment: ""), style: .default,handler: reportCommon)
        let report3_Orna = UIAlertAction(title: NSLocalizedString("Report something else", comment: ""), style: .default,handler: reportCommon)
        let report4_Orna = UIAlertAction(title: NSLocalizedString("Block", comment: ""), style: .default,handler: reportCommon)
        let report5_Orna = UIAlertAction(title: NSLocalizedString("Report", comment: ""), style: .default,handler: reportCommon)
        let cancel_Orna = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel,handler: nil)
        reportAlter_Orna.addAction(report1_Orna)
        reportAlter_Orna.addAction(report2_Orna)
        reportAlter_Orna.addAction(report3_Orna)
        reportAlter_Orna.addAction(report4_Orna)
        reportAlter_Orna.addAction(report5_Orna)
        reportAlter_Orna.addAction(cancel_Orna)
        reportAlter_Orna.modalPresentationStyle = .overFullScreen
        UIViewController.currentViewController_Orna()?.present(reportAlter_Orna, animated: true, completion: nil)
    }
}
