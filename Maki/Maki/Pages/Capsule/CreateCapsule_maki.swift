import Foundation
import UIKit
import SnapKit

// MARK: - 创建手作时光胶囊页面视图控制器

/// 创建手作时光胶囊页面视图控制器
/// 功能：上传成品实拍、可选制作步骤视频，填写材料清单、心情、赠送对象与背后故事，设置开启时间后封存
/// 设计：与发布页统一的渐变导航 + 卡片表单风格；复用 ReleaseField_Maki / ReleaseTextView_Maki 输入组件
/// 逻辑：封存成功后调用 CapsuleViewModel_Maki.createCapsule_Maki，并返回上一页
class CreateCapsule_Maki: UIViewController {

    // MARK: - 私有常量

    private enum K_Maki {
        static let primary = UIColor(hexstring_Maki: "#9B59B6")
        static let accent  = UIColor(hexstring_Maki: "#6C3483")
        static let bg      = UIColor(hexstring_Maki: "#FFFBF4")
        static let tp      = UIColor(hexstring_Maki: "#1A0A00")
        static let ts      = UIColor(hexstring_Maki: "#8B7355")
        static let moods: [String] = ["😊", "🥰", "😌", "🤔", "😤", "🥳"]
    }

    // MARK: - 状态

    /// 已选取的成品封面图片
    private var coverImage_Maki: UIImage?
    /// 封面保存至 Documents 后的文件名
    private var coverPath_Maki: String?
    /// 制作视频保存至 Documents 后的文件名（可选）
    private var videoPath_Maki: String?
    /// 当前选中的心情索引
    private var selectedMoodIdx_Maki: Int = 0

    // MARK: - UI 属性 / 主容器

    private let scrollView_Maki: UIScrollView = {
        let sv_maki = UIScrollView()
        sv_maki.alwaysBounceVertical = true
        sv_maki.showsVerticalScrollIndicator = false
        sv_maki.contentInsetAdjustmentBehavior = .never
        return sv_maki
    }()
    private let contentView_Maki = UIView()

    // MARK: - UI 属性 / 顶部导航区

    private let navArea_Maki = UIView()
    private let navGrad_Maki = CAGradientLayer()

    // MARK: - UI 属性 / 封面选取区

