import Foundation
import UIKit

extension UIAlertController {
    
    /// 登出
    static func logout_Echd(completion_Echd: @escaping() -> Void) {
        let alert_Echd = UIAlertController(title: "Prompt", message: "Are you sure you want to log out of the current account?", preferredStyle: .alert)
        let confirm_Echd = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Echd()
        })
        let cancel_Echd = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Echd.addAction(confirm_Echd)
        alert_Echd.addAction(cancel_Echd)
        UIViewController.currentViewController_Echd()?.present(alert_Echd, animated: true, completion: nil)
    }
    
    /// 删除
    static func delete_Echd(completion_Echd: @escaping() -> Void) {
        let alert_Echd = UIAlertController(title: "Prompt", message: "Are you sure you want to delete the current account?", preferredStyle: .alert)
        let confirm_Echd = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Echd()
        })
        let cancel_Echd = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Echd.addAction(confirm_Echd)
        alert_Echd.addAction(cancel_Echd)
        UIViewController.currentViewController_Echd()?.present(alert_Echd, animated: true, completion: nil)
    }
    
    /// 举报
    static func report_Echd(with isUser: Bool = false, completeBlock: @escaping () -> Void) {
        var reportAlter_Echd: UIAlertController!
        reportAlter_Echd = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
        
        let reportCommon : (UIAlertAction) -> Void = { action in
            completeBlock()
        }
        
        let report1_Echd = UIAlertAction(title: NSLocalizedString("Report Sexually Explicit Material", comment: ""), style: .default,handler: reportCommon)
        let report2_Echd = UIAlertAction(title: NSLocalizedString("Report spam", comment: ""), style: .default,handler: reportCommon)
        let report3_Echd = UIAlertAction(title: NSLocalizedString("Report something else", comment: ""), style: .default,handler: reportCommon)
        let report4_Echd = UIAlertAction(title: NSLocalizedString(isUser ? "Block" : "Report", comment: ""), style: .default,handler: reportCommon)
        let cancel_Echd = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel,handler: nil)
        reportAlter_Echd.addAction(report1_Echd)
        reportAlter_Echd.addAction(report2_Echd)
        reportAlter_Echd.addAction(report3_Echd)
        reportAlter_Echd.addAction(report4_Echd)
        reportAlter_Echd.addAction(cancel_Echd)
        reportAlter_Echd.modalPresentationStyle = .overFullScreen
        UIViewController.currentViewController_Echd()?.present(reportAlter_Echd, animated: true, completion: nil)
    }
}
