import Foundation
import UIKit
import SnapKit

// MARK: - 个人/用户主页帖子网格单元格

/// 个人主页帖子网格单元格
/// 核心作用：在"我的"与"用户中心"页面以统一网格样式展示帖子（方形媒体 + 标题 + 举报/删除）
/// 设计思路：固定高度方形媒体 + 单行标题，统一整齐；举报/删除按钮叠加于媒体右上角
class ProfileGridCell_Breeze: UICollectionViewCell {
    
    /// 复用标识
    static let reuseId_Breeze = "ProfileGridCell_Breeze"
    
    /// 卡片容器
    private let cardView_Breeze: UIView = {
        let view_breeze = UIView()
        view_breeze.backgroundColor = ColorConfig_Breeze.cardBackground_Breeze
        view_breeze.layer.cornerRadius = 14
        view_breeze.layer.shadowColor = ColorConfig_Breeze.shadowColor_Breeze.cgColor
        view_breeze.layer.shadowOffset = CGSize(width: 0, height: 4)
        view_breeze.layer.shadowRadius = 8
        view_breeze.layer.shadowOpacity = 0.10
        return view_breeze
    }()
    
    /// 媒体裁剪容器
    private let mediaContainer_Breeze: UIView = {
        let view_breeze = UIView()
        view_breeze.layer.cornerRadius = 14
        view_breeze.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view_breeze.clipsToBounds = true
        return view_breeze
    }()
    
    /// 媒体展示
    private let mediaView_Breeze = MediaDisplayView_Breeze()
    
    /// 标题
    private let titleLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label_breeze.textColor = ColorConfig_Breeze.textPrimary_Breeze
        label_breeze.numberOfLines = 2
        return label_breeze
    }()
    
    /// 举报/删除按钮容器
    private let reportButtonContainer_Breeze: UIView = {
        let view_breeze = UIView()
        view_breeze.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        view_breeze.layer.cornerRadius = 14
        return view_breeze
    }()
    private var reportButton_Breeze: UIButton?
    
    /// 操作完成回调
    var onReportComplete_Breeze: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Breeze()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI_Breeze() {
        contentView.addSubview(cardView_Breeze)
        cardView_Breeze.addSubview(mediaContainer_Breeze)
        mediaContainer_Breeze.addSubview(mediaView_Breeze)
        cardView_Breeze.addSubview(reportButtonContainer_Breeze)
        cardView_Breeze.addSubview(titleLabel_Breeze)
        
        cardView_Breeze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        mediaContainer_Breeze.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(mediaContainer_Breeze.snp.width)
        }
        mediaView_Breeze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        reportButtonContainer_Breeze.snp.makeConstraints { make in
            make.top.equalTo(mediaContainer_Breeze).offset(6)
            make.right.equalTo(mediaContainer_Breeze).offset(-6)
            make.width.height.equalTo(28)
        }
        titleLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(mediaContainer_Breeze.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(10)
            make.bottom.lessThanOrEqualToSuperview().offset(-8)
        }
    }
    
    /// 配置网格帖子
    /// - Parameters:
    ///   - post_breeze: 帖子模型
    ///   - host_breeze: 宿主控制器（举报/删除弹窗使用）
    func configure_Breeze(post_breeze: TitleModel_Breeze, host_breeze: UIViewController) {
        titleLabel_Breeze.text = post_breeze.title_Breeze
        mediaView_Breeze.configure_Breeze(mediaPath_Breeze: post_breeze.titleMeidas_Breeze.first)
        
        reportButton_Breeze?.removeFromSuperview()
        let button_breeze = ReportDeleteHelper_Breeze.createPostReportButton_Breeze(
            post_Breeze: post_breeze,
            size_Breeze: 14,
            color_Breeze: .white,
            from: host_breeze
        ) { [weak self] in
            self?.onReportComplete_Breeze?()
        }
        reportButtonContainer_Breeze.addSubview(button_breeze)
        button_breeze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        reportButton_Breeze = button_breeze
    }
    
    /// 网格单元格高度（方形媒体 + 文本区）
    static func cellHeight_Breeze(width_breeze: CGFloat) -> CGFloat {
        return width_breeze + 50
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reportButton_Breeze?.removeFromSuperview()
        reportButton_Breeze = nil
        onReportComplete_Breeze = nil
    }
}