    private let coverPickerView_Maki = UIView()
    private let coverDisplayView_Maki = MediaDisplayView_Maki()
    private let coverPlaceholder_Maki = UIView()
    private let coverHintLb_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.text = "Add a Photo of Your Creation"
        lb_maki.font = .systemFont(ofSize: 15, weight: .semibold)
        lb_maki.textColor = K_Maki.primary
        lb_maki.textAlignment = .center
        return lb_maki
    }()

    // MARK: - UI 属性 / 视频选取行

    private let videoRow_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = .white
        v_maki.layer.cornerRadius = 14
        v_maki.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        v_maki.layer.shadowOffset = CGSize(width: 0, height: 3)
        v_maki.layer.shadowRadius = 8
        v_maki.layer.shadowOpacity = 1
        v_maki.layer.borderWidth = 1.5
        v_maki.layer.borderColor = UIColor(hexstring_Maki: "#F0EDE6").cgColor
        return v_maki
    }()
    private let videoStatusLb_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.text = "No process video added"
        lb_maki.font = .systemFont(ofSize: 13)
        lb_maki.textColor = UIColor(hexstring_Maki: "#8B7355")
        return lb_maki
    }()
    private let videoAddBtn_Maki: UIButton = {
        let btn_maki = UIButton(type: .system)
        btn_maki.setTitle("Add", for: .normal)
        btn_maki.setTitleColor(.white, for: .normal)
        btn_maki.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        btn_maki.backgroundColor = K_Maki.primary
        btn_maki.layer.cornerRadius = 12
        return btn_maki
    }()

    // MARK: - UI 属性 / 表单字段

    private let materialsField_Maki = ReleaseField_Maki(
        iconName_maki: "list.bullet.clipboard.fill",
        label: "Materials Used",
        placeholder: "e.g. beeswax, cotton fabric, jojoba oil"
    )
    private let giftToField_Maki = ReleaseField_Maki(
        iconName_maki: "gift.fill",
        label: "Made For",
        placeholder: "Yourself, a friend, family..."
    )
    private let storyView_Maki = ReleaseTextView_Maki(
        iconName_maki: "text.quote",
        label: "The Story Behind It",
        placeholder: "What inspired this creation? How did it feel to make it?"
    )

    /// 心情选择行容器
    private let moodCard_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = .white
        v_maki.layer.cornerRadius = 14
        v_maki.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        v_maki.layer.shadowOffset = CGSize(width: 0, height: 3)
        v_maki.layer.shadowRadius = 8
        v_maki.layer.shadowOpacity = 1
        v_maki.layer.borderWidth = 1.5
        v_maki.layer.borderColor = UIColor(hexstring_Maki: "#F0EDE6").cgColor
        return v_maki
    }()
    private var moodButtons_Maki: [UIButton] = []

    // MARK: - UI 属性 / 开启时间

    private let openDateCard_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = .white
        v_maki.layer.cornerRadius = 14
        v_maki.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        v_maki.layer.shadowOffset = CGSize(width: 0, height: 3)
        v_maki.layer.shadowRadius = 8
        v_maki.layer.shadowOpacity = 1
        v_maki.layer.borderWidth = 1.5
        v_maki.layer.borderColor = UIColor(hexstring_Maki: "#F0EDE6").cgColor
        return v_maki
    }()
    private let openDatePicker_Maki: UIDatePicker = {
        let dp_maki = UIDatePicker()
        dp_maki.datePickerMode = .date
        dp_maki.preferredDatePickerStyle = .compact
        dp_maki.minimumDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        dp_maki.date = Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date()
        return dp_maki
    }()

    // MARK: - UI 属性 / 封存按钮

    private let sealBtn_Maki: UIButton = {
        let btn_maki = UIButton(type: .system)
        btn_maki.setTitle("  Seal This Capsule", for: .normal)
        btn_maki.setImage(UIImage(systemName: "shippingbox.fill"), for: .normal)
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
    private let sealGrad_Maki = CAGradientLayer()

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
        navGrad_Maki.frame = navArea_Maki.bounds
        sealGrad_Maki.frame = CGRect(x: 0, y: 0, width: APPSCREEN_Maki.WIDTH_Maki - 40, height: 56)
    }
}

// MARK: - UI 构建

extension CreateCapsule_Maki {

