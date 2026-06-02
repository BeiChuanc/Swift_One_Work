import Foundation
import UIKit
import SnapKit

// MARK: - 帖子卡片单元格组件

/// 帖子卡片单元格
/// 核心作用：在瀑布流中展示一条帖子——媒体图 + 底部渐变遮罩 + 分类徽章 + 标题 + 内容 + 底部作者栏
/// 设计思路：图片底部叠加深色渐变提升视觉层次；分类徽章浮于图片左上角；底部作者行含头像、昵称、点赞数
/// 关键属性：mediaView_Breeze 媒体展示、categoryBadge_Breeze 分类徽章、onReportComplete_Breeze 操作回调
class PostCardCell_Breeze: UICollectionViewCell {
    
    /// 复用标识
    static let reuseId_Breeze = "PostCardCell_Breeze"
    
    // MARK: - UI 组件：卡片容器
    
    /// 卡片容器（圆角阴影）
    private let cardView_Breeze: UIView = {
        let view_breeze = UIView()
        view_breeze.backgroundColor = ColorConfig_Breeze.cardBackground_Breeze
        view_breeze.layer.cornerRadius = 20
        view_breeze.layer.shadowColor = ColorConfig_Breeze.shadowColor_Breeze.cgColor
        view_breeze.layer.shadowOffset = CGSize(width: 0, height: 6)
        view_breeze.layer.shadowRadius = 14
        view_breeze.layer.shadowOpacity = 0.14
        return view_breeze
    }()
    
    // MARK: - UI 组件：媒体区
    
    /// 媒体裁剪容器（顶部圆角）
    private let mediaContainer_Breeze: UIView = {
        let view_breeze = UIView()
        view_breeze.layer.cornerRadius = 20
        view_breeze.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view_breeze.clipsToBounds = true
        return view_breeze
    }()
    
    /// 媒体展示视图
    private let mediaView_Breeze = MediaDisplayView_Breeze()
    
    /// 图片底部渐变遮罩（透明 → 半透黑，提升视觉层次）
    private let imageOverlayView_Breeze: UIView = {
        let view_breeze = UIView()
        view_breeze.isUserInteractionEnabled = false
        return view_breeze
    }()
    
    /// 底部渐变图层（懒创建，布局完成后赋值）
    private var overlayGradientLayer_Breeze: CAGradientLayer?
    
    // MARK: - UI 组件：分类徽章
    
    /// 分类徽章容器（渐变背景胶囊）
    private let categoryBadge_Breeze: UIView = {
        let view_breeze = UIView()
        view_breeze.layer.cornerRadius = 11
        view_breeze.clipsToBounds = true
        return view_breeze
    }()
    
    /// 分类徽章渐变图层
    private var badgeGradientLayer_Breeze: CAGradientLayer?
    
    /// 分类图标
    private let categoryIcon_Breeze: UIImageView = {
        let imageView_breeze = UIImageView()
        imageView_breeze.tintColor = .white
        imageView_breeze.contentMode = .scaleAspectFit
        return imageView_breeze
    }()
    
