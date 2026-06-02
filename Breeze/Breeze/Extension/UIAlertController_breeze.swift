import Foundation
import UIKit

extension UIAlertController {
    
    /// 登出
    static func logout_Breeze(completion_Breeze: @escaping() -> Void) {
        let alert_Breeze = UIAlertController(title: "Prompt", message: "Are you sure you want to log out of the current account?", preferredStyle: .alert)
        let confirm_Breeze = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Breeze()
        })
        let cancel_Breeze = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Breeze.addAction(confirm_Breeze)
        alert_Breeze.addAction(cancel_Breeze)
        UIViewController.currentViewController_Breeze()?.present(alert_Breeze, animated: true, completion: nil)
    }
    
    /// 删除
    static func delete_Breeze(completion_Breeze: @escaping() -> Void) {
        let alert_Breeze = UIAlertController(title: "Prompt", message: "Are you sure you want to delete the current account?", preferredStyle: .alert)
        let confirm_Breeze = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Breeze()
        })
        let cancel_Breeze = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Breeze.addAction(confirm_Breeze)
        alert_Breeze.addAction(cancel_Breeze)
        UIViewController.currentViewController_Breeze()?.present(alert_Breeze, animated: true, completion: nil)
    }
    
    /// 举报
    static func report_Breeze(with isUser: Bool = false, completeBlock: @escaping () -> Void) {
        var reportAlter_Breeze: UIAlertController!
        reportAlter_Breeze = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
        
        let reportCommon : (UIAlertAction) -> Void = { action in
            completeBlock()
        }
        
        let report1_Breeze = UIAlertAction(title: NSLocalizedString("Report Sexually Explicit Material", comment: ""), style: .default,handler: reportCommon)
        let report2_Breeze = UIAlertAction(title: NSLocalizedString("Report spam", comment: ""), style: .default,handler: reportCommon)
        let report3_Breeze = UIAlertAction(title: NSLocalizedString("Report something else", comment: ""), style: .default,handler: reportCommon)
        let report4_Breeze = UIAlertAction(title: NSLocalizedString(isUser ? "Block" : "Report", comment: ""), style: .default,handler: reportCommon)
        let cancel_Breeze = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel,handler: nil)
        reportAlter_Breeze.addAction(report1_Breeze)
        reportAlter_Breeze.addAction(report2_Breeze)
        reportAlter_Breeze.addAction(report3_Breeze)
        reportAlter_Breeze.addAction(report4_Breeze)
        reportAlter_Breeze.addAction(cancel_Breeze)
        reportAlter_Breeze.modalPresentationStyle = .overFullScreen
        UIViewController.currentViewController_Breeze()?.present(reportAlter_Breeze, animated: true, completion: nil)
    }
}
