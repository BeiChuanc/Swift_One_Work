import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: - 消息列表 Cell

/// 消息列表通用 Cell 组件
/// 核心作用：展示单条会话预览，含头像、用户名、最后消息及时间戳
/// 设计思路：白色卡片 + 三色渐变头像光圈 + 在线辉光绿点 + 渐变竖条装饰
///          发送方消息"You:"前缀以紫色高亮区分 + 右侧箭头引导 + 未读数角标
class MessageListCell_Somnia: UITableViewCell {

    // MARK: - 静态标识

    static let reuseId_Somnia = "MessageListCell_Somnia"

    // MARK: - 回调

    var onDeleteTapped_Somnia: (() -> Void)?

    // MARK: - 私有属性

    /// 当前头像装饰竖条颜色索引（用于渐变复建）
    private var _accentColorIdx_Somnia: Int = 0

    // MARK: - UI 组件 — 卡片

    private let cardView_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 3)
        v.layer.shadowRadius = 10
        v.layer.shadowOpacity = 0.07
        return v
    }()

    // MARK: - UI 组件 — 左侧渐变竖条

    private let accentBar_Somnia: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 2
        v.clipsToBounds = true
        return v
    }()

    private var accentBarGradient_Somnia: CAGradientLayer?

    // MARK: - UI 组件 — 头像三层环

    /// 最外层渐变光圈（64pt）
    private let avatarRingView_Somnia: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 32
        v.clipsToBounds = true
        return v
    }()

    private var ringGradientLayer_Somnia: CAGradientLayer?

    /// 白色内边框（56pt）
    private let avatarBorder_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 28
        return v
    }()

    /// 头像图片（48pt）
    private let avatarImageView_Somnia: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 24
        iv.backgroundColor = ColorConfig_Somnia.backgroundPrimary_Somnia
        return iv
    }()

    /// 头像首字母占位
    private let avatarInitialLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        lbl.textColor = .white
        return lbl
    }()

    // MARK: - UI 组件 — 在线辉光 + 绿点

    /// 在线辉光层（20pt，绿色低透明度背景）
    private let onlineGlowView_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Somnia: "#48BB78").withAlphaComponent(0.25)
        v.layer.cornerRadius = 10
        return v
    }()

    /// 在线绿点（12pt，带白色边框）
    private let onlineDot_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Somnia: "#48BB78")
        v.layer.cornerRadius = 6
        v.layer.borderColor = UIColor.white.cgColor
        v.layer.borderWidth = 2
        return v
    }()

    // MARK: - UI 组件 — 文本信息

    /// 用户名标签
    private let nameLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        lbl.textColor = ColorConfig_Somnia.textPrimary_Somnia
        return lbl
    }()

    /// 最后一条消息预览
    private let lastMsgLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl.textColor = ColorConfig_Somnia.textSecondary_Somnia
        lbl.numberOfLines = 1
        return lbl
    }()

    /// 时间戳
    private let timeLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        lbl.textColor = ColorConfig_Somnia.textPlaceholder_Somnia
        lbl.textAlignment = .right
        return lbl
    }()

    // MARK: - UI 组件 — 右侧箭头

    private let chevronView_Somnia: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
        iv.image = UIImage(systemName: "chevron.right", withConfiguration: cfg)
        iv.tintColor = UIColor(hexstring_Somnia: "#CBD5E0")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: - UI 组件 — 未读角标

    private let unreadBadge_Somnia: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 9
        v.isHidden = true
        return v
    }()

    private let unreadLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        lbl.textColor = .white
        lbl.textAlignment = .center
        return lbl
    }()

    private var badgeGradientLayer_Somnia: CAGradientLayer?

    // MARK: - 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        setupUI_Somnia()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradientLayouts_Somnia()
    }

    // MARK: - 对外配置方法

    /// 配置 Cell 数据
    /// - Parameters:
    ///   - user_somnia: 聊天对象用户模型
    ///   - lastMessage_somnia: 最后一条消息模型
    ///   - unreadCount_somnia: 未读消息数量（默认 0）
    func configure_Somnia(
        user_somnia: PrewUserModel_Somnia,
        lastMessage_somnia: MessageModel_Somnia?,
        unreadCount_somnia: Int = 0
    ) {
        nameLabel_Somnia.text = user_somnia.userName_Somnia ?? "Unknown"
        configureAvatar_Somnia(user_somnia: user_somnia)

        // 最后消息：发送方前缀用紫色高亮
        if let content = lastMessage_somnia?.content_Somnia, !content.isEmpty {
            let isMine = lastMessage_somnia?.isMine_Somnia == true
            if isMine {
                lastMsgLabel_Somnia.attributedText = makeSentMsgAttr_Somnia(
                    content_Somnia: content,
                    isUnread_Somnia: unreadCount_somnia > 0
                )
            } else {
                lastMsgLabel_Somnia.attributedText = nil
                lastMsgLabel_Somnia.text = content
                lastMsgLabel_Somnia.textColor = unreadCount_somnia > 0
                    ? ColorConfig_Somnia.textPrimary_Somnia
                    : ColorConfig_Somnia.textSecondary_Somnia
                lastMsgLabel_Somnia.font = UIFont.systemFont(
                    ofSize: 13,
                    weight: unreadCount_somnia > 0 ? .medium : .regular
                )
            }
        } else {
            lastMsgLabel_Somnia.attributedText = nil
            lastMsgLabel_Somnia.text = "Say hello 👋"
            lastMsgLabel_Somnia.textColor = ColorConfig_Somnia.textPlaceholder_Somnia
            lastMsgLabel_Somnia.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        }

        timeLabel_Somnia.text = lastMessage_somnia?.time_Somnia ?? ""
        configureUnreadBadge_Somnia(count_somnia: unreadCount_somnia)

        // 装饰竖条颜色索引（下次 layoutSubviews 时重建渐变）
        let idx = (user_somnia.userId_Somnia ?? 0) % UserAvatarView_Somnia.defaultAvatarColors_Somnia.count
        _accentColorIdx_Somnia = idx
        accentBarGradient_Somnia?.removeFromSuperlayer()
        accentBarGradient_Somnia = nil
    }

    // MARK: - 私有 UI 搭建

    private func setupUI_Somnia() {
        contentView.addSubview(cardView_Somnia)

        cardView_Somnia.addSubview(accentBar_Somnia)
        cardView_Somnia.addSubview(avatarRingView_Somnia)
        avatarRingView_Somnia.addSubview(avatarBorder_Somnia)
        avatarBorder_Somnia.addSubview(avatarImageView_Somnia)
        avatarImageView_Somnia.addSubview(avatarInitialLabel_Somnia)
        cardView_Somnia.addSubview(onlineGlowView_Somnia)
        cardView_Somnia.addSubview(onlineDot_Somnia)

        cardView_Somnia.addSubview(nameLabel_Somnia)
        cardView_Somnia.addSubview(lastMsgLabel_Somnia)
        cardView_Somnia.addSubview(timeLabel_Somnia)
        cardView_Somnia.addSubview(chevronView_Somnia)
        cardView_Somnia.addSubview(unreadBadge_Somnia)
        unreadBadge_Somnia.addSubview(unreadLabel_Somnia)

        setupConstraints_Somnia()
    }

    private func setupConstraints_Somnia() {
        cardView_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.bottom.equalToSuperview().offset(-6)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }

        // 左侧渐变装饰竖条
        accentBar_Somnia.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(44)
        }

        // 头像外层渐变环（64pt）
        avatarRingView_Somnia.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(26)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(64)
        }

        // 白色内边框（56pt）
        avatarBorder_Somnia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(56)
        }

        // 头像图片（48pt）
        avatarImageView_Somnia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(48)
        }

        avatarInitialLabel_Somnia.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 在线辉光（20pt，叠在 onlineDot 之后）
        onlineGlowView_Somnia.snp.makeConstraints { make in
            make.center.equalTo(onlineDot_Somnia)
            make.width.height.equalTo(20)
        }

        // 在线绿点（12pt，圆角右下角）
        onlineDot_Somnia.snp.makeConstraints { make in
            make.right.equalTo(avatarRingView_Somnia.snp.right).offset(1)
            make.bottom.equalTo(avatarRingView_Somnia.snp.bottom).offset(1)
            make.width.height.equalTo(12)
        }

        // 右侧箭头
        chevronView_Somnia.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.width.equalTo(8)
            make.height.equalTo(14)
        }

        // 时间戳（chevron 左侧）
        timeLabel_Somnia.snp.makeConstraints { make in
            make.right.equalTo(chevronView_Somnia.snp.left).offset(-6)
            make.top.equalTo(avatarRingView_Somnia.snp.top).offset(8)
            make.width.equalTo(52)
        }

        // 用户名（内容区顶部，与时间同行）
        nameLabel_Somnia.snp.makeConstraints { make in
            make.left.equalTo(avatarRingView_Somnia.snp.right).offset(12)
            make.top.equalTo(timeLabel_Somnia)
            make.right.equalTo(timeLabel_Somnia.snp.left).offset(-8)
        }

        // 未读角标（chevron 左侧，消息预览行）
        unreadBadge_Somnia.snp.makeConstraints { make in
            make.right.equalTo(chevronView_Somnia.snp.left).offset(-6)
            make.centerY.equalTo(lastMsgLabel_Somnia)
            make.width.greaterThanOrEqualTo(18)
            make.height.equalTo(18)
        }

        // 最后消息（名字下方，右边为角标/chevron 留空）
        lastMsgLabel_Somnia.snp.makeConstraints { make in
            make.left.equalTo(nameLabel_Somnia)
            make.top.equalTo(nameLabel_Somnia.snp.bottom).offset(5)
            make.right.equalTo(unreadBadge_Somnia.snp.left).offset(-8)
        }

        unreadLabel_Somnia.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4))
        }
    }

    // MARK: - 私有配置方法

    /// 构建发送方消息 NSAttributedString（"You:" 紫色高亮）
    /// - Parameters:
    ///   - content_Somnia: 消息正文内容
    ///   - isUnread_Somnia: 是否有未读消息（影响正文字重）
    private func makeSentMsgAttr_Somnia(content_Somnia: String, isUnread_Somnia: Bool) -> NSAttributedString {
        let prefixAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13, weight: .medium),
            .foregroundColor: ColorConfig_Somnia.primaryGradientStart_Somnia.withAlphaComponent(0.85)
        ]
        let contentAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13, weight: isUnread_Somnia ? .medium : .regular),
            .foregroundColor: isUnread_Somnia
                ? ColorConfig_Somnia.textPrimary_Somnia
                : ColorConfig_Somnia.textSecondary_Somnia
        ]
        let result = NSMutableAttributedString(string: "You:  ", attributes: prefixAttrs)
        result.append(NSAttributedString(string: content_Somnia, attributes: contentAttrs))
        return result
    }

    /// 配置头像显示
    private func configureAvatar_Somnia(user_somnia: PrewUserModel_Somnia) {
        let idx = (user_somnia.userId_Somnia ?? 0) % UserAvatarView_Somnia.defaultAvatarColors_Somnia.count
        let color = UserAvatarView_Somnia.defaultAvatarColors_Somnia[idx]

        let initial = String(user_somnia.userName_Somnia?.prefix(1) ?? "?").uppercased()
        avatarInitialLabel_Somnia.text = initial
        avatarImageView_Somnia.backgroundColor = color

        if let head = user_somnia.userHead_Somnia, !head.isEmpty, head != "default_avatar",
           let url = URL(string: head) {
            avatarImageView_Somnia.kf.setImage(with: url) { [weak self] result in
                switch result {
                case .success: self?.avatarInitialLabel_Somnia.isHidden = true
                case .failure: self?.avatarInitialLabel_Somnia.isHidden = false
                }
            }
        } else {
            avatarInitialLabel_Somnia.isHidden = false
        }

        // 清除旧渐变，等待 layoutSubviews 重建
        ringGradientLayer_Somnia?.removeFromSuperlayer()
        ringGradientLayer_Somnia = nil
    }

    /// 配置未读角标
    private func configureUnreadBadge_Somnia(count_somnia: Int) {
        if count_somnia > 0 {
            unreadBadge_Somnia.isHidden = false
            unreadLabel_Somnia.text = count_somnia > 99 ? "99+" : "\(count_somnia)"
            badgeGradientLayer_Somnia?.removeFromSuperlayer()
            badgeGradientLayer_Somnia = nil
        } else {
            unreadBadge_Somnia.isHidden = true
        }
    }

    /// 在 layoutSubviews 中统一更新所有渐变图层尺寸
    private func updateGradientLayouts_Somnia() {
        // ── 头像三色渐变光圈 ──
        if ringGradientLayer_Somnia == nil {
            let g = CAGradientLayer()
            g.colors = [
                UIColor(hexstring_Somnia: "#C4B5FD").cgColor,
                ColorConfig_Somnia.primaryGradientStart_Somnia.cgColor,
                ColorConfig_Somnia.primaryGradientEnd_Somnia.cgColor
            ]
            g.locations = [0.0, 0.5, 1.0]
            g.startPoint = CGPoint(x: 0, y: 0)
            g.endPoint   = CGPoint(x: 1, y: 1)
            g.frame = avatarRingView_Somnia.bounds
            g.cornerRadius = avatarRingView_Somnia.layer.cornerRadius
            avatarRingView_Somnia.layer.insertSublayer(g, at: 0)
            ringGradientLayer_Somnia = g
        } else {
            ringGradientLayer_Somnia?.frame = avatarRingView_Somnia.bounds
        }

        // ── 装饰竖条渐变（顶部强色 → 底部淡色） ──
        if accentBarGradient_Somnia == nil {
            let colors = UserAvatarView_Somnia.defaultAvatarColors_Somnia
            let color = colors[_accentColorIdx_Somnia % colors.count]
            let g = CAGradientLayer()
            g.colors = [color.cgColor, color.withAlphaComponent(0.3).cgColor]
            g.startPoint = CGPoint(x: 0, y: 0)
            g.endPoint   = CGPoint(x: 0, y: 1)
            g.frame = accentBar_Somnia.bounds
            g.cornerRadius = accentBar_Somnia.layer.cornerRadius
            accentBar_Somnia.layer.insertSublayer(g, at: 0)
            accentBarGradient_Somnia = g
        } else {
            accentBarGradient_Somnia?.frame = accentBar_Somnia.bounds
        }

        // ── 未读角标渐变 ──
        if !unreadBadge_Somnia.isHidden, badgeGradientLayer_Somnia == nil {
            let g = CAGradientLayer()
            g.colors = [
                ColorConfig_Somnia.primaryGradientStart_Somnia.cgColor,
                UIColor(hexstring_Somnia: "#ED64A6").cgColor
            ]
            g.startPoint = CGPoint(x: 0, y: 0)
            g.endPoint   = CGPoint(x: 1, y: 1)
            g.frame = unreadBadge_Somnia.bounds
            g.cornerRadius = unreadBadge_Somnia.layer.cornerRadius
            unreadBadge_Somnia.layer.insertSublayer(g, at: 0)
            badgeGradientLayer_Somnia = g
        } else {
            badgeGradientLayer_Somnia?.frame = unreadBadge_Somnia.bounds
        }
    }

    // MARK: - 复用重置

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView_Somnia.image = nil
        avatarInitialLabel_Somnia.isHidden = false
        onlineDot_Somnia.isHidden = false
        unreadBadge_Somnia.isHidden = true
        lastMsgLabel_Somnia.attributedText = nil

        ringGradientLayer_Somnia?.removeFromSuperlayer()
        ringGradientLayer_Somnia = nil
        badgeGradientLayer_Somnia?.removeFromSuperlayer()
        badgeGradientLayer_Somnia = nil
        accentBarGradient_Somnia?.removeFromSuperlayer()
        accentBarGradient_Somnia = nil
    }

    // MARK: - 交互动画

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        cardView_Somnia.animatePressDown_Somnia()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        cardView_Somnia.animatePressUp_Somnia()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        cardView_Somnia.animatePressUp_Somnia()
    }
}
