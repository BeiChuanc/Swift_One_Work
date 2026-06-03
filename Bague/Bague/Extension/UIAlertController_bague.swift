import Foundation
import UIKit

extension UIAlertController {
    
    /// 登出
    static func logout_Bague(completion_Bague: @escaping() -> Void) {
        let alert_Bague = UIAlertController(title: "Prompt", message: "Are you sure you want to log out of the current account?", preferredStyle: .alert)
        let confirm_Bague = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Bague()
        })
        let cancel_Bague = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Bague.addAction(confirm_Bague)
        alert_Bague.addAction(cancel_Bague)
        UIViewController.currentViewController_Bague()?.present(alert_Bague, animated: true, completion: nil)
    }
    
    /// 删除
    static func delete_Bague(completion_Bague: @escaping() -> Void) {
        let alert_Bague = UIAlertController(title: "Prompt", message: "Are you sure you want to delete the current account?", preferredStyle: .alert)
        let confirm_Bague = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Bague()
        })
        let cancel_Bague = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Bague.addAction(confirm_Bague)
        alert_Bague.addAction(cancel_Bague)
        UIViewController.currentViewController_Bague()?.present(alert_Bague, animated: true, completion: nil)
    }
    
    /// 举报
    static func report_Bague(with isUser: Bool = false, completeBlock: @escaping () -> Void) {
        var reportAlter_Bague: UIAlertController!
        reportAlter_Bague = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
        
        let reportCommon : (UIAlertAction) -> Void = { action in
            completeBlock()
        }
        
        let report1_Bague = UIAlertAction(title: NSLocalizedString("Report Sexually Explicit Material", comment: ""), style: .default,handler: reportCommon)
        let report2_Bague = UIAlertAction(title: NSLocalizedString("Report spam", comment: ""), style: .default,handler: reportCommon)
        let report3_Bague = UIAlertAction(title: NSLocalizedString("Report something else", comment: ""), style: .default,handler: reportCommon)
        let report4_Bague = UIAlertAction(title: NSLocalizedString(isUser ? "Block" : "Report", comment: ""), style: .default,handler: reportCommon)
        let cancel_Bague = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel,handler: nil)
        reportAlter_Bague.addAction(report1_Bague)
        reportAlter_Bague.addAction(report2_Bague)
        reportAlter_Bague.addAction(report3_Bague)
        reportAlter_Bague.addAction(report4_Bague)
        reportAlter_Bague.addAction(cancel_Bague)
        reportAlter_Bague.modalPresentationStyle = .overFullScreen
        UIViewController.currentViewController_Bague()?.present(reportAlter_Bague, animated: true, completion: nil)
    }
}
