import Foundation
import UIKit

extension UIAlertController {
    
    /// 登出
    static func logout_Niche(completion_Niche: @escaping() -> Void) {
        let alert_Niche = UIAlertController(title: "Prompt", message: "Are you sure you want to log out of the current account?", preferredStyle: .alert)
        let confirm_Niche = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Niche()
        })
        let cancel_Niche = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Niche.addAction(confirm_Niche)
        alert_Niche.addAction(cancel_Niche)
        UIViewController.currentViewController_Niche()?.present(alert_Niche, animated: true, completion: nil)
    }
    
    /// 删除
    static func delete_Niche(completion_Niche: @escaping() -> Void) {
        let alert_Niche = UIAlertController(title: "Prompt", message: "Are you sure you want to delete the current account?", preferredStyle: .alert)
        let confirm_Niche = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Niche()
        })
        let cancel_Niche = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Niche.addAction(confirm_Niche)
        alert_Niche.addAction(cancel_Niche)
        UIViewController.currentViewController_Niche()?.present(alert_Niche, animated: true, completion: nil)
    }
    
    /// 举报
    static func report_Niche(with isUser: Bool = false, completeBlock: @escaping () -> Void) {
        var reportAlter_Niche: UIAlertController!
        reportAlter_Niche = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
        
        let reportCommon : (UIAlertAction) -> Void = { action in
            completeBlock()
        }
        
        let report1_Niche = UIAlertAction(title: NSLocalizedString("Report Sexually Explicit Material", comment: ""), style: .default,handler: reportCommon)
        let report2_Niche = UIAlertAction(title: NSLocalizedString("Report spam", comment: ""), style: .default,handler: reportCommon)
        let report3_Niche = UIAlertAction(title: NSLocalizedString("Report something else", comment: ""), style: .default,handler: reportCommon)
        let report4_Niche = UIAlertAction(title: NSLocalizedString(isUser ? "Block" : "Report", comment: ""), style: .default,handler: reportCommon)
        let cancel_Niche = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel,handler: nil)
        reportAlter_Niche.addAction(report1_Niche)
        reportAlter_Niche.addAction(report2_Niche)
        reportAlter_Niche.addAction(report3_Niche)
        reportAlter_Niche.addAction(report4_Niche)
        reportAlter_Niche.addAction(cancel_Niche)
        reportAlter_Niche.modalPresentationStyle = .overFullScreen
        UIViewController.currentViewController_Niche()?.present(reportAlter_Niche, animated: true, completion: nil)
    }
}
