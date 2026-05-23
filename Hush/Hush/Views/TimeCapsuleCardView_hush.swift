import UIKit
import SnapKit

// MARK: 时间胶囊卡片视图

/// 时间胶囊卡片视图
/// 功能：展示单个时间胶囊，锁定状态模糊封面并显示倒计时，解锁状态显示完整内容
/// 关键属性：deleteAction_Hush（删除回调）、model_Hush（绑定数据模型）
class TimeCapsuleCardView_Hush: UIView {

    // MARK: - 回调

    /// 删除按钮点击回调
    var deleteAction_Hush: (() -> Void)?

    // MARK: - UI 组件

    /// 封面图片层
    private let imageView_Hush: UIImageView = {
        let iv_hush = UIImageView()
        iv_hush.contentMode = .scaleAspectFill
        iv_hush.clipsToBounds = true
        iv_hush.backgroundColor = UIColor(hexstring_Hush: "#2C2F3A")
        return iv_hush
    }()

    /// 模糊蒙层（锁定时显示）
    private let blurView_Hush: UIVisualEffectView = {
        let blur_hush = UIBlurEffect(style: .dark)
        return UIVisualEffectView(effect: blur_hush)
    }()

    /// 渐变遮罩（底部信息区背景）
    private let gradientOverlay_Hush = UIView()
    private var gradientLayer_Hush: CAGradientLayer?

    /// 锁定图标
    private let lockIcon_Hush: UIImageView = {
        let iv_hush = UIImageView()
        iv_hush.image = UIImage(systemName: "lock.fill")
        iv_hush.tintColor = .white
        iv_hush.contentMode = .scaleAspectFit
        return iv_hush
    }()

    /// 倒计时标签（锁定时显示）
    private let countdownLabel_Hush: UILabel = {
        let lb_hush = UILabel()
        lb_hush.textColor = .white
        lb_hush.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        lb_hush.textAlignment = .center
        return lb_hush
    }()

    /// 解锁标识（已解锁时显示）
    private let unlockedBadge_Hush: UIView = {
        let v_hush = UIView()
        v_hush.backgroundColor = UIColor(hexstring_Hush: "#FF6B35")
        v_hush.layer.cornerRadius = 10
        return v_hush
    }()

    private let unlockedLabel_Hush: UILabel = {
        let lb_hush = UILabel()
        lb_hush.text = "Unlocked"
        lb_hush.textColor = .white
        lb_hush.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        lb_hush.textAlignment = .center
        return lb_hush
    }()

    /// 胶囊标题
    private let titleLabel_Hush: UILabel = {
        let lb_hush = UILabel()
        lb_hush.textColor = .white
        lb_hush.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        lb_hush.numberOfLines = 2
        return lb_hush
    }()

    /// 删除按钮
    private let deleteButton_Hush: UIButton = {
        let bt_hush = UIButton(type: .system)
        let config_hush = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        bt_hush.setImage(UIImage(systemName: "trash.fill", withConfiguration: config_hush), for: .normal)
        bt_hush.tintColor = .white
        bt_hush.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        bt_hush.layer.cornerRadius = 14
        return bt_hush
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Hush()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI_Hush()
    }

    // MARK: - 布局

    override func layoutSubviews() {
        super.layoutSubviews()
        setupGradientLayer_Hush()
    }

    // MARK: - 私有方法

    /// 构建视图层次与约束
    private func setupUI_Hush() {
        layer.cornerRadius = 16
        clipsToBounds = true
        layer.shadowColor = ColorConfig_Hush.shadowColor_Hush.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 10
        layer.shadowOpacity = 1

        addSubview(imageView_Hush)
        addSubview(blurView_Hush)
        addSubview(gradientOverlay_Hush)
        addSubview(lockIcon_Hush)
        addSubview(countdownLabel_Hush)
        addSubview(unlockedBadge_Hush)
        unlockedBadge_Hush.addSubview(unlockedLabel_Hush)
        addSubview(titleLabel_Hush)
        addSubview(deleteButton_Hush)

        imageView_Hush.snp.makeConstraints { make_hush in
            make_hush.edges.equalToSuperview()
        }
        blurView_Hush.snp.makeConstraints { make_hush in
            make_hush.edges.equalToSuperview()
        }
        gradientOverlay_Hush.snp.makeConstraints { make_hush in
            make_hush.left.right.bottom.equalToSuperview()
            make_hush.height.equalTo(100)
        }
        lockIcon_Hush.snp.makeConstraints { make_hush in
            make_hush.centerX.equalToSuperview()
            make_hush.centerY.equalToSuperview().offset(-16)
            make_hush.width.height.equalTo(32)
        }
        countdownLabel_Hush.snp.makeConstraints { make_hush in
            make_hush.centerX.equalToSuperview()
            make_hush.top.equalTo(lockIcon_Hush.snp.bottom).offset(8)
            make_hush.left.right.equalToSuperview().inset(8)
        }
        unlockedBadge_Hush.snp.makeConstraints { make_hush in
            make_hush.top.equalToSuperview().offset(12)
            make_hush.left.equalToSuperview().offset(12)
            make_hush.height.equalTo(20)
            make_hush.width.equalTo(68)
        }
        unlockedLabel_Hush.snp.makeConstraints { make_hush in
            make_hush.edges.equalToSuperview().inset(UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6))
        }
        titleLabel_Hush.snp.makeConstraints { make_hush in
            make_hush.left.right.equalToSuperview().inset(12)
            make_hush.bottom.equalToSuperview().offset(-14)
        }
        deleteButton_Hush.snp.makeConstraints { make_hush in
            make_hush.top.equalToSuperview().offset(12)
            make_hush.right.equalToSuperview().offset(-12)
            make_hush.width.height.equalTo(28)
        }