    private func buildUI_Maki() {
        view.addSubview(scrollView_Maki)
        scrollView_Maki.addSubview(contentView_Maki)
        scrollView_Maki.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView_Maki.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Maki.contentLayoutGuide)
            make.width.equalTo(scrollView_Maki.frameLayoutGuide)
        }
        buildNavArea_Maki()
        buildCoverPicker_Maki()
        buildVideoRow_Maki()
        buildFormFields_Maki()
        buildMoodRow_Maki()
        buildOpenDateArea_Maki()
        buildSealButton_Maki()
    }

    /// 构建顶部渐变导航区
    private func buildNavArea_Maki() {
        navGrad_Maki.colors = [
            K_Maki.accent.cgColor,
            K_Maki.primary.cgColor
        ]
        navGrad_Maki.startPoint = CGPoint(x: 0, y: 0)
        navGrad_Maki.endPoint   = CGPoint(x: 1, y: 1)
        navArea_Maki.layer.insertSublayer(navGrad_Maki, at: 0)
        contentView_Maki.addSubview(navArea_Maki)

        let statusH_maki = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 44
        navArea_Maki.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(statusH_maki + 110)
        }

        // 装饰气泡
        let bubble1_maki = UIView()
        bubble1_maki.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        bubble1_maki.layer.cornerRadius = 55
        navArea_Maki.addSubview(bubble1_maki)
        bubble1_maki.snp.makeConstraints { make in
            make.width.height.equalTo(110)
            make.trailing.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(-22)
        }

        // 返回按钮
        let backBtn_maki = UIButton(type: .system)
        backBtn_maki.setImage(UIImage(systemName: "xmark"), for: .normal)
        backBtn_maki.tintColor = .white
        backBtn_maki.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        backBtn_maki.layer.cornerRadius = 17
        backBtn_maki.layer.borderWidth = 1.5
        backBtn_maki.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        backBtn_maki.addTarget(self, action: #selector(onClose_Maki), for: .touchUpInside)
        navArea_Maki.addSubview(backBtn_maki)
        backBtn_maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(18)
            make.top.equalToSuperview().offset(statusH_maki + 8)
            make.width.height.equalTo(34)
        }

        // 标题
        let titleLb_maki = UILabel()
        titleLb_maki.text = "⏳  Time Capsule"
        titleLb_maki.font = UIFont(name: "Georgia-Bold", size: 22) ?? .systemFont(ofSize: 22, weight: .bold)
        titleLb_maki.textColor = .white
        navArea_Maki.addSubview(titleLb_maki)
        titleLb_maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalTo(backBtn_maki).offset(24)
        }

        // 副标题
        let subLb_maki = UILabel()
        subLb_maki.text = "Seal today's creation for future you to rediscover"
        subLb_maki.font = .systemFont(ofSize: 12, weight: .light)
        subLb_maki.textColor = UIColor.white.withAlphaComponent(0.85)
        navArea_Maki.addSubview(subLb_maki)
        subLb_maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(titleLb_maki.snp.bottom).offset(4)
        }

        // 底部圆角过渡条
        let decoBar_maki = UIView()
        decoBar_maki.backgroundColor = K_Maki.bg
        decoBar_maki.layer.cornerRadius = 20
        decoBar_maki.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        navArea_Maki.addSubview(decoBar_maki)
        decoBar_maki.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(24)
        }
    }

    /// 构建成品封面选取区
    private func buildCoverPicker_Maki() {
        coverPickerView_Maki.backgroundColor = UIColor(hexstring_Maki: "#9B59B6").withAlphaComponent(0.06)
        coverPickerView_Maki.layer.cornerRadius = 18
        coverPickerView_Maki.clipsToBounds = true
        contentView_Maki.addSubview(coverPickerView_Maki)
        coverPickerView_Maki.snp.makeConstraints { make in
            make.top.equalTo(navArea_Maki.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(180)
        }

        coverPickerView_Maki.addSubview(coverDisplayView_Maki)
        coverDisplayView_Maki.isHidden = true
        coverDisplayView_Maki.snp.makeConstraints { $0.edges.equalToSuperview() }

        coverPickerView_Maki.addSubview(coverPlaceholder_Maki)
        coverPlaceholder_Maki.snp.makeConstraints { $0.edges.equalToSuperview() }

        let iconWrap_maki = UIView()
        iconWrap_maki.backgroundColor = K_Maki.primary.withAlphaComponent(0.12)
        iconWrap_maki.layer.cornerRadius = 30
        coverPlaceholder_Maki.addSubview(iconWrap_maki)
        let icon_maki = UIImageView(image: UIImage(systemName: "camera.fill"))
        icon_maki.tintColor = K_Maki.primary
        icon_maki.contentMode = .scaleAspectFit
        iconWrap_maki.addSubview(icon_maki)
        iconWrap_maki.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-18)
            make.width.height.equalTo(60)
        }
        icon_maki.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }
        coverPlaceholder_Maki.addSubview(coverHintLb_Maki)
        coverHintLb_Maki.snp.makeConstraints { make in
            make.top.equalTo(iconWrap_maki.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }

        let tap_maki = UITapGestureRecognizer(target: self, action: #selector(onPickCover_Maki))
        coverPickerView_Maki.isUserInteractionEnabled = true
        coverPickerView_Maki.addGestureRecognizer(tap_maki)
    }

    /// 构建制作视频选取行
    private func buildVideoRow_Maki() {
        contentView_Maki.addSubview(videoRow_Maki)
        videoRow_Maki.snp.makeConstraints { make in
            make.top.equalTo(coverPickerView_Maki.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(56)
        }

        let icon_maki = UIImageView(image: UIImage(systemName: "video.fill"))
        icon_maki.tintColor = K_Maki.primary
        icon_maki.contentMode = .scaleAspectFit
        videoRow_Maki.addSubview(icon_maki)
        icon_maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }

        videoRow_Maki.addSubview(videoStatusLb_Maki)
        videoStatusLb_Maki.snp.makeConstraints { make in
            make.leading.equalTo(icon_maki.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
        }

        videoAddBtn_Maki.addTarget(self, action: #selector(onPickVideo_Maki), for: .touchUpInside)
        videoRow_Maki.addSubview(videoAddBtn_Maki)
        videoAddBtn_Maki.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.width.equalTo(56)
            make.height.equalTo(26)
        }
    }

    /// 构建表单字段（材料、赠送对象、故事）
    private func buildFormFields_Maki() {
        contentView_Maki.addSubview(materialsField_Maki)
        materialsField_Maki.snp.makeConstraints { make in
            make.top.equalTo(videoRow_Maki.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(68)
        }

        contentView_Maki.addSubview(giftToField_Maki)
        giftToField_Maki.snp.makeConstraints { make in
            make.top.equalTo(materialsField_Maki.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(68)
        }

        contentView_Maki.addSubview(storyView_Maki)
        storyView_Maki.snp.makeConstraints { make in
            make.top.equalTo(giftToField_Maki.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(110)
        }
    }

    /// 构建心情选择行
    private func buildMoodRow_Maki() {
        contentView_Maki.addSubview(moodCard_Maki)
        moodCard_Maki.snp.makeConstraints { make in
            make.top.equalTo(storyView_Maki.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(74)
        }

        let labelLb_maki = UILabel()
        labelLb_maki.text = "TODAY'S MOOD"
        labelLb_maki.font = .systemFont(ofSize: 10, weight: .bold)
        labelLb_maki.textColor = K_Maki.ts
        moodCard_Maki.addSubview(labelLb_maki)
        labelLb_maki.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(16)
        }

        let stack_maki = UIStackView()
        stack_maki.axis = .horizontal
        stack_maki.distribution = .fillEqually
        stack_maki.spacing = 8
        moodCard_Maki.addSubview(stack_maki)
        stack_maki.snp.makeConstraints { make in
            make.top.equalTo(labelLb_maki.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().offset(-10)
        }

        for (idx_maki, mood_maki) in K_Maki.moods.enumerated() {
            let btn_maki = UIButton(type: .custom)
            btn_maki.setTitle(mood_maki, for: .normal)
            btn_maki.titleLabel?.font = .systemFont(ofSize: 20)
            btn_maki.tag = idx_maki
            btn_maki.layer.cornerRadius = 10
            btn_maki.addTarget(self, action: #selector(onMoodTap_Maki(_:)), for: .touchUpInside)
            stack_maki.addArrangedSubview(btn_maki)
            moodButtons_Maki.append(btn_maki)
        }
        refreshMoodSelection_Maki()
    }

    /// 构建开启时间选择区
    private func buildOpenDateArea_Maki() {
        contentView_Maki.addSubview(openDateCard_Maki)
        openDateCard_Maki.snp.makeConstraints { make in
            make.top.equalTo(moodCard_Maki.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(112)
        }

        let iconIV_maki = UIImageView(image: UIImage(systemName: "hourglass"))
        iconIV_maki.tintColor = K_Maki.primary
        iconIV_maki.contentMode = .scaleAspectFit
        let labelLb_maki = UILabel()
        labelLb_maki.text = "Open Capsule On"
        labelLb_maki.font = .systemFont(ofSize: 13, weight: .bold)
        labelLb_maki.textColor = K_Maki.tp
        openDateCard_Maki.addSubview(iconIV_maki)
        openDateCard_Maki.addSubview(labelLb_maki)
        iconIV_maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(14)
            make.width.height.equalTo(16)
        }
        labelLb_maki.snp.makeConstraints { make in
            make.leading.equalTo(iconIV_maki.snp.trailing).offset(6)
            make.centerY.equalTo(iconIV_maki)
        }

        // 快捷预设按钮
        let sixMoBtn_maki = buildQuickDateBtn_Maki(title_maki: "6 Months")
        let oneYrBtn_maki = buildQuickDateBtn_Maki(title_maki: "1 Year")
        sixMoBtn_maki.addTarget(self, action: #selector(onSixMonths_Maki), for: .touchUpInside)
        oneYrBtn_maki.addTarget(self, action: #selector(onOneYear_Maki), for: .touchUpInside)

        let quickStack_maki = UIStackView(arrangedSubviews: [sixMoBtn_maki, oneYrBtn_maki])
        quickStack_maki.axis = .horizontal
        quickStack_maki.spacing = 8
        openDateCard_Maki.addSubview(quickStack_maki)
        quickStack_maki.snp.makeConstraints { make in
            make.top.equalTo(iconIV_maki.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(28)
        }

        openDateCard_Maki.addSubview(openDatePicker_Maki)
        openDatePicker_Maki.snp.makeConstraints { make in
            make.centerY.equalTo(quickStack_maki)
            make.trailing.equalToSuperview().offset(-14)
        }
    }

    /// 创建快捷日期预设胶囊按钮
    private func buildQuickDateBtn_Maki(title_maki: String) -> UIButton {
        let btn_maki = UIButton(type: .system)
        btn_maki.setTitle(title_maki, for: .normal)
        btn_maki.setTitleColor(K_Maki.primary, for: .normal)
        btn_maki.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        btn_maki.backgroundColor = K_Maki.primary.withAlphaComponent(0.1)
        btn_maki.layer.cornerRadius = 14
        btn_maki.contentEdgeInsets = UIEdgeInsets(top: 6, left: 14, bottom: 6, right: 14)
        return btn_maki
    }

    /// 构建封存按钮
    private func buildSealButton_Maki() {
        sealGrad_Maki.colors = [
            K_Maki.primary.cgColor,
            K_Maki.accent.cgColor
        ]
        sealGrad_Maki.startPoint = CGPoint(x: 0, y: 0.5)
        sealGrad_Maki.endPoint   = CGPoint(x: 1, y: 0.5)
        sealGrad_Maki.cornerRadius = 16
        sealGrad_Maki.frame = CGRect(x: 0, y: 0, width: APPSCREEN_Maki.WIDTH_Maki - 40, height: 56)
        sealBtn_Maki.layer.insertSublayer(sealGrad_Maki, at: 0)

        contentView_Maki.addSubview(sealBtn_Maki)
        sealBtn_Maki.snp.makeConstraints { make in
            make.top.equalTo(openDateCard_Maki.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-48)
        }
        sealBtn_Maki.addTarget(self, action: #selector(onSeal_Maki), for: .touchUpInside)
    }
}

// MARK: - 事件响应

extension CreateCapsule_Maki {

    @objc private func onClose_Maki() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Navigation_Maki.pop_Maki()
    }

    /// 选取成品封面照片
    @objc private func onPickCover_Maki() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        MediaPickerHelper_Maki.pickImage_Maki(from: self) { [weak self] image_maki in
            guard let self, let img_maki = image_maki else { return }
            self.coverImage_Maki = img_maki
            self.coverDisplayView_Maki.configureWithImage_Maki(image_Maki: img_maki)
            self.coverDisplayView_Maki.isHidden = false
            self.coverPlaceholder_Maki.isHidden = true
            self.coverPath_Maki = self.saveImageToDocuments_Maki(img_maki, prefix_maki: "capsule_cover")
        }
    }

    /// 选取制作步骤视频（可选）
    @objc private func onPickVideo_Maki() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        MediaPickerHelper_Maki.pickVideo_Maki(from: self) { [weak self] url_maki in
            guard let self, let url_maki else { return }
            self.videoPath_Maki = self.saveVideoToDocuments_Maki(url_maki)
            self.videoStatusLb_Maki.text = "Process video added ✓"
            self.videoAddBtn_Maki.setTitle("Change", for: .normal)
        }
    }

    /// 心情选择
    @objc private func onMoodTap_Maki(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        selectedMoodIdx_Maki = sender.tag
        refreshMoodSelection_Maki()
    }

    /// 刷新心情按钮选中态样式
    private func refreshMoodSelection_Maki() {
        for btn_maki in moodButtons_Maki {
            btn_maki.backgroundColor = btn_maki.tag == selectedMoodIdx_Maki
                ? K_Maki.primary.withAlphaComponent(0.15)
                : .clear
        }
    }

    @objc private func onSixMonths_Maki() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        openDatePicker_Maki.date = Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date()
    }

    @objc private func onOneYear_Maki() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        openDatePicker_Maki.date = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    }

    /// 封存胶囊
    @objc private func onSeal_Maki() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        UIView.animate(withDuration: 0.1, animations: {
            self.sealBtn_Maki.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }, completion: { _ in
            UIView.animate(withDuration: 0.15) { self.sealBtn_Maki.transform = .identity }
        })

        guard UserViewModel_Maki.shared_Maki.isLoggedIn_Maki else {
            Load_Maki.showWarning_Maki(message_Maki: "Please log in first")
            Navigation_Maki.toLogin_Maki(style_maki: .present_maki)
            return
        }
        guard let coverPath_maki = coverPath_Maki else {
            Load_Maki.showWarning_Maki(message_Maki: "Please add a photo of your creation")
            return
        }
        let materials_maki = materialsField_Maki.currentValue_Maki
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        guard !materials_maki.isEmpty else {
            Load_Maki.showWarning_Maki(message_Maki: "Please list at least one material")
            return
        }
        let giftTo_maki = giftToField_Maki.currentValue_Maki.trimmingCharacters(in: .whitespaces)
        guard !giftTo_maki.isEmpty else {
            Load_Maki.showWarning_Maki(message_Maki: "Please tell us who this is for")
            return
        }
        let story_maki = storyView_Maki.currentValue_Maki.trimmingCharacters(in: .whitespaces)
        guard !story_maki.isEmpty else {
            Load_Maki.showWarning_Maki(message_Maki: "Please share the story behind it")
            return
        }

        CapsuleViewModel_Maki.shared_Maki.createCapsule_Maki(
            coverMedia_maki: coverPath_maki,
            videoPath_maki: videoPath_Maki,
            materials_maki: materials_maki,
            mood_maki: K_Maki.moods[selectedMoodIdx_Maki],
            giftTo_maki: giftTo_maki,
            story_maki: story_maki,
            openDate_maki: openDatePicker_Maki.date
        )
        Navigation_Maki.pop_Maki()
    }

    /// 保存图片到 Documents 目录，返回文件名
    private func saveImageToDocuments_Maki(_ image_maki: UIImage, prefix_maki: String) -> String {
        let filename_maki = "\(prefix_maki)_\(Int(Date().timeIntervalSince1970)).jpg"
        let url_maki = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename_maki)
        if let data_maki = image_maki.jpegData(compressionQuality: 0.85) {
            try? data_maki.write(to: url_maki)
        }
        return filename_maki
    }

    /// 将临时视频复制到 Documents 目录，返回文件名
    private func saveVideoToDocuments_Maki(_ tempURL_maki: URL) -> String {
        let filename_maki = "capsule_video_\(Int(Date().timeIntervalSince1970)).\(tempURL_maki.pathExtension)"
        let destURL_maki = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename_maki)
        try? FileManager.default.copyItem(at: tempURL_maki, to: destURL_maki)
        return filename_maki
    }
}
