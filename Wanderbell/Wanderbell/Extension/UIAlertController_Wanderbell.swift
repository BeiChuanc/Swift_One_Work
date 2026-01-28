import Foundation
import UIKit

extension UIAlertController {
    
    /// 登出
    static func logout_Wanderbell(completion_Wanderbell: @escaping() -> Void) {
        let alert_Wanderbell = UIAlertController(title: "Prompt", message: "Are you sure you want to log out of the current account?", preferredStyle: .alert)
        let confirm_Wanderbell = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Wanderbell()
        })
        let cancel_Wanderbell = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Wanderbell.addAction(confirm_Wanderbell)
        alert_Wanderbell.addAction(cancel_Wanderbell)
        UIViewController.currentViewController_Wanderbell()?.present(alert_Wanderbell, animated: true, completion: nil)
    }
    
    /// 删除
    static func delete_Wanderbell(completion_Wanderbell: @escaping() -> Void) {
        let alert_Wanderbell = UIAlertController(title: "Prompt", message: "Are you sure you want to delete the current account?", preferredStyle: .alert)
        let confirm_Wanderbell = UIAlertAction(title: "Confirm", style: .default, handler: { Action in
            completion_Wanderbell()
        })
        let cancel_Wanderbell = UIAlertAction(title: "Cancel", style: .cancel)
        alert_Wanderbell.addAction(confirm_Wanderbell)
        alert_Wanderbell.addAction(cancel_Wanderbell)
        UIViewController.currentViewController_Wanderbell()?.present(alert_Wanderbell, animated: true, completion: nil)
    }
    
    /// 举报
    static func report_Wanderbell(Id: Int, completeBlock: @escaping () -> Void) {
        var reportAlter_Wanderbell: UIAlertController!
        reportAlter_Wanderbell = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
        
        let reportCommon : (UIAlertAction) -> Void = { action in
            completeBlock()
        }
        
        let report1_Wanderbell = UIAlertAction(title: NSLocalizedString("Report Sexually Explicit Material", comment: ""), style: .default,handler: reportCommon)
        let report2_Wanderbell = UIAlertAction(title: NSLocalizedString("Report spam", comment: ""), style: .default,handler: reportCommon)
        let report3_Wanderbell = UIAlertAction(title: NSLocalizedString("Report something else", comment: ""), style: .default,handler: reportCommon)
        let report4_Wanderbell = UIAlertAction(title: NSLocalizedString("Block", comment: ""), style: .default,handler: reportCommon)
        let cancel_Wanderbell = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel,handler: nil)
        reportAlter_Wanderbell.addAction(report1_Wanderbell)
        reportAlter_Wanderbell.addAction(report2_Wanderbell)
        reportAlter_Wanderbell.addAction(report3_Wanderbell)
        reportAlter_Wanderbell.addAction(report4_Wanderbell)
        reportAlter_Wanderbell.addAction(cancel_Wanderbell)
        reportAlter_Wanderbell.modalPresentationStyle = .overFullScreen
        UIViewController.currentViewController_Wanderbell()?.present(reportAlter_Wanderbell, animated: true, completion: nil)
    }
    
    /// 全局提示
    static func globalTips_Wanderbell(tips_Wanderbell: String) {
        var tipsAlter_Wanderbell: UIAlertController!
        tipsAlter_Wanderbell = UIAlertController(title: nil, message: tips_Wanderbell, preferredStyle: .alert)
        let onAction_Wanderbell = UIAlertAction(title: "OK", style: .default, handler: nil)
        tipsAlter_Wanderbell.addAction(onAction_Wanderbell)
        UIViewController.currentViewController_Wanderbell()?.present(tipsAlter_Wanderbell, animated: true, completion: nil)
    }
}
