import Foundation
import UIKit

extension UIAlertController {
    
    /// 登出
    static func logout_Maki(completion_Maki: @escaping() -> Void) {
        let alert_Maki = UIAlertController(title: "Prompt", message: "Are you sure you want to log out of the current account?", preferredStyle: .alert)
        let confirm_Maki = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Maki()
        })
        let cancel_Maki = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Maki.addAction(confirm_Maki)
        alert_Maki.addAction(cancel_Maki)
        UIViewController.currentViewController_Maki()?.present(alert_Maki, animated: true, completion: nil)
    }
    
    /// 删除
    static func delete_Maki(completion_Maki: @escaping() -> Void) {
        let alert_Maki = UIAlertController(title: "Prompt", message: "Are you sure you want to delete the current account?", preferredStyle: .alert)
        let confirm_Maki = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Maki()
        })
        let cancel_Maki = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Maki.addAction(confirm_Maki)
        alert_Maki.addAction(cancel_Maki)
        UIViewController.currentViewController_Maki()?.present(alert_Maki, animated: true, completion: nil)
    }
    
    /// 举报
    static func report_Maki(with isUser: Bool = false, completeBlock: @escaping () -> Void) {
        var reportAlter_Maki: UIAlertController!
        reportAlter_Maki = UIAlertController(title: "Report", message: nil, preferredStyle: .actionSheet)
        
        let reportCommon : (UIAlertAction) -> Void = { action in
            completeBlock()
        }
        
        let report1_Maki = UIAlertAction(title: NSLocalizedString("Report Sexually Explicit Material", comment: ""), style: .default,handler: reportCommon)
        let report2_Maki = UIAlertAction(title: NSLocalizedString("Report spam", comment: ""), style: .default,handler: reportCommon)
        let report3_Maki = UIAlertAction(title: NSLocalizedString("Report something else", comment: ""), style: .default,handler: reportCommon)
        let report4_Maki = UIAlertAction(title: NSLocalizedString("Report", comment: ""), style: .default,handler: reportCommon)
        let report5_Maki = UIAlertAction(title: NSLocalizedString("Block", comment: ""), style: .default,handler: reportCommon)
        let cancel_Maki = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel,handler: nil)
        reportAlter_Maki.addAction(report1_Maki)
        reportAlter_Maki.addAction(report2_Maki)
        reportAlter_Maki.addAction(report3_Maki)
        reportAlter_Maki.addAction(report4_Maki)
        reportAlter_Maki.addAction(report5_Maki)
        reportAlter_Maki.addAction(cancel_Maki)
        reportAlter_Maki.modalPresentationStyle = .overFullScreen
        UIViewController.currentViewController_Maki()?.present(reportAlter_Maki, animated: true, completion: nil)
    }
}
