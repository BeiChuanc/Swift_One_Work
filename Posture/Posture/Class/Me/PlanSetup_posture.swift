import Foundation
import UIKit
import SnapKit

// MARK: 体态档案设置页

/// 体态档案设置控制器
/// 核心作用：引导用户填写体态短板（多选）、每日久坐时长、运动基础，保存后生成个性化每日推荐。
/// 设计思路：使用自定义顶部导航栏，完全脱离系统 Navigation Bar 状态机干扰。
///          纯 UI 表单，保存逻辑委托给 UserViewModel_Posture.savePlanProfile_Posture()。
/// 关键属性：selectedWeaknesses_Posture 存储已勾选短板，sittingHours_Posture 存储久坐时长。
@MainActor
class PlanSetup_Posture: UIViewController {

    // MARK: - 状态属性

    /// 已选短板集合
    private var selectedWeaknesses_Posture: Set<String> = []

    /// 当前久坐时长（小时）
    private var sittingHours_Posture: Int = 8

    /// 当前运动基础
    private var selectedLevel_Posture: String = FitnessLevel_Posture.beginner_posture.rawValue

    // MARK: - UI 组件

    /// 自定义顶部导航栏
    private let customNavBar_Posture = UIView()

    private let scrollView_Posture = UIScrollView()
    private let contentView_Posture = UIView()

    /// 短板勾选按钮组（按 PostureWeakness_Posture.allCases 顺序）
    private var weaknessButtons_Posture: [UIButton] = []

    /// 久坐时长显示标签
    private let hoursValueLabel_Posture = UILabel()

    /// 久坐时长步进控件
    private let hoursStepper_Posture = UIStepper()

    /// 运动基础选择按钮组
    private var levelButtons_Posture: [UIButton] = []

