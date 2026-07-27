import Foundation
import UIKit
import SnapKit

// MARK: - 成长阶梯与年度海报页面视图控制器

/// 成长阶梯与年度海报页面视图控制器
/// 功能：以竖直阶梯可视化展示"新手入门 → 进阶创作 → 造物大师"三阶段手作技艺成长轨迹
/// 设计：渐变导航区 + 竖直连线阶梯卡片（当前等级高亮）+ 一键生成年度手作纪念海报
/// 逻辑：等级依据 CapsuleViewModel_Maki.currentLevel_Maki 计算；海报离屏渲染后调用系统分享
class GrowthLadder_Maki: UIViewController {

    // MARK: - 私有常量

    private enum K_Maki {
        static let primary = UIColor(hexstring_Maki: "#FF8C00")
        static let accent  = UIColor(hexstring_Maki: "#E8650A")
        static let bg      = UIColor(hexstring_Maki: "#FFFBF4")
        static let tp      = UIColor(hexstring_Maki: "#1A0A00")
        static let ts      = UIColor(hexstring_Maki: "#8B7355")
    }

    // MARK: - UI 属性 / 主容器

    private let scrollView_Maki: UIScrollView = {
        let sv_maki = UIScrollView()
        sv_maki.showsVerticalScrollIndicator = false
        sv_maki.alwaysBounceVertical = true
        sv_maki.contentInsetAdjustmentBehavior = .never
        return sv_maki
    }()
    private let contentView_Maki = UIView()

    // MARK: - UI 属性 / 头部区域

    private let headerView_Maki = UIView()
    private let headerGrad_Maki = CAGradientLayer()

    // MARK: - UI 属性 / 阶梯区

    private let ladderCard_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = .white
        v_maki.layer.cornerRadius = 20
        v_maki.layer.shadowColor = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.12).cgColor
        v_maki.layer.shadowOffset = CGSize(width: 0, height: 4)
        v_maki.layer.shadowRadius = 12
        v_maki.layer.shadowOpacity = 1
        return v_maki
    }()

    // MARK: - UI 属性 / 统计区

    private let statsCard_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = .white
        v_maki.layer.cornerRadius = 18
        v_maki.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        v_maki.layer.shadowOffset = CGSize(width: 0, height: 3)
        v_maki.layer.shadowRadius = 8
        v_maki.layer.shadowOpacity = 1
        return v_maki
    }()

    // MARK: - UI 属性 / 生成海报按钮

    private let posterBtn_Maki: UIButton = {
        let btn_maki = UIButton(type: .system)
        btn_maki.setTitle("  Generate Annual Poster", for: .normal)
        btn_maki.setImage(UIImage(systemName: "sparkles.rectangle.stack.fill"), for: .normal)
        btn_maki.setTitleColor(.white, for: .normal)
        btn_maki.tintColor = .white
        btn_maki.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btn_maki.layer.cornerRadius = 16
        btn_maki.layer.shadowColor = K_Maki.primary.withAlphaComponent(0.4).cgColor
        btn_maki.layer.shadowOffset = CGSize(width: 0, height: 6)
        btn_maki.layer.shadowRadius = 14
        btn_maki.layer.shadowOpacity = 1
        return btn_maki
    }()
    private let posterGrad_Maki = CAGradientLayer()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = K_Maki.bg
        buildUI_Maki()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGrad_Maki.frame = headerView_Maki.bounds
        posterGrad_Maki.frame = CGRect(x: 0, y: 0, width: APPSCREEN_Maki.WIDTH_Maki - 40, height: 56)
    }
}

// MARK: - UI 构建

extension GrowthLadder_Maki {

