import UIKit
import SnapKit

// MARK: 首页打卡进度条 Cell

/// 首页打卡进度条 Cell
/// 核心作用：在首页展示最近 7 天打卡状态，以线性圆点条带形式呈现
/// 设计理念：温暖渐变卡片 + 火焰/天数（左上） + 7 天圆点（左下） + 右侧操作按钮
/// 未登录时：右侧显示 "Login to Start" 胶囊按钮，圆点以空态展示
/// 已登录时：右侧显示 "Check In" / "✓ Done" 文字 + 箭头
class HomeCheckInBannerCell_Pane: UICollectionViewCell {

    // MARK: - 常量

    static let reuseId_Pane = "HomeCheckInBannerCell_Pane"

    // MARK: - UI 组件

    private let cardView_Pane: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 20
        v.clipsToBounds      = true
        return v
    }()

    private var bgGradient_Pane: CAGradientLayer?

    private let flameIcon_Pane: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "flame.fill"))
        iv.tintColor   = UIColor(hexstring_Pane: "#FF8C42")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let streakLabel_Pane: UILabel = {
        let l = UILabel()
        l.font      = .systemFont(ofSize: 22, weight: .black)
        l.textColor = .white
        return l
    }()

    private let streakSubLabel_Pane: UILabel = {
        let l = UILabel()
        l.text      = "Day Streak"
        l.font      = .systemFont(ofSize: 11, weight: .medium)
        l.textColor = UIColor.white.withAlphaComponent(0.75)
        return l
    }()

    private let dotsStack_Pane: UIStackView = {
        let sv = UIStackView()
        sv.axis         = .horizontal
        sv.spacing      = 6
        sv.alignment    = .center
        sv.distribution = .fillEqually
        return sv
    }()

    // MARK: - 右侧：已登录状态（文字 + 箭头）

    private let actionLabel_Pane: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor     = .white
        l.textAlignment = .right
        return l
    }()

    private let chevronIcon_Pane: UIImageView = {
        let cfg = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        let iv  = UIImageView(image: UIImage(systemName: "chevron.right", withConfiguration: cfg))
        iv.tintColor   = UIColor.white.withAlphaComponent(0.7)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: - 右侧：未登录状态（Login 胶囊按钮）

    private let loginButton_Pane: UIButton = {
        let b = UIButton(type: .custom)
        b.setTitle("Start  →", for: .normal)
        b.titleLabel?.font    = .systemFont(ofSize: 12, weight: .semibold)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor     = UIColor.white.withAlphaComponent(0.22)
        b.layer.cornerRadius  = 15
        b.layer.borderWidth   = 1
        b.layer.borderColor   = UIColor.white.withAlphaComponent(0.4).cgColor
        b.contentEdgeInsets   = UIEdgeInsets(top: 6, left: 14, bottom: 6, right: 14)
        b.isUserInteractionEnabled = false  // 整体点击由 cell 手势处理
        b.isHidden = true
        return b
    }()

    // MARK: - 属性

    var onTapped_Pane: (() -> Void)?
    private var dotViews_Pane: [UIView] = []

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Pane()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap_Pane))
        contentView.addGestureRecognizer(tap)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        bgGradient_Pane?.frame = cardView_Pane.bounds
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 20).cgPath
    }

    // MARK: - UI 搭建

    private func setupUI_Pane() {
        layer.shadowColor   = UIColor(hexstring_Pane: "#C97B3E").withAlphaComponent(0.3).cgColor
        layer.shadowOpacity = 0.6
        layer.shadowOffset  = CGSize(width: 0, height: 4)
        layer.shadowRadius  = 8
        layer.masksToBounds = false

        contentView.addSubview(cardView_Pane)
        cardView_Pane.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 背景渐变
        let gl = CAGradientLayer()
        gl.colors      = [UIColor(hexstring_Pane: "#FF7043").cgColor,
                          UIColor(hexstring_Pane: "#E91E8C").cgColor]
        gl.startPoint  = CGPoint(x: 0, y: 0.5)
        gl.endPoint    = CGPoint(x: 1, y: 0.5)
        cardView_Pane.layer.addSublayer(gl)
        bgGradient_Pane = gl

        // 右侧装饰圆
        let deco_pane = UIView()
        deco_pane.backgroundColor    = UIColor.white.withAlphaComponent(0.08)
        deco_pane.layer.cornerRadius = 60
        cardView_Pane.addSubview(deco_pane)
        deco_pane.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(30)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(120)
        }

        // 左上：火焰 + 天数 + 副标题
        cardView_Pane.addSubview(flameIcon_Pane)
        flameIcon_Pane.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(14)
            $0.width.height.equalTo(22)
        }
        cardView_Pane.addSubview(streakLabel_Pane)
        streakLabel_Pane.snp.makeConstraints {
            $0.leading.equalTo(flameIcon_Pane.snp.trailing).offset(6)
            $0.centerY.equalTo(flameIcon_Pane)
        }
        cardView_Pane.addSubview(streakSubLabel_Pane)
        streakSubLabel_Pane.snp.makeConstraints {
            $0.leading.equalTo(streakLabel_Pane.snp.trailing).offset(5)
            $0.centerY.equalTo(streakLabel_Pane)
        }

        // 左下：7 天圆点进度
        cardView_Pane.addSubview(dotsStack_Pane)
        dotsStack_Pane.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-12)
            $0.height.equalTo(30)
        }
        buildDotViews_Pane()

        // 右侧：已登录 - 文字 + 箭头
        cardView_Pane.addSubview(chevronIcon_Pane)
        chevronIcon_Pane.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(12)
        }
        cardView_Pane.addSubview(actionLabel_Pane)
        actionLabel_Pane.snp.makeConstraints {
            $0.trailing.equalTo(chevronIcon_Pane.snp.leading).offset(-4)
            $0.centerY.equalToSuperview()
        }

        // 右侧：未登录 - Login 按钮
        cardView_Pane.addSubview(loginButton_Pane)
        loginButton_Pane.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
    }

    // MARK: - 7 天圆点

    private func buildDotViews_Pane() {
        dotViews_Pane.forEach { $0.removeFromSuperview() }
        dotViews_Pane.removeAll()
        for _ in 0..<7 {
            let container_pane = UIView()
            container_pane.snp.makeConstraints { $0.width.equalTo(28) }

            let circle_pane = UIView()
            circle_pane.layer.cornerRadius = 9
            circle_pane.layer.borderWidth  = 1.5
            circle_pane.layer.borderColor  = UIColor.white.withAlphaComponent(0.5).cgColor
            container_pane.addSubview(circle_pane)
            circle_pane.snp.makeConstraints {
                $0.top.centerX.equalToSuperview()
                $0.width.height.equalTo(18)
            }

            let dayLabel_pane = UILabel()
            dayLabel_pane.font          = .systemFont(ofSize: 9, weight: .semibold)
            dayLabel_pane.textAlignment = .center
            dayLabel_pane.textColor     = UIColor.white.withAlphaComponent(0.65)
            container_pane.addSubview(dayLabel_pane)
            dayLabel_pane.snp.makeConstraints {
                $0.top.equalTo(circle_pane.snp.bottom).offset(2)
                $0.centerX.equalToSuperview()
                $0.bottom.equalToSuperview()
            }

            dotsStack_Pane.addArrangedSubview(container_pane)
            dotViews_Pane.append(container_pane)
        }
    }

    // MARK: - 数据配置

    /// 配置打卡进度条内容
    /// - Parameters:
    ///   - streak_pane:       连续打卡天数
    ///   - records_pane:      最近 7 天打卡记录
    ///   - checkedToday_pane: 今天是否已打卡
    ///   - isLoggedIn_pane:   是否已登录（决定右侧显示内容）
    func configure_Pane(
        streak_pane: Int,
        records_pane: [(date: String, checked: Bool, isToday: Bool)],
        checkedToday_pane: Bool,
        isLoggedIn_pane: Bool = true
    ) {
        if isLoggedIn_pane {
            // 已登录：右侧显示 "Check In" / "✓ Done" + 箭头
            actionLabel_Pane.isHidden  = false
            chevronIcon_Pane.isHidden  = false
            loginButton_Pane.isHidden  = true

            streakLabel_Pane.text  = streak_pane > 0 ? "\(streak_pane)" : "0"
            actionLabel_Pane.text  = checkedToday_pane ? "✓ Done" : "Check In"
            renderDots_Pane(records_pane: records_pane)
        } else {
            // 未登录：右侧显示 Login 按钮，圆点全空态，天数显示 "--"
            actionLabel_Pane.isHidden  = true
            chevronIcon_Pane.isHidden  = true
            loginButton_Pane.isHidden  = false

            streakLabel_Pane.text = "--"
            renderDots_Pane(records_pane: [])    // 空态点
        }
    }

    /// 渲染 7 个圆点状态
    private func renderDots_Pane(records_pane: [(date: String, checked: Bool, isToday: Bool)]) {
        let letters_pane   = ["S", "M", "T", "W", "T", "F", "S"]
        let fallback_pane  = ["M", "T", "W", "T", "F", "S", "S"]
        let cal_pane       = Calendar.current
        let f_pane         = DateFormatter()
        f_pane.dateFormat  = "yyyy-MM-dd"

        for (idx_pane, container_pane) in dotViews_Pane.enumerated() {
            guard let circle_pane = container_pane.subviews.first,
                  let dayLbl_pane = container_pane.subviews.last as? UILabel else { continue }

            if idx_pane < records_pane.count {
                let rec_pane = records_pane[idx_pane]
                if let d_pane = f_pane.date(from: rec_pane.date) {
                    let wd_pane = cal_pane.component(.weekday, from: d_pane)
                    dayLbl_pane.text = letters_pane[safe: wd_pane - 1] ?? fallback_pane[safe: idx_pane] ?? ""
                } else {
                    dayLbl_pane.text = fallback_pane[safe: idx_pane] ?? ""
                }
                if rec_pane.checked {
                    circle_pane.backgroundColor   = UIColor.white.withAlphaComponent(0.9)
                    circle_pane.layer.borderColor = UIColor.clear.cgColor
                    circle_pane.layer.borderWidth = 0
                    addCheckmark_Pane(to: circle_pane)
                } else if rec_pane.isToday {
                    circle_pane.backgroundColor   = UIColor.white.withAlphaComponent(0.15)
                    circle_pane.layer.borderColor = UIColor.white.cgColor
                    circle_pane.layer.borderWidth = 2
                    removeCheckmark_Pane(from: circle_pane)
                } else {
                    circle_pane.backgroundColor   = UIColor.white.withAlphaComponent(0.08)
                    circle_pane.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
                    circle_pane.layer.borderWidth = 1.5
                    removeCheckmark_Pane(from: circle_pane)
                }
            } else {
                // 空态（未登录或无数据）
                dayLbl_pane.text              = fallback_pane[safe: idx_pane] ?? ""
                circle_pane.backgroundColor   = UIColor.white.withAlphaComponent(0.08)
                circle_pane.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
                circle_pane.layer.borderWidth = 1.5
                removeCheckmark_Pane(from: circle_pane)
            }
        }
    }

    private func addCheckmark_Pane(to view_pane: UIView) {
        if view_pane.viewWithTag(99) != nil { return }
        let iv = UIImageView(image: UIImage(systemName: "checkmark"))
        iv.tag          = 99
        iv.tintColor    = UIColor(hexstring_Pane: "#FF7043")
        iv.contentMode  = .scaleAspectFit
        view_pane.addSubview(iv)
        iv.snp.makeConstraints { $0.center.equalToSuperview(); $0.width.height.equalTo(10) }
    }

    private func removeCheckmark_Pane(from view_pane: UIView) {
        view_pane.viewWithTag(99)?.removeFromSuperview()
    }

    // MARK: - 事件

    @objc private func handleTap_Pane() {
        animatePressDown_Pane { self.animatePressUp_Pane { self.onTapped_Pane?() } }
    }
}

// MARK: - Array 安全下标

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
