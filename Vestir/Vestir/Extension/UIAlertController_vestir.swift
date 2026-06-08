import Foundation
import UIKit

extension UIAlertController {
    
    /// 登出
    static func logout_Vestir(completion_Vestir: @escaping() -> Void) {
        let alert_Vestir = UIAlertController(title: "Prompt", message: "Are you sure you want to log out of the current account?", preferredStyle: .alert)
        let confirm_Vestir = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Vestir()
        })
        let cancel_Vestir = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Vestir.addAction(confirm_Vestir)
        alert_Vestir.addAction(cancel_Vestir)
        UIViewController.currentViewController_Vestir()?.present(alert_Vestir, animated: true, completion: nil)
    }
    
    /// 删除
    static func delete_Vestir(completion_Vestir: @escaping() -> Void) {
        let alert_Vestir = UIAlertController(title: "Prompt", message: "Are you sure you want to delete the current account?", preferredStyle: .alert)
        let confirm_Vestir = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Vestir()
        })
        let cancel_Vestir = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Vestir.addAction(confirm_Vestir)
        alert_Vestir.addAction(cancel_Vestir)
        UIViewController.currentViewController_Vestir()?.present(alert_Vestir, animated: true, completion: nil)
    }
    
    /// 举报
    static func report_Vestir(with isUser: Bool = false, completeBlock: @escaping () -> Void) {
        var reportAlter_Vestir: UIAlertController!
        reportAlter_Vestir = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
        
        let reportCommon : (UIAlertAction) -> Void = { action in
            completeBlock()
        }
        
        let report1_Vestir = UIAlertAction(title: NSLocalizedString("Report Sexually Explicit Material", comment: ""), style: .default,handler: reportCommon)
        let report2_Vestir = UIAlertAction(title: NSLocalizedString("Report spam", comment: ""), style: .default,handler: reportCommon)
        let report3_Vestir = UIAlertAction(title: NSLocalizedString("Report something else", comment: ""), style: .default,handler: reportCommon)
        let report4_Vestir = UIAlertAction(title: NSLocalizedString(isUser ? "Block" : "Report", comment: ""), style: .default,handler: reportCommon)
        let cancel_Vestir = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel,handler: nil)
        reportAlter_Vestir.addAction(report1_Vestir)
        reportAlter_Vestir.addAction(report2_Vestir)
        reportAlter_Vestir.addAction(report3_Vestir)
        reportAlter_Vestir.addAction(report4_Vestir)
        reportAlter_Vestir.addAction(cancel_Vestir)
        reportAlter_Vestir.modalPresentationStyle = .overFullScreen
        UIViewController.currentViewController_Vestir()?.present(reportAlter_Vestir, animated: true, completion: nil)
    }
}