    /// 分类名称标签
    private let categoryLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label_breeze.textColor = .white
        return label_breeze
    }()
    
    // MARK: - UI 组件：举报按钮
    
    /// 举报/删除按钮半透明圆形容器
    private let reportButtonContainer_Breeze: UIView = {
        let view_breeze = UIView()
        view_breeze.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view_breeze.layer.cornerRadius = 15
        return view_breeze
    }()
    
    /// 举报/删除按钮（随帖子重建）
    private var reportButton_Breeze: UIButton?
    
    // MARK: - UI 组件：文字区
    
    /// 帖子标题
    private let titleLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label_breeze.textColor = ColorConfig_Breeze.textPrimary_Breeze
        label_breeze.numberOfLines = 2
        return label_breeze
    }()
    
    /// 帖子内容摘要
    private let contentLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label_breeze.textColor = ColorConfig_Breeze.textSecondary_Breeze
        label_breeze.numberOfLines = 3
        return label_breeze
    }()
    
    // MARK: - UI 组件：作者信息行
    
    /// 分割线（内容与作者行之间）
    private let divider_Breeze: UIView = {
        let view_breeze = UIView()
        view_breeze.backgroundColor = ColorConfig_Breeze.divider_Breeze
        return view_breeze
    }()
    
    /// 作者头像
    private let avatarView_Breeze = UserAvatarView_Breeze()
    
    /// 作者昵称
    private let nameLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        label_breeze.textColor = ColorConfig_Breeze.textSecondary_Breeze
        return label_breeze
    }()
    
    /// 点赞心形图标（珊瑚红）
    private let likeIcon_Breeze: UIImageView = {
        let imageView_breeze = UIImageView()
        imageView_breeze.image = UIImage(systemName: "heart.fill")
        imageView_breeze.tintColor = ColorConfig_Breeze.accentCoral_Breeze
        imageView_breeze.contentMode = .scaleAspectFit
        return imageView_breeze
    }()
    
    /// 点赞数量
    private let likeLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        label_breeze.textColor = ColorConfig_Breeze.accentCoral_Breeze
        return label_breeze
    }()
    
    // MARK: - 约束与回调
    
    /// 媒体高度约束（随帖子动态变化）
    private var mediaHeightConstraint_Breeze: Constraint?
    
    /// 举报/删除完成后刷新列表的回调
    var onReportComplete_Breeze: (() -> Void)?
    
    /// 点击作者头像/昵称区域时的回调（传入该帖子作者的 userId）
    var onAvatarTap_Breeze: ((Int) -> Void)?
    
    /// 当前帖子的作者 userId（头像点击时使用）
    private var currentAuthorId_Breeze: Int = 0
    
    /// 宿主控制器（用于弹出举报/删除 Sheet）
    private weak var hostViewController_Breeze: UIViewController?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Breeze()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI 搭建
    
    /// 搭建卡片完整布局
    private func setupUI_Breeze() {
        contentView.addSubview(cardView_Breeze)
        
        // 媒体区
        cardView_Breeze.addSubview(mediaContainer_Breeze)
        mediaContainer_Breeze.addSubview(mediaView_Breeze)
        mediaContainer_Breeze.addSubview(imageOverlayView_Breeze)
        
        // 分类徽章（浮于图片左上角）
        mediaContainer_Breeze.addSubview(categoryBadge_Breeze)
        categoryBadge_Breeze.addSubview(categoryIcon_Breeze)
        categoryBadge_Breeze.addSubview(categoryLabel_Breeze)
        
        // 举报按钮（浮于图片右上角）
        cardView_Breeze.addSubview(reportButtonContainer_Breeze)
        
        // 文字区
        cardView_Breeze.addSubview(titleLabel_Breeze)
        cardView_Breeze.addSubview(contentLabel_Breeze)
        
        // 分割线
        cardView_Breeze.addSubview(divider_Breeze)
        
        // 作者行
        cardView_Breeze.addSubview(avatarView_Breeze)
        cardView_Breeze.addSubview(nameLabel_Breeze)
        cardView_Breeze.addSubview(likeIcon_Breeze)
        cardView_Breeze.addSubview(likeLabel_Breeze)
        
        setupConstraints_Breeze()
    }
    
    /// 配置所有 SnapKit 约束
    private func setupConstraints_Breeze() {
        cardView_Breeze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 媒体容器
        mediaContainer_Breeze.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            mediaHeightConstraint_Breeze = make.height.equalTo(140).constraint
        }
        
        mediaView_Breeze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 底部渐变遮罩：固定高度覆盖图片底部
        imageOverlayView_Breeze.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(64)
        }
        
        // 分类徽章：左上角，顶部偏移 10
        categoryBadge_Breeze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(22)
        }
        
        categoryIcon_Breeze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(7)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(11)
        }
        
        categoryLabel_Breeze.snp.makeConstraints { make in
            make.left.equalTo(categoryIcon_Breeze.snp.right).offset(4)
            make.right.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
        }
        
        // 举报按钮：右上角，顶部偏移 10
        reportButtonContainer_Breeze.snp.makeConstraints { make in
            make.top.equalTo(mediaContainer_Breeze).offset(10)
            make.right.equalTo(mediaContainer_Breeze).offset(-10)
            make.width.height.equalTo(30)
        }
        
        // 标题
        titleLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(mediaContainer_Breeze.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(12)
        }
        
        // 内容摘要
        contentLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Breeze.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(12)
        }
        
        // 分割线
        divider_Breeze.snp.makeConstraints { make in
            make.top.equalTo(contentLabel_Breeze.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(12)
            make.height.equalTo(0.5)
        }
        
        // 作者头像
        avatarView_Breeze.snp.makeConstraints { make in
            make.top.equalTo(divider_Breeze.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(12)
            make.width.height.equalTo(22)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        // 作者昵称
        nameLabel_Breeze.snp.makeConstraints { make in
            make.centerY.equalTo(avatarView_Breeze)
            make.left.equalTo(avatarView_Breeze.snp.right).offset(6)
        }
        
        // 点赞数
        likeLabel_Breeze.snp.makeConstraints { make in
            make.centerY.equalTo(avatarView_Breeze)
            make.right.equalToSuperview().offset(-12)
        }
        
        // 点赞心形图标
        likeIcon_Breeze.snp.makeConstraints { make in
            make.centerY.equalTo(avatarView_Breeze)
            make.right.equalTo(likeLabel_Breeze.snp.left).offset(-4)
            make.width.height.equalTo(12)
        }
        
        // 作者头像 + 昵称区域点击手势（跳转用户中心）
        let avatarTap_breeze = UITapGestureRecognizer(target: self, action: #selector(handleAvatarTap_Breeze))
        avatarView_Breeze.addGestureRecognizer(avatarTap_breeze)
        avatarView_Breeze.isUserInteractionEnabled = true
        
        let nameTap_breeze = UITapGestureRecognizer(target: self, action: #selector(handleAvatarTap_Breeze))
        nameLabel_Breeze.addGestureRecognizer(nameTap_breeze)
        nameLabel_Breeze.isUserInteractionEnabled = true
    }
    
    /// 头像 / 昵称被点击
    @objc private func handleAvatarTap_Breeze() {
        onAvatarTap_Breeze?(currentAuthorId_Breeze)
    }
    
    // MARK: - 布局更新
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 渐变图层需在 bounds 确定后创建 / 更新
        refreshOverlayGradient_Breeze()
        refreshBadgeGradient_Breeze()
    }
    
    /// 刷新图片底部渐变遮罩图层
    private func refreshOverlayGradient_Breeze() {
        overlayGradientLayer_Breeze?.removeFromSuperlayer()
        guard !imageOverlayView_Breeze.bounds.isEmpty else { return }
        
        let layer_breeze = CAGradientLayer()
        layer_breeze.frame = imageOverlayView_Breeze.bounds
        layer_breeze.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.48).cgColor]
        layer_breeze.locations = [0.0, 1.0]
        imageOverlayView_Breeze.layer.insertSublayer(layer_breeze, at: 0)
        overlayGradientLayer_Breeze = layer_breeze
    }
    
    /// 刷新分类徽章渐变背景图层
    private func refreshBadgeGradient_Breeze() {
        badgeGradientLayer_Breeze?.removeFromSuperlayer()
        guard !categoryBadge_Breeze.bounds.isEmpty else { return }
        
        let layer_breeze = CAGradientLayer()
        layer_breeze.frame = categoryBadge_Breeze.bounds
        layer_breeze.colors = currentBadgeColors_Breeze
        layer_breeze.startPoint = CGPoint(x: 0, y: 0.5)
        layer_breeze.endPoint = CGPoint(x: 1, y: 0.5)
        categoryBadge_Breeze.layer.insertSublayer(layer_breeze, at: 0)
        badgeGradientLayer_Breeze = layer_breeze
    }
    
    /// 当前分类对应的渐变色数组（configure 时存储）
    private var currentBadgeColors_Breeze: [CGColor] = [
        ColorConfig_Breeze.primaryGradientStart_Breeze.cgColor,
        ColorConfig_Breeze.primaryGradientEnd_Breeze.cgColor
    ]
    
    // MARK: - 数据配置
    
    /// 配置卡片展示内容
    /// - Parameters:
    ///   - post_breeze: 帖子数据模型
    ///   - hostViewController_breeze: 宿主控制器（举报/删除弹窗依赖）
    ///   - cardWidth_breeze: 卡片宽度（用于计算媒体高度）
    func configure_Breeze(post_breeze: TitleModel_Breeze,
                          hostViewController_breeze: UIViewController,
                          cardWidth_breeze: CGFloat) {
        self.hostViewController_Breeze = hostViewController_breeze
        currentAuthorId_Breeze = post_breeze.titleUserId_Breeze
        
        // 填充文字内容
        titleLabel_Breeze.text = post_breeze.title_Breeze
        contentLabel_Breeze.text = post_breeze.titleContent_Breeze
        nameLabel_Breeze.text = post_breeze.titleUserName_Breeze
        likeLabel_Breeze.text = "\(post_breeze.likes_Breeze)"
        
        // 头像 & 媒体
        avatarView_Breeze.configure_Breeze(userId_Breeze: post_breeze.titleUserId_Breeze)
        mediaView_Breeze.configure_Breeze(mediaPath_Breeze: post_breeze.titleMeidas_Breeze.first)
        
        // 分类徽章文字 & 图标
        let category_breeze = post_breeze.titleCategory_Breeze
        categoryLabel_Breeze.text = category_breeze.rawValue
        let iconConf_breeze = UIImage.SymbolConfiguration(pointSize: 9, weight: .bold)
        categoryIcon_Breeze.image = UIImage(systemName: category_breeze.iconName_Breeze,
                                            withConfiguration: iconConf_breeze)
        
        // 存储徽章渐变色，等待 layoutSubviews 实际绘制
        currentBadgeColors_Breeze = category_breeze.gradientColors_Breeze
        
        // 更新媒体高度约束
        let mediaHeight_breeze = Self.mediaHeight_Breeze(width_breeze: cardWidth_breeze, post_breeze: post_breeze)
        mediaHeightConstraint_Breeze?.update(offset: mediaHeight_breeze)
        
        // 重建举报/删除按钮（绑定当前帖子）
        rebuildReportButton_Breeze(post_breeze: post_breeze, hostViewController_breeze: hostViewController_breeze)
    }
    
    /// 重建举报/删除按钮
    private func rebuildReportButton_Breeze(post_breeze: TitleModel_Breeze,
                                             hostViewController_breeze: UIViewController) {
        reportButton_Breeze?.removeFromSuperview()
        
        let button_breeze = ReportDeleteHelper_Breeze.createPostReportButton_Breeze(
            post_Breeze: post_breeze,
            size_Breeze: 14,
            color_Breeze: .white,
            from: hostViewController_breeze
        ) { [weak self] in
            self?.onReportComplete_Breeze?()
        }
        reportButtonContainer_Breeze.addSubview(button_breeze)
        button_breeze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        reportButton_Breeze = button_breeze
    }
    
    // MARK: - 高度计算
    
    /// 计算媒体图片高度（按帖子 ID 伪随机三档比例，形成错落瀑布效果）
    /// - Parameters:
    ///   - width_breeze: 卡片宽度
    ///   - post_breeze: 帖子数据模型
    /// - Returns: 媒体高度
    static func mediaHeight_Breeze(width_breeze: CGFloat, post_breeze: TitleModel_Breeze) -> CGFloat {
        let ratios_breeze: [CGFloat] = [0.75, 1.0, 1.25]
        let ratio_breeze = ratios_breeze[abs(post_breeze.titleId_Breeze) % ratios_breeze.count]
        return width_breeze * ratio_breeze
    }
    
    /// 计算整张卡片总高度（供瀑布流布局使用）
    /// - Parameters:
    ///   - width_breeze: 卡片宽度
    ///   - post_breeze: 帖子数据模型
    /// - Returns: 卡片总高度
    static func cellHeight_Breeze(width_breeze: CGFloat, post_breeze: TitleModel_Breeze) -> CGFloat {
        let mediaH_breeze = mediaHeight_Breeze(width_breeze: width_breeze, post_breeze: post_breeze)
        let textW_breeze = width_breeze - 24
        
        // 标题（最多 2 行）
        let titleH_breeze = heightForLabel_Breeze(
            text_breeze: post_breeze.title_Breeze,
            font_breeze: .systemFont(ofSize: 15, weight: .bold),
            width_breeze: textW_breeze,
            maxLines_breeze: 2
        )
        // 内容（最多 3 行）
        let contentH_breeze = heightForLabel_Breeze(
            text_breeze: post_breeze.titleContent_Breeze,
            font_breeze: .systemFont(ofSize: 12, weight: .regular),
            width_breeze: textW_breeze,
            maxLines_breeze: 3
        )
        // 12(标题上) + 6(内容上) + 10(分割线上) + 0.5(分割线) + 10(头像上) + 22(头像) + 12(底部)
        return mediaH_breeze + 12 + titleH_breeze + 6 + contentH_breeze + 10 + 0.5 + 10 + 22 + 12
    }
    
    /// 计算多行文本在限定宽度和行数内的实际高度
    private static func heightForLabel_Breeze(text_breeze: String,
                                              font_breeze: UIFont,
                                              width_breeze: CGFloat,
                                              maxLines_breeze: Int) -> CGFloat {
        let maxH_breeze = font_breeze.lineHeight * CGFloat(maxLines_breeze)
        let boundRect_breeze = (text_breeze as NSString).boundingRect(
            with: CGSize(width: width_breeze, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font_breeze],
            context: nil
        )
        return min(ceil(boundRect_breeze.height), ceil(maxH_breeze))
    }
    
    // MARK: - 复用清理
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reportButton_Breeze?.removeFromSuperview()
        reportButton_Breeze = nil
        onReportComplete_Breeze = nil
        onAvatarTap_Breeze = nil
        currentAuthorId_Breeze = 0
        overlayGradientLayer_Breeze = nil
        badgeGradientLayer_Breeze = nil
    }
}
