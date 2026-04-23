import Foundation
import UIKit

extension UIAlertController {
    
    /// 登出
    static func logout_Nest(completion_Nest: @escaping() -> Void) {
        let alert_Nest = UIAlertController(title: "Prompt", message: "Are you sure you want to log out of the current account?", preferredStyle: .alert)
        let confirm_Nest = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Nest()
        })
        let cancel_Nest = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Nest.addAction(confirm_Nest)
        alert_Nest.addAction(cancel_Nest)
        UIViewController.currentViewController_Nest()?.present(alert_Nest, animated: true, completion: nil)
    }
    
    /// 删除
    static func delete_Nest(completion_Nest: @escaping() -> Void) {
        let alert_Nest = UIAlertController(title: "Prompt", message: "Are you sure you want to delete the current account?", preferredStyle: .alert)
        let confirm_Nest = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Nest()
        })
        let cancel_Nest = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Nest.addAction(confirm_Nest)
        alert_Nest.addAction(cancel_Nest)
        UIViewController.currentViewController_Nest()?.present(alert_Nest, animated: true, completion: nil)
    }
    
    /// 举报
    static func report_Nest(with isUser: Bool = false, completeBlock: @escaping () -> Void) {
        var reportAlter_Nest: UIAlertController!
        reportAlter_Nest = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
        
        let reportCommon : (UIAlertAction) -> Void = { action in
            completeBlock()
        }
        
        let report1_Nest = UIAlertAction(title: NSLocalizedString("Report Sexually Explicit Material", comment: ""), style: .default,handler: reportCommon)
        let report2_Nest = UIAlertAction(title: NSLocalizedString("Report spam", comment: ""), style: .default,handler: reportCommon)
        let report3_Nest = UIAlertAction(title: NSLocalizedString("Report something else", comment: ""), style: .default,handler: reportCommon)
        let report4_Nest = UIAlertAction(title: NSLocalizedString(isUser ? "Block" : "Report", comment: ""), style: .default,handler: reportCommon)
        let cancel_Nest = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel,handler: nil)
        reportAlter_Nest.addAction(report1_Nest)
        reportAlter_Nest.addAction(report2_Nest)
        reportAlter_Nest.addAction(report3_Nest)
        reportAlter_Nest.addAction(report4_Nest)
        reportAlter_Nest.addAction(cancel_Nest)
        reportAlter_Nest.modalPresentationStyle = .overFullScreen
        UIViewController.currentViewController_Nest()?.present(reportAlter_Nest, animated: true, completion: nil)
    }
}