    private func buildUI_Maki() {
        view.addSubview(scrollView_Maki)
        scrollView_Maki.addSubview(contentView_Maki)
        scrollView_Maki.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView_Maki.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Maki.contentLayoutGuide)
            make.width.equalTo(scrollView_Maki.frameLayoutGuide)
        }
        buildHeader_Maki()
        buildLadder_Maki()
        buildStats_Maki()
        buildPosterButton_Maki()
    }

    /// 构建渐变头部
    private func buildHeader_Maki() {
        let statusH_maki = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 44

        headerGrad_Maki.colors = [
            K_Maki.accent.cgColor,
            K_Maki.primary.cgColor
        ]
        headerGrad_Maki.startPoint = CGPoint(x: 0, y: 0)
        headerGrad_Maki.endPoint   = CGPoint(x: 1, y: 1)
        headerView_Maki.layer.insertSublayer(headerGrad_Maki, at: 0)
        contentView_Maki.addSubview(headerView_Maki)
        headerView_Maki.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(statusH_maki + 108)
        }

        let bubble_maki = UIView()
        bubble_maki.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        bubble_maki.layer.cornerRadius = 60
        headerView_Maki.addSubview(bubble_maki)
        bubble_maki.snp.makeConstraints { make in
            make.width.height.equalTo(120)
            make.trailing.equalToSuperview().offset(28)
            make.top.equalToSuperview().offset(-26)
        }

        let backBtn_maki = UIButton(type: .system)
        backBtn_maki.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        backBtn_maki.tintColor = .white
        backBtn_maki.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        backBtn_maki.layer.cornerRadius = 17
        backBtn_maki.layer.borderWidth = 1.5
        backBtn_maki.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        backBtn_maki.addTarget(self, action: #selector(onBack_Maki), for: .touchUpInside)
        headerView_Maki.addSubview(backBtn_maki)
        backBtn_maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(18)
            make.top.equalToSuperview().offset(statusH_maki + 8)
            make.width.height.equalTo(34)
        }

        let titleLb_maki = UILabel()
        titleLb_maki.text = "📈  Craft Journey"
        titleLb_maki.font = UIFont(name: "Georgia-Bold", size: 22) ?? .systemFont(ofSize: 22, weight: .bold)
        titleLb_maki.textColor = .white
        headerView_Maki.addSubview(titleLb_maki)
        titleLb_maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(backBtn_maki.snp.bottom).offset(16)
        }

        let subLb_maki = UILabel()
        subLb_maki.text = "From small beginnings to master creations"
        subLb_maki.font = .systemFont(ofSize: 12, weight: .light)
        subLb_maki.textColor = UIColor.white.withAlphaComponent(0.85)
        headerView_Maki.addSubview(subLb_maki)
        subLb_maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(titleLb_maki.snp.bottom).offset(4)
        }

        let decoBar_maki = UIView()
        decoBar_maki.backgroundColor = K_Maki.bg
        decoBar_maki.layer.cornerRadius = 20
        decoBar_maki.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        headerView_Maki.addSubview(decoBar_maki)
        decoBar_maki.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(24)
        }
    }

    /// 构建竖直阶梯（新手 → 进阶 → 大师，从下到上排列，当前等级高亮）
    private func buildLadder_Maki() {
        contentView_Maki.addSubview(ladderCard_Maki)
        ladderCard_Maki.snp.makeConstraints { make in
            make.top.equalTo(headerView_Maki.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        let currentLevel_maki = CapsuleViewModel_Maki.shared_Maki.currentLevel_Maki()
        // 从上到下：大师 → 进阶 → 新手（视觉阶梯自顶向下摆放，最高等级在最上方）
        let orderedLevels_maki: [CraftLevel_Maki] = [.advanced_maki, .intermediate_maki, .beginner_maki]

        var prevView_maki: UIView?
        for (idx_maki, level_maki) in orderedLevels_maki.enumerated() {
            let isAchieved_maki = level_maki.rawValue <= currentLevel_maki.rawValue
            let isCurrent_maki  = level_maki == currentLevel_maki
            let row_maki = buildLadderRow_Maki(level_maki: level_maki, isAchieved_maki: isAchieved_maki, isCurrent_maki: isCurrent_maki)
            ladderCard_Maki.addSubview(row_maki)
            row_maki.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(18)
                make.height.equalTo(74)
                if let prev_maki = prevView_maki {
                    make.top.equalTo(prev_maki.snp.bottom)
                } else {
                    make.top.equalToSuperview().offset(16)
                }
                if idx_maki == orderedLevels_maki.count - 1 {
                    make.bottom.equalToSuperview().offset(-16)
                }
            }
            prevView_maki = row_maki
        }
    }

    /// 构建单个阶梯行（图标圆 + 标题 + 副标题 + 完成状态）
    private func buildLadderRow_Maki(level_maki: CraftLevel_Maki, isAchieved_maki: Bool, isCurrent_maki: Bool) -> UIView {
        let row_maki = UIView()

        let circleColor_maki = isAchieved_maki ? K_Maki.primary : UIColor(hexstring_Maki: "#E8DDD0")
        let circle_maki = UIView()
        circle_maki.backgroundColor = isAchieved_maki ? circleColor_maki.withAlphaComponent(0.15) : UIColor(hexstring_Maki: "#F5F1EA")
        circle_maki.layer.cornerRadius = 26
        if isCurrent_maki {
            circle_maki.layer.borderWidth = 2.5
            circle_maki.layer.borderColor = K_Maki.primary.cgColor
        }
        let iconIV_maki = UIImageView(image: UIImage(systemName: level_maki.icon_Maki))
        iconIV_maki.tintColor = isAchieved_maki ? K_Maki.primary : UIColor(hexstring_Maki: "#C0B4A0")
        iconIV_maki.contentMode = .scaleAspectFit
        circle_maki.addSubview(iconIV_maki)
        iconIV_maki.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(24)
        }
        row_maki.addSubview(circle_maki)
        circle_maki.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(52)
        }

        let titleLb_maki = UILabel()
        titleLb_maki.text = level_maki.title_Maki
        titleLb_maki.font = .systemFont(ofSize: 15, weight: .bold)
        titleLb_maki.textColor = isAchieved_maki ? K_Maki.tp : UIColor(hexstring_Maki: "#C0B4A0")
        let subLb_maki = UILabel()
        subLb_maki.text = level_maki.subtitle_Maki
        subLb_maki.font = .systemFont(ofSize: 12)
        subLb_maki.textColor = K_Maki.ts

        row_maki.addSubview(titleLb_maki)
        row_maki.addSubview(subLb_maki)
        titleLb_maki.snp.makeConstraints { make in
            make.leading.equalTo(circle_maki.snp.trailing).offset(14)
            make.top.equalTo(circle_maki.snp.top).offset(2)
            make.trailing.equalToSuperview().offset(-40)
        }
        subLb_maki.snp.makeConstraints { make in
            make.leading.equalTo(titleLb_maki)
            make.top.equalTo(titleLb_maki.snp.bottom).offset(3)
            make.trailing.equalToSuperview()
        }

        // 完成/当前状态角标
        if isCurrent_maki {
            let badge_maki = UILabel()
            badge_maki.text = "NOW"
            badge_maki.font = .systemFont(ofSize: 10, weight: .bold)
            badge_maki.textColor = .white
            badge_maki.backgroundColor = K_Maki.primary
            badge_maki.textAlignment = .center
            badge_maki.layer.cornerRadius = 9
            badge_maki.clipsToBounds = true
            row_maki.addSubview(badge_maki)
            badge_maki.snp.makeConstraints { make in
                make.trailing.equalToSuperview()
                make.centerY.equalToSuperview()
                make.width.equalTo(40)
                make.height.equalTo(18)
            }
        } else if isAchieved_maki {
            let check_maki = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
            check_maki.tintColor = K_Maki.primary
            check_maki.contentMode = .scaleAspectFit
            row_maki.addSubview(check_maki)
            check_maki.snp.makeConstraints { make in
                make.trailing.equalToSuperview()
                make.centerY.equalToSuperview()
                make.width.height.equalTo(20)
            }
        }

        return row_maki
    }

    /// 构建统计信息卡（作品数量 + 距下一等级）
    private func buildStats_Maki() {
        contentView_Maki.addSubview(statsCard_Maki)
        statsCard_Maki.snp.makeConstraints { make in
            make.top.equalTo(ladderCard_Maki.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        let vm_maki = CapsuleViewModel_Maki.shared_Maki
        let count_maki = vm_maki.postsCount_Maki()
        let toNext_maki = vm_maki.postsToNextLevel_Maki()

        let countLb_maki = UILabel()
        countLb_maki.text = "\(count_maki)"
        countLb_maki.font = .systemFont(ofSize: 30, weight: .bold)
        countLb_maki.textColor = K_Maki.primary
        let countCaptionLb_maki = UILabel()
        countCaptionLb_maki.text = "Creations Made"
        countCaptionLb_maki.font = .systemFont(ofSize: 12, weight: .medium)
        countCaptionLb_maki.textColor = K_Maki.ts

        let divider_maki = UIView()
        divider_maki.backgroundColor = UIColor(hexstring_Maki: "#F0EDE6")

        let nextLb_maki = UILabel()
        nextLb_maki.font = .systemFont(ofSize: 13)
        nextLb_maki.textColor = K_Maki.tp
        nextLb_maki.numberOfLines = 2
        nextLb_maki.text = toNext_maki > 0
            ? "Make \(toNext_maki) more creation\(toNext_maki == 1 ? "" : "s") to level up! 🎉"
            : "You've reached the top tier! 👑"

        statsCard_Maki.addSubview(countLb_maki)
        statsCard_Maki.addSubview(countCaptionLb_maki)
        statsCard_Maki.addSubview(divider_maki)
        statsCard_Maki.addSubview(nextLb_maki)

        countLb_maki.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.leading.equalToSuperview().offset(18)
        }
        countCaptionLb_maki.snp.makeConstraints { make in
            make.top.equalTo(countLb_maki.snp.bottom).offset(2)
            make.leading.equalTo(countLb_maki)
            make.bottom.equalToSuperview().offset(-18)
        }
        divider_maki.snp.makeConstraints { make in
            make.leading.equalTo(countLb_maki.snp.trailing).offset(20)
            make.top.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
            make.width.equalTo(1)
        }
        nextLb_maki.snp.makeConstraints { make in
            make.leading.equalTo(divider_maki.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }

    /// 构建生成年度海报按钮
    private func buildPosterButton_Maki() {
        posterGrad_Maki.colors = [
            K_Maki.primary.cgColor,
            K_Maki.accent.cgColor
        ]
        posterGrad_Maki.startPoint = CGPoint(x: 0, y: 0.5)
        posterGrad_Maki.endPoint   = CGPoint(x: 1, y: 0.5)
        posterGrad_Maki.cornerRadius = 16
        posterGrad_Maki.frame = CGRect(x: 0, y: 0, width: APPSCREEN_Maki.WIDTH_Maki - 40, height: 56)
        posterBtn_Maki.layer.insertSublayer(posterGrad_Maki, at: 0)

        contentView_Maki.addSubview(posterBtn_Maki)
        posterBtn_Maki.snp.makeConstraints { make in
            make.top.equalTo(statsCard_Maki.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-48)
        }
        posterBtn_Maki.addTarget(self, action: #selector(onGeneratePoster_Maki), for: .touchUpInside)
    }
}

// MARK: - 事件响应

extension GrowthLadder_Maki {

    @objc private func onBack_Maki() {
        Navigation_Maki.pop_Maki()
    }

    /// 生成年度手作纪念海报并弹出系统分享面板
    @objc private func onGeneratePoster_Maki() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        UIView.animate(withDuration: 0.1, animations: {
            self.posterBtn_Maki.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }, completion: { _ in
            UIView.animate(withDuration: 0.15) { self.posterBtn_Maki.transform = .identity }
        })

        let posterView_maki = buildPosterView_Maki()
        let posterImage_maki = renderView_Maki(posterView_maki)
        let activityVC_maki = UIActivityViewController(activityItems: [posterImage_maki], applicationActivities: nil)
        present(activityVC_maki, animated: true)
    }

    /// 构建离屏年度海报视图（固定尺寸，手动布局，不依赖 Auto Layout）
    private func buildPosterView_Maki() -> UIView {
        let size_maki = CGSize(width: 340, height: 500)
        let container_maki = UIView(frame: CGRect(origin: .zero, size: size_maki))
        container_maki.backgroundColor = K_Maki.bg

        let grad_maki = CAGradientLayer()
        grad_maki.frame = container_maki.bounds
        grad_maki.colors = [K_Maki.accent.cgColor, K_Maki.primary.cgColor]
        grad_maki.startPoint = CGPoint(x: 0, y: 0)
        grad_maki.endPoint   = CGPoint(x: 1, y: 1)
        container_maki.layer.addSublayer(grad_maki)

        // 装饰气泡
        let bubble_maki = UIView(frame: CGRect(x: size_maki.width - 90, y: -30, width: 120, height: 120))
        bubble_maki.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        bubble_maki.layer.cornerRadius = 60
        container_maki.addSubview(bubble_maki)

        // 年份标题
        let year_maki = Calendar.current.component(.year, from: Date())
        let yearLb_maki = UILabel(frame: CGRect(x: 24, y: 34, width: size_maki.width - 48, height: 20))
        yearLb_maki.text = "\(year_maki) ANNUAL RECAP"
        yearLb_maki.font = .systemFont(ofSize: 12, weight: .bold)
        yearLb_maki.textColor = UIColor.white.withAlphaComponent(0.85)
        container_maki.addSubview(yearLb_maki)

        // 品牌 Logo
        let logoLb_maki = UILabel(frame: CGRect(x: 24, y: 58, width: size_maki.width - 48, height: 40))
        logoLb_maki.text = "✦ Maki"
        logoLb_maki.font = UIFont(name: "Georgia-Bold", size: 30) ?? .systemFont(ofSize: 30, weight: .bold)
        logoLb_maki.textColor = .white
        container_maki.addSubview(logoLb_maki)

        // 白色信息卡
        let cardFrame_maki = CGRect(x: 24, y: 118, width: size_maki.width - 48, height: size_maki.height - 118 - 32)
        let card_maki = UIView(frame: cardFrame_maki)
        card_maki.backgroundColor = .white
        card_maki.layer.cornerRadius = 24
        container_maki.addSubview(card_maki)

        let level_maki = CapsuleViewModel_Maki.shared_Maki.currentLevel_Maki()
        let count_maki = CapsuleViewModel_Maki.shared_Maki.postsCount_Maki()
        let userName_maki = UserViewModel_Maki.shared_Maki.getCurrentUser_Maki().userName_Maki ?? "Maker"

        // 等级图标圆
        let iconWrap_maki = UIView(frame: CGRect(x: (cardFrame_maki.width - 76) / 2, y: 28, width: 76, height: 76))
        iconWrap_maki.backgroundColor = K_Maki.primary.withAlphaComponent(0.12)
        iconWrap_maki.layer.cornerRadius = 38
        card_maki.addSubview(iconWrap_maki)
        let iconIV_maki = UIImageView(frame: CGRect(x: 22, y: 22, width: 32, height: 32))
        iconIV_maki.image = UIImage(systemName: level_maki.icon_Maki)
        iconIV_maki.tintColor = K_Maki.primary
        iconIV_maki.contentMode = .scaleAspectFit
        iconWrap_maki.addSubview(iconIV_maki)

        // 姓名
        let nameLb_maki = UILabel(frame: CGRect(x: 16, y: 116, width: cardFrame_maki.width - 32, height: 24))
        nameLb_maki.text = userName_maki
        nameLb_maki.font = .systemFont(ofSize: 18, weight: .bold)
        nameLb_maki.textColor = K_Maki.tp
        nameLb_maki.textAlignment = .center
        card_maki.addSubview(nameLb_maki)

        // 等级标题
        let levelLb_maki = UILabel(frame: CGRect(x: 16, y: 144, width: cardFrame_maki.width - 32, height: 20))
        levelLb_maki.text = level_maki.title_Maki
        levelLb_maki.font = .systemFont(ofSize: 14, weight: .semibold)
        levelLb_maki.textColor = K_Maki.primary
        levelLb_maki.textAlignment = .center
        card_maki.addSubview(levelLb_maki)

        // 分割线
        let divider_maki = UIView(frame: CGRect(x: 16, y: 178, width: cardFrame_maki.width - 32, height: 1))
        divider_maki.backgroundColor = UIColor(hexstring_Maki: "#F0EDE6")
        card_maki.addSubview(divider_maki)

        // 统计数字
        let countLb_maki = UILabel(frame: CGRect(x: 16, y: 196, width: cardFrame_maki.width - 32, height: 40))
        countLb_maki.text = "\(count_maki)"
        countLb_maki.font = .systemFont(ofSize: 34, weight: .bold)
        countLb_maki.textColor = K_Maki.tp
        countLb_maki.textAlignment = .center
        card_maki.addSubview(countLb_maki)

        let countCaptionLb_maki = UILabel(frame: CGRect(x: 16, y: 238, width: cardFrame_maki.width - 32, height: 18))
        countCaptionLb_maki.text = "Handmade Creations This Year"
        countCaptionLb_maki.font = .systemFont(ofSize: 11, weight: .medium)
        countCaptionLb_maki.textColor = K_Maki.ts
        countCaptionLb_maki.textAlignment = .center
        card_maki.addSubview(countCaptionLb_maki)

        // 励志语
        let quoteLb_maki = UILabel(frame: CGRect(x: 16, y: cardFrame_maki.height - 56, width: cardFrame_maki.width - 32, height: 40))
        quoteLb_maki.text = "\u{201C}Every creation tells a story.\u{201D}"
        quoteLb_maki.font = UIFont(name: "Georgia-Italic", size: 13) ?? .italicSystemFont(ofSize: 13)
        quoteLb_maki.textColor = K_Maki.ts
        quoteLb_maki.textAlignment = .center
        quoteLb_maki.numberOfLines = 2
        card_maki.addSubview(quoteLb_maki)

        return container_maki
    }

    /// 将指定视图离屏渲染为 UIImage
    private func renderView_Maki(_ view_maki: UIView) -> UIImage {
        let renderer_maki = UIGraphicsImageRenderer(bounds: view_maki.bounds)
        return renderer_maki.image { ctx_maki in
            view_maki.layer.render(in: ctx_maki.cgContext)
        }
    }
}