        deleteButton_Hush.addTarget(self, action: #selector(onDeleteTap_Hush), for: .touchUpInside)
    }

    /// 设置底部渐变遮罩
    private func setupGradientLayer_Hush() {
        gradientLayer_Hush?.removeFromSuperlayer()
        let layer_hush = CAGradientLayer()
        layer_hush.frame = gradientOverlay_Hush.bounds
        layer_hush.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.75).cgColor]
        layer_hush.startPoint = CGPoint(x: 0.5, y: 0)
        layer_hush.endPoint = CGPoint(x: 0.5, y: 1)
        gradientOverlay_Hush.layer.insertSublayer(layer_hush, at: 0)
        gradientLayer_Hush = layer_hush
    }

    @objc private func onDeleteTap_Hush() {
        deleteAction_Hush?()
    }

    // MARK: - 数据绑定

    /// 绑定胶囊模型，刷新视图状态
    /// - Parameter model_hush: 时间胶囊数据模型
    func configure_Hush(model_hush: TimeCapsuleModel_Hush) {
        titleLabel_Hush.text = model_hush.capsuleTitle_Hush

        if let img_hush = model_hush.capsuleImage_Hush {
            imageView_Hush.image = img_hush
        } else {
            imageView_Hush.image = nil
            imageView_Hush.backgroundColor = UIColor(hexstring_Hush: "#2C2F3A")
        }

        if model_hush.isUnlocked_Hush {
            // 已解锁：取消模糊，显示解锁徽章
            blurView_Hush.isHidden = true
            lockIcon_Hush.isHidden = true
            countdownLabel_Hush.isHidden = true
            unlockedBadge_Hush.isHidden = false
        } else {
            // 锁定中：显示模糊层和倒计时
            blurView_Hush.isHidden = false
            lockIcon_Hush.isHidden = false
            countdownLabel_Hush.isHidden = false
            unlockedBadge_Hush.isHidden = true
            let days_hush = model_hush.daysRemaining_Hush
            countdownLabel_Hush.text = days_hush > 0 ? "Opens in \(days_hush) days" : "Opening soon..."
        }
    }
}

// MARK: - 时间胶囊 CollectionViewCell

/// 时间胶囊列表 Cell
/// 功能：包装 TimeCapsuleCardView_Hush，供 UICollectionView 使用
class TimeCapsuleCell_Hush: UICollectionViewCell {

    static let reuseId_Hush = "TimeCapsuleCell_Hush"

    /// 胶囊卡片视图
    let cardView_Hush = TimeCapsuleCardView_Hush()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(cardView_Hush)
        cardView_Hush.snp.makeConstraints { make_hush in
            make_hush.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - 新建胶囊占位 Cell

/// 新建时间胶囊占位卡片 Cell
/// 功能：点击后跳转至时间胶囊创建页
class AddCapsuleCell_Hush: UICollectionViewCell {

    static let reuseId_Hush = "AddCapsuleCell_Hush"

    private let containerView_Hush: UIView = {
        let v_hush = UIView()
        v_hush.layer.cornerRadius = 16
        v_hush.layer.borderWidth = 2
        v_hush.layer.borderColor = UIColor(hexstring_Hush: "#FF6B35", alpha_Hush: 0.5).cgColor
        v_hush.backgroundColor = UIColor(hexstring_Hush: "#FF6B35", alpha_Hush: 0.06)
        return v_hush
    }()

    private let plusIcon_Hush: UIImageView = {
        let iv_hush = UIImageView()
        iv_hush.image = UIImage(systemName: "plus.circle.fill")
        iv_hush.tintColor = UIColor(hexstring_Hush: "#FF6B35")
        iv_hush.contentMode = .scaleAspectFit
        return iv_hush
    }()

    private let label_Hush: UILabel = {
        let lb_hush = UILabel()
        lb_hush.text = "Plant a\nCapsule"
        lb_hush.textColor = UIColor(hexstring_Hush: "#FF6B35")
        lb_hush.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        lb_hush.textAlignment = .center
        lb_hush.numberOfLines = 2
        return lb_hush
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(containerView_Hush)
        containerView_Hush.addSubview(plusIcon_Hush)
        containerView_Hush.addSubview(label_Hush)

        containerView_Hush.snp.makeConstraints { make_hush in
            make_hush.edges.equalToSuperview()
        }
        plusIcon_Hush.snp.makeConstraints { make_hush in
            make_hush.centerX.equalToSuperview()
            make_hush.centerY.equalToSuperview().offset(-16)
            make_hush.width.height.equalTo(36)
        }
        label_Hush.snp.makeConstraints { make_hush in
            make_hush.centerX.equalToSuperview()
            make_hush.top.equalTo(plusIcon_Hush.snp.bottom).offset(8)
            make_hush.left.right.equalToSuperview().inset(8)
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