    /// 保存按钮
    private let saveButton_Posture = UIButton(type: .system)

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomNavBar_Posture()
        setupUI_Posture()
        loadExistingProfile_Posture()
    }

    // MARK: - 自定义导航栏

    /// 搭建自定义顶部导航栏（背景 + 返回按钮 + 标题）
    private func setupCustomNavBar_Posture() {
        // 与页面背景色保持一致，去除阴影避免割裂感
        customNavBar_Posture.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture
        view.addSubview(customNavBar_Posture)

        customNavBar_Posture.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }

        // 返回按钮
        let backBtn_Posture = UIButton(type: .system)
        let backConfig_Posture = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        backBtn_Posture.setImage(UIImage(systemName: "chevron.left", withConfiguration: backConfig_Posture), for: .normal)
        backBtn_Posture.tintColor = ColorConfig_Posture.textPrimary_Posture
        backBtn_Posture.addAction(UIAction { _ in Navigation_Posture.pop_Posture() }, for: .touchUpInside)
        customNavBar_Posture.addSubview(backBtn_Posture)

        backBtn_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }

        // 标题
        let titleLabel_Posture = UILabel()
        titleLabel_Posture.text = "My Posture Profile"
        titleLabel_Posture.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel_Posture.textColor = ColorConfig_Posture.textPrimary_Posture
        titleLabel_Posture.textAlignment = .center
        customNavBar_Posture.addSubview(titleLabel_Posture)

        titleLabel_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualTo(backBtn_Posture.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualToSuperview().inset(60)
        }
    }

    // MARK: - UI 搭建

    /// 搭建整体页面布局（ScrollView + 三大表单区块 + 保存按钮）
    private func setupUI_Posture() {
        view.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture

        scrollView_Posture.showsVerticalScrollIndicator = false
        view.addSubview(scrollView_Posture)
        scrollView_Posture.addSubview(contentView_Posture)

        scrollView_Posture.snp.makeConstraints { make in
            make.top.equalTo(customNavBar_Posture.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

        contentView_Posture.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Posture.contentLayoutGuide)
            make.width.equalTo(scrollView_Posture.frameLayoutGuide)
        }

        let stack_Posture = UIStackView()
        stack_Posture.axis = .vertical
        stack_Posture.spacing = 20
        stack_Posture.alignment = .fill
        contentView_Posture.addSubview(stack_Posture)
        stack_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.trailing.equalToSuperview().inset(18)
            make.bottom.equalToSuperview().inset(30)
        }

        stack_Posture.addArrangedSubview(buildSectionCard_Posture(
            title_posture: "What are your posture weak spots?",
            subtitle_posture: "Select all that apply",
            body_posture: buildWeaknessPanel_Posture()
        ))

        stack_Posture.addArrangedSubview(buildSectionCard_Posture(
            title_posture: "Daily sitting hours",
            subtitle_posture: "How long do you sit per day?",
            body_posture: buildHoursPanel_Posture()
        ))

        stack_Posture.addArrangedSubview(buildSectionCard_Posture(
            title_posture: "Fitness background",
            subtitle_posture: "Helps us set the right intensity",
            body_posture: buildLevelPanel_Posture()
        ))

        // 保存按钮
        saveButton_Posture.setTitle("Save My Plan", for: .normal)
        saveButton_Posture.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        saveButton_Posture.setTitleColor(.white, for: .normal)
        saveButton_Posture.layer.cornerRadius = 26
        saveButton_Posture.backgroundColor = ColorConfig_Posture.primaryGradientStart_Posture
        saveButton_Posture.layer.shadowColor = ColorConfig_Posture.primaryGradientStart_Posture.withAlphaComponent(0.4).cgColor
        saveButton_Posture.layer.shadowOpacity = 1
        saveButton_Posture.layer.shadowRadius = 12
        saveButton_Posture.layer.shadowOffset = CGSize(width: 0, height: 6)
        saveButton_Posture.addAction(UIAction { [weak self] _ in self?.handleSave_Posture() }, for: .touchUpInside)
        stack_Posture.addArrangedSubview(saveButton_Posture)
        saveButton_Posture.snp.makeConstraints { make in make.height.equalTo(52) }
    }

    /// 构建区块卡片容器
    /// - Parameters:
    ///   - title_posture: 区块标题
    ///   - subtitle_posture: 区块副标题
    ///   - body_posture: 内部内容视图
    /// - Returns: UIView
    private func buildSectionCard_Posture(title_posture: String, subtitle_posture: String, body_posture: UIView) -> UIView {
        let card_Posture = UIView()
        card_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        card_Posture.layer.cornerRadius = 22
        card_Posture.layer.shadowColor = ColorConfig_Posture.shadowColor_Posture.cgColor
        card_Posture.layer.shadowOpacity = 1
        card_Posture.layer.shadowRadius = 12
        card_Posture.layer.shadowOffset = CGSize(width: 0, height: 4)

        let titleLabel_Posture = UILabel()
        titleLabel_Posture.text = title_posture
        titleLabel_Posture.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel_Posture.textColor = ColorConfig_Posture.textPrimary_Posture

        let subtitleLabel_Posture = UILabel()
        subtitleLabel_Posture.text = subtitle_posture
        subtitleLabel_Posture.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel_Posture.textColor = ColorConfig_Posture.textSecondary_Posture

        card_Posture.addSubview(titleLabel_Posture)
        card_Posture.addSubview(subtitleLabel_Posture)
        card_Posture.addSubview(body_posture)

        titleLabel_Posture.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(18)
            make.trailing.equalToSuperview().inset(18)
        }
        subtitleLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Posture.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(18)
        }
        body_posture.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel_Posture.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(18)
            make.bottom.equalToSuperview().inset(18)
        }

        return card_Posture
    }

    /// 构建体态短板多选面板（2列网格）
    private func buildWeaknessPanel_Posture() -> UIView {
        let container_Posture = UIView()
        let leftCol_Posture = UIStackView()
        leftCol_Posture.axis = .vertical
        leftCol_Posture.spacing = 10
        let rightCol_Posture = UIStackView()
        rightCol_Posture.axis = .vertical
        rightCol_Posture.spacing = 10

        for (idx_posture, weakness_posture) in PostureWeakness_Posture.allCases.enumerated() {
            let btn_Posture = makeCheckButton_Posture(label_posture: weakness_posture.rawValue, tag_posture: idx_posture)
            weaknessButtons_Posture.append(btn_Posture)
            if idx_posture % 2 == 0 {
                leftCol_Posture.addArrangedSubview(btn_Posture)
            } else {
                rightCol_Posture.addArrangedSubview(btn_Posture)
            }
        }

        let rowStack_Posture = UIStackView(arrangedSubviews: [leftCol_Posture, rightCol_Posture])
        rowStack_Posture.axis = .horizontal
        rowStack_Posture.spacing = 10
        rowStack_Posture.distribution = .fillEqually
        container_Posture.addSubview(rowStack_Posture)
        rowStack_Posture.snp.makeConstraints { make in make.edges.equalToSuperview() }
        return container_Posture
    }

    /// 创建单个短板勾选按钮
    /// - Parameters:
    ///   - label_posture: 显示文本
    ///   - tag_posture: 对应 PostureWeakness_Posture.allCases 下标
    /// - Returns: UIButton
    private func makeCheckButton_Posture(label_posture: String, tag_posture: Int) -> UIButton {
        let btn_Posture = UIButton(type: .system)
        btn_Posture.tag = tag_posture
        btn_Posture.setTitle(label_posture, for: .normal)
        btn_Posture.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        btn_Posture.setTitleColor(ColorConfig_Posture.textSecondary_Posture, for: .normal)
        btn_Posture.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture
        btn_Posture.layer.cornerRadius = 14
        btn_Posture.layer.borderWidth = 1.5
        btn_Posture.layer.borderColor = ColorConfig_Posture.border_Posture.cgColor
        btn_Posture.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        btn_Posture.addAction(UIAction { [weak self] _ in self?.toggleWeakness_Posture(button_posture: btn_Posture) }, for: .touchUpInside)
        btn_Posture.snp.makeConstraints { make in make.height.equalTo(44) }
        return btn_Posture
    }

    /// 构建久坐时长面板（步进器）
    private func buildHoursPanel_Posture() -> UIView {
        let container_Posture = UIView()

        hoursValueLabel_Posture.text = "\(sittingHours_Posture) hours / day"
        hoursValueLabel_Posture.font = .systemFont(ofSize: 22, weight: .bold)
        hoursValueLabel_Posture.textColor = ColorConfig_Posture.primaryGradientStart_Posture

        hoursStepper_Posture.minimumValue = 1
        hoursStepper_Posture.maximumValue = 16
        hoursStepper_Posture.stepValue = 1
        hoursStepper_Posture.value = Double(sittingHours_Posture)
        hoursStepper_Posture.tintColor = ColorConfig_Posture.primaryGradientStart_Posture
        hoursStepper_Posture.addAction(UIAction { [weak self] _ in self?.handleStepperChange_Posture() }, for: .valueChanged)

        container_Posture.addSubview(hoursValueLabel_Posture)
        container_Posture.addSubview(hoursStepper_Posture)

        hoursValueLabel_Posture.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
        }
        hoursStepper_Posture.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        container_Posture.snp.makeConstraints { make in make.height.equalTo(48) }
        return container_Posture
    }

    /// 构建运动基础单选面板（水平排列）
    private func buildLevelPanel_Posture() -> UIView {
        let stack_Posture = UIStackView()
        stack_Posture.axis = .horizontal
        stack_Posture.spacing = 10
        stack_Posture.distribution = .fillEqually

        for (idx_posture, level_posture) in FitnessLevel_Posture.allCases.enumerated() {
            let btn_Posture = UIButton(type: .system)
            btn_Posture.tag = idx_posture
            btn_Posture.setTitle(level_posture.rawValue, for: .normal)
            btn_Posture.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
            btn_Posture.setTitleColor(ColorConfig_Posture.textSecondary_Posture, for: .normal)
            btn_Posture.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture
            btn_Posture.layer.cornerRadius = 14
            btn_Posture.layer.borderWidth = 1.5
            btn_Posture.layer.borderColor = ColorConfig_Posture.border_Posture.cgColor
            btn_Posture.addAction(UIAction { [weak self] _ in
                self?.selectLevel_Posture(button_posture: btn_Posture, level_posture: level_posture.rawValue)
            }, for: .touchUpInside)
            btn_Posture.snp.makeConstraints { make in make.height.equalTo(44) }
            levelButtons_Posture.append(btn_Posture)
            stack_Posture.addArrangedSubview(btn_Posture)
        }

        // 默认选中第一个
        if let first_Posture = levelButtons_Posture.first {
            applySelectedStyle_Posture(button_posture: first_Posture, selected_posture: true)
        }

        return stack_Posture
    }

    // MARK: - 加载已有档案

    /// 读取已有档案并回填 UI 状态
    private func loadExistingProfile_Posture() {
        guard let profile_posture = UserViewModel_Posture.shared_Posture.getPlanProfile_Posture() else { return }

        // 回填短板
        for weakness_posture in profile_posture.weaknesses_Posture {
            if let idx_posture = PostureWeakness_Posture.allCases.firstIndex(where: { $0.rawValue == weakness_posture }),
               idx_posture < weaknessButtons_Posture.count {
                selectedWeaknesses_Posture.insert(weakness_posture)
                applySelectedStyle_Posture(button_posture: weaknessButtons_Posture[idx_posture], selected_posture: true)
            }
        }

        // 回填久坐时长
        sittingHours_Posture = profile_posture.dailySittingHours_Posture
        hoursStepper_Posture.value = Double(sittingHours_Posture)
        hoursValueLabel_Posture.text = "\(sittingHours_Posture) hours / day"

        // 回填运动基础
        selectedLevel_Posture = profile_posture.fitnessLevel_Posture
        for (idx_posture, level_posture) in FitnessLevel_Posture.allCases.enumerated() {
            guard idx_posture < levelButtons_Posture.count else { continue }
            applySelectedStyle_Posture(
                button_posture: levelButtons_Posture[idx_posture],
                selected_posture: level_posture.rawValue == selectedLevel_Posture
            )
        }
    }

    // MARK: - 事件处理

    /// 切换短板勾选状态
    /// - Parameter button_posture: 被点击的短板按钮
    private func toggleWeakness_Posture(button_posture: UIButton) {
        let idx_posture = button_posture.tag
        guard idx_posture < PostureWeakness_Posture.allCases.count else { return }
        let rawValue_posture = PostureWeakness_Posture.allCases[idx_posture].rawValue
        button_posture.animatePulse_Posture()
        if selectedWeaknesses_Posture.contains(rawValue_posture) {
            selectedWeaknesses_Posture.remove(rawValue_posture)
            applySelectedStyle_Posture(button_posture: button_posture, selected_posture: false)
        } else {
            selectedWeaknesses_Posture.insert(rawValue_posture)
            applySelectedStyle_Posture(button_posture: button_posture, selected_posture: true)
        }
    }

    /// 步进器值变化处理
    private func handleStepperChange_Posture() {
        sittingHours_Posture = Int(hoursStepper_Posture.value)
        hoursValueLabel_Posture.text = "\(sittingHours_Posture) hours / day"
    }

    /// 选择运动基础等级
    /// - Parameters:
    ///   - button_posture: 被点击的等级按钮
    ///   - level_posture: 等级 rawValue
    private func selectLevel_Posture(button_posture: UIButton, level_posture: String) {
        selectedLevel_Posture = level_posture
        button_posture.animatePulse_Posture()
        levelButtons_Posture.forEach { btn_posture in
            applySelectedStyle_Posture(button_posture: btn_posture, selected_posture: btn_posture === button_posture)
        }
    }

    /// 保存档案并返回上一页
    private func handleSave_Posture() {
        guard !selectedWeaknesses_Posture.isEmpty else {
            Utils_Posture.showWarning_Posture(message_Posture: "Please select at least one weak spot.")
            return
        }
        let profile_posture = PosturePlanProfile_Posture(
            weaknesses_Posture: Array(selectedWeaknesses_Posture),
            dailySittingHours_Posture: sittingHours_Posture,
            fitnessLevel_Posture: selectedLevel_Posture
        )
        saveButton_Posture.animatePressDown_Posture { [weak self] in
            self?.saveButton_Posture.animatePressUp_Posture()
        }
        UserViewModel_Posture.shared_Posture.savePlanProfile_Posture(profile_posture: profile_posture)
        Utils_Posture.showSuccess_Posture(
            message_Posture: "Profile saved! Your daily plan is ready.",
            image_Posture: UIImage(systemName: "checkmark.circle.fill")
        )
        Navigation_Posture.pop_Posture()
    }

    // MARK: - 样式辅助

    /// 应用选中/未选中样式到按钮
    /// - Parameters:
    ///   - button_posture: 目标按钮
    ///   - selected_posture: 是否选中
    private func applySelectedStyle_Posture(button_posture: UIButton, selected_posture: Bool) {
        if selected_posture {
            button_posture.backgroundColor = ColorConfig_Posture.primaryLight_Posture
            button_posture.setTitleColor(ColorConfig_Posture.primaryGradientStart_Posture, for: .normal)
            button_posture.layer.borderColor = ColorConfig_Posture.primaryGradientStart_Posture.cgColor
        } else {
            button_posture.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture
            button_posture.setTitleColor(ColorConfig_Posture.textSecondary_Posture, for: .normal)
            button_posture.layer.borderColor = ColorConfig_Posture.border_Posture.cgColor
        }
    }
}
