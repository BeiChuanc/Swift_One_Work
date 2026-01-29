import Foundation
import UIKit
import SnapKit

// MARK: 日期情绪详情弹窗

/// 日期情绪详情弹窗
/// 功能：展示选中日期的所有情绪记录
/// 设计：半透明背景、圆角卡片、列表展示
class DayEmotionDetailView_Wanderbell: UIView {
    
    // MARK: - UI组件
    
    /// 背景遮罩
    private let overlayView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view_wanderbell.alpha = 0
        return view_wanderbell
    }()
    
    /// 内容容器
    private let containerView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.backgroundColor = .white
        view_wanderbell.layer.cornerRadius = 24
        view_wanderbell.layer.shadowColor = UIColor.black.cgColor
        view_wanderbell.layer.shadowOffset = CGSize(width: 0, height: 8)
        view_wanderbell.layer.shadowRadius = 24
        view_wanderbell.layer.shadowOpacity = 0.3
        return view_wanderbell
    }()
    
    /// 关闭按钮
    private let closeButton_Wanderbell: UIButton = {
        let button_wanderbell = UIButton(type: .custom)
        button_wanderbell.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button_wanderbell.tintColor = ColorConfig_Wanderbell.textPlaceholder_Wanderbell
        return button_wanderbell
    }()
    
    /// 日期标题
    private let dateTitleLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = FontConfig_Wanderbell.title2_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        label_wanderbell.textAlignment = .center
        return label_wanderbell
    }()
    
    /// 情绪概览标签
    private let emotionSummaryLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = FontConfig_Wanderbell.subheadline_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        label_wanderbell.textAlignment = .center
        return label_wanderbell
    }()
    
    /// 情绪图标展示视图
    private let emotionIconsView_Wanderbell: UIStackView = {
        let stack_wanderbell = UIStackView()
        stack_wanderbell.axis = .horizontal
        stack_wanderbell.spacing = 12
        stack_wanderbell.distribution = .fillEqually
        return stack_wanderbell
    }()
    
    /// 记录列表容器
    private let recordsScrollView_Wanderbell: UIScrollView = {
        let scrollView_wanderbell = UIScrollView()
        scrollView_wanderbell.showsVerticalScrollIndicator = true
        return scrollView_wanderbell
    }()
    
    private let recordsStackView_Wanderbell: UIStackView = {
        let stack_wanderbell = UIStackView()
        stack_wanderbell.axis = .vertical
        stack_wanderbell.spacing = 12
        return stack_wanderbell
    }()
    
    // MARK: - 属性
    
    private var selectedDate_Wanderbell: Date
    private var records_Wanderbell: [EmotionRecord_Wanderbell] = []
    
    /// 保存显示弹窗的ViewController引用
    private weak var parentViewController_Wanderbell: UIViewController?
    
    // MARK: - 初始化
    
    init(date_wanderbell: Date) {
        self.selectedDate_Wanderbell = date_wanderbell
        super.init(frame: .zero)
        setupUI_Wanderbell()
        loadData_Wanderbell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    private func setupUI_Wanderbell() {
        addSubview(overlayView_Wanderbell)
        addSubview(containerView_Wanderbell)
        
        containerView_Wanderbell.addSubview(closeButton_Wanderbell)
        containerView_Wanderbell.addSubview(dateTitleLabel_Wanderbell)
        containerView_Wanderbell.addSubview(emotionSummaryLabel_Wanderbell)
        containerView_Wanderbell.addSubview(emotionIconsView_Wanderbell)
        containerView_Wanderbell.addSubview(recordsScrollView_Wanderbell)
        recordsScrollView_Wanderbell.addSubview(recordsStackView_Wanderbell)
        
        overlayView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView_Wanderbell.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(340)
            make.height.equalTo(500)
        }
        
        closeButton_Wanderbell.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(16)
            make.width.height.equalTo(32)
        }
        
        dateTitleLabel_Wanderbell.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        emotionSummaryLabel_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(dateTitleLabel_Wanderbell.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
        }
        
        emotionIconsView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(emotionSummaryLabel_Wanderbell.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(40)
            make.height.equalTo(50)
        }
        
        recordsScrollView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(emotionIconsView_Wanderbell.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        recordsStackView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(recordsScrollView_Wanderbell.snp.width)
        }
        
        closeButton_Wanderbell.addTarget(self, action: #selector(dismiss_Wanderbell), for: .touchUpInside)
        
        // 点击遮罩关闭
        let tapGesture_wanderbell = UITapGestureRecognizer(target: self, action: #selector(dismiss_Wanderbell))
        overlayView_Wanderbell.addGestureRecognizer(tapGesture_wanderbell)
    }
    
    // MARK: - 数据加载
    
    private func loadData_Wanderbell() {
        // 设置日期标题
        let formatter_wanderbell = DateFormatter()
        formatter_wanderbell.dateStyle = .long
        dateTitleLabel_Wanderbell.text = formatter_wanderbell.string(from: selectedDate_Wanderbell)
        
        // 获取该日当前登录用户的所有情绪记录
        let calendar_wanderbell = Calendar.current
        let startOfDay_wanderbell = calendar_wanderbell.startOfDay(for: selectedDate_Wanderbell)
        let endOfDay_wanderbell = calendar_wanderbell.date(byAdding: .day, value: 1, to: startOfDay_wanderbell) ?? startOfDay_wanderbell
        
        let currentUser_wanderbell = UserViewModel_Wanderbell.shared_Wanderbell.getCurrentUser_Wanderbell()
        let userId_wanderbell = currentUser_wanderbell.userId_Wanderbell
        
        records_Wanderbell = EmotionViewModel_Wanderbell.shared_Wanderbell.getRecordsByDateRange_Wanderbell(
            startDate_wanderbell: startOfDay_wanderbell,
            endDate_wanderbell: endOfDay_wanderbell,
            userId_wanderbell: userId_wanderbell
        )
        
        // 更新概览信息
        if records_Wanderbell.isEmpty {
            emotionSummaryLabel_Wanderbell.text = "No records on this day"
            emotionIconsView_Wanderbell.isHidden = true
        } else {
            emotionSummaryLabel_Wanderbell.text = "\(records_Wanderbell.count) emotion record\(records_Wanderbell.count > 1 ? "s" : "")"
            emotionIconsView_Wanderbell.isHidden = false
            updateEmotionIcons_Wanderbell()
        }
        
        // 更新记录列表
        updateRecordsList_Wanderbell()
    }
    
    /// 更新情绪图标展示
    private func updateEmotionIcons_Wanderbell() {
        emotionIconsView_Wanderbell.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 获取所有出现的情绪类型（去重）
        var emotionTypes_wanderbell: [EmotionType_Wanderbell] = []
        for record_wanderbell in records_Wanderbell {
            if !emotionTypes_wanderbell.contains(record_wanderbell.emotionType_Wanderbell) {
                emotionTypes_wanderbell.append(record_wanderbell.emotionType_Wanderbell)
            }
        }
        
        // 最多显示5个图标
        for emotionType_wanderbell in emotionTypes_wanderbell.prefix(5) {
            let iconContainer_wanderbell = UIView()
            iconContainer_wanderbell.backgroundColor = emotionType_wanderbell.getColor_Wanderbell().withAlphaComponent(0.2)
            iconContainer_wanderbell.layer.cornerRadius = 25
            
            let iconImageView_wanderbell = UIImageView()
            iconImageView_wanderbell.image = UIImage(systemName: emotionType_wanderbell.getIcon_Wanderbell())
            iconImageView_wanderbell.tintColor = emotionType_wanderbell.getColor_Wanderbell()
            iconImageView_wanderbell.contentMode = .scaleAspectFit
            
            iconContainer_wanderbell.addSubview(iconImageView_wanderbell)
            iconImageView_wanderbell.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.height.equalTo(24)
            }
            
            emotionIconsView_Wanderbell.addArrangedSubview(iconContainer_wanderbell)
            iconContainer_wanderbell.snp.makeConstraints { make in
                make.width.height.equalTo(50)
            }
        }
    }
    
    /// 更新记录列表
    private func updateRecordsList_Wanderbell() {
        recordsStackView_Wanderbell.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if records_Wanderbell.isEmpty {
            let emptyView_wanderbell = createEmptyView_Wanderbell()
            recordsStackView_Wanderbell.addArrangedSubview(emptyView_wanderbell)
        } else {
            for record_wanderbell in records_Wanderbell {
                let recordCard_wanderbell = createRecordCard_Wanderbell(record_wanderbell: record_wanderbell)
                recordsStackView_Wanderbell.addArrangedSubview(recordCard_wanderbell)
            }
        }
    }
    
    /// 创建空状态视图
    private func createEmptyView_Wanderbell() -> UIView {
        let container_wanderbell = UIView()
        
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.image = UIImage(systemName: "calendar.badge.clock")
        imageView_wanderbell.tintColor = ColorConfig_Wanderbell.textPlaceholder_Wanderbell
        imageView_wanderbell.contentMode = .scaleAspectFit
        
        let label_wanderbell = UILabel()
        label_wanderbell.text = "No emotions recorded on this day.\nTap the + button to start recording!"
        label_wanderbell.font = FontConfig_Wanderbell.subheadline_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        label_wanderbell.textAlignment = .center
        label_wanderbell.numberOfLines = 0
        
        container_wanderbell.addSubview(imageView_wanderbell)
        container_wanderbell.addSubview(label_wanderbell)
        
        imageView_wanderbell.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(40)
            make.width.height.equalTo(60)
        }
        
        label_wanderbell.snp.makeConstraints { make in
            make.top.equalTo(imageView_wanderbell.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        return container_wanderbell
    }
    
    /// 创建记录卡片
    private func createRecordCard_Wanderbell(record_wanderbell: EmotionRecord_Wanderbell) -> UIView {
        let container_wanderbell = UIView()
        container_wanderbell.backgroundColor = ColorConfig_Wanderbell.backgroundSecondary_Wanderbell
        container_wanderbell.layer.cornerRadius = 16
        container_wanderbell.layer.borderWidth = 2
        container_wanderbell.layer.borderColor = record_wanderbell.emotionType_Wanderbell.getColor_Wanderbell().withAlphaComponent(0.3).cgColor
        
        // 删除按钮
        let deleteButton_wanderbell = UIButton(type: .system)
        let config_wanderbell = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        deleteButton_wanderbell.setImage(UIImage(systemName: "trash.fill", withConfiguration: config_wanderbell), for: .normal)
        deleteButton_wanderbell.tintColor = UIColor(hexstring_Wanderbell: "#FF6B6B")
        deleteButton_wanderbell.backgroundColor = UIColor(hexstring_Wanderbell: "#FF6B6B").withAlphaComponent(0.1)
        deleteButton_wanderbell.layer.cornerRadius = 16
        deleteButton_wanderbell.isUserInteractionEnabled = true
        
        // 保存记录ID到tag，统一使用 target-action 方式（更稳定）
        deleteButton_wanderbell.tag = record_wanderbell.recordId_Wanderbell
        deleteButton_wanderbell.addTarget(self, action: #selector(deleteButtonTapped_Wanderbell(_:)), for: .touchUpInside)
        
        // 情绪图标
        let iconView_wanderbell = UIView()
        iconView_wanderbell.backgroundColor = record_wanderbell.emotionType_Wanderbell.getColor_Wanderbell().withAlphaComponent(0.15)
        iconView_wanderbell.layer.cornerRadius = 28
        
        let iconImageView_wanderbell = UIImageView()
        iconImageView_wanderbell.image = UIImage(systemName: record_wanderbell.emotionType_Wanderbell.getIcon_Wanderbell())
        iconImageView_wanderbell.tintColor = record_wanderbell.emotionType_Wanderbell.getColor_Wanderbell()
        iconImageView_wanderbell.contentMode = .scaleAspectFit
        iconView_wanderbell.addSubview(iconImageView_wanderbell)
        
        // 情绪名称
        let emotionLabel_wanderbell = UILabel()
        emotionLabel_wanderbell.text = record_wanderbell.getEmotionDisplayName_Wanderbell()
        emotionLabel_wanderbell.font = FontConfig_Wanderbell.title3_Wanderbell()
        emotionLabel_wanderbell.textColor = record_wanderbell.emotionType_Wanderbell.getColor_Wanderbell()
        
        // 强度星星
        let intensityLabel_wanderbell = UILabel()
        intensityLabel_wanderbell.text = String(repeating: "⭐️", count: record_wanderbell.intensity_Wanderbell)
        intensityLabel_wanderbell.font = UIFont.systemFont(ofSize: 14)
        
        // 时间
        let timeLabel_wanderbell = UILabel()
        let timeFormatter_wanderbell = DateFormatter()
        timeFormatter_wanderbell.timeStyle = .short
        timeLabel_wanderbell.text = timeFormatter_wanderbell.string(from: record_wanderbell.timestamp_Wanderbell)
        timeLabel_wanderbell.font = FontConfig_Wanderbell.caption_Wanderbell()
        timeLabel_wanderbell.textColor = ColorConfig_Wanderbell.textPlaceholder_Wanderbell
        
        // 笔记内容
        let noteLabel_wanderbell = UILabel()
        noteLabel_wanderbell.text = record_wanderbell.note_Wanderbell
        noteLabel_wanderbell.font = FontConfig_Wanderbell.subheadline_Wanderbell()
        noteLabel_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        noteLabel_wanderbell.numberOfLines = 0
        
        // 标签视图
        let tagsView_wanderbell = createTagsView_Wanderbell(tags_wanderbell: record_wanderbell.tags_Wanderbell)
        
        container_wanderbell.addSubview(iconView_wanderbell)
        container_wanderbell.addSubview(emotionLabel_wanderbell)
        container_wanderbell.addSubview(intensityLabel_wanderbell)
        container_wanderbell.addSubview(timeLabel_wanderbell)
        container_wanderbell.addSubview(noteLabel_wanderbell)
        container_wanderbell.addSubview(tagsView_wanderbell)
        container_wanderbell.addSubview(deleteButton_wanderbell)
        
        iconImageView_wanderbell.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        iconView_wanderbell.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(16)
            make.width.height.equalTo(56)
        }
        
        deleteButton_wanderbell.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.width.height.equalTo(32)
        }
        
        emotionLabel_wanderbell.snp.makeConstraints { make in
            make.left.equalTo(iconView_wanderbell.snp.right).offset(12)
            make.top.equalTo(iconView_wanderbell).offset(4)
            make.right.equalTo(deleteButton_wanderbell.snp.left).offset(-8)
        }
        
        intensityLabel_wanderbell.snp.makeConstraints { make in
            make.left.equalTo(emotionLabel_wanderbell)
            make.top.equalTo(emotionLabel_wanderbell.snp.bottom).offset(4)
        }
        
        timeLabel_wanderbell.snp.makeConstraints { make in
            make.right.equalTo(deleteButton_wanderbell.snp.left).offset(-8)
            make.centerY.equalTo(emotionLabel_wanderbell)
        }
        
        noteLabel_wanderbell.snp.makeConstraints { make in
            make.top.equalTo(iconView_wanderbell.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
        }
        
        tagsView_wanderbell.snp.makeConstraints { make in
            make.top.equalTo(noteLabel_wanderbell.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
            make.height.greaterThanOrEqualTo(20)
        }
        
        return container_wanderbell
    }
    
    /// 创建标签视图
    private func createTagsView_Wanderbell(tags_wanderbell: [String]) -> UIView {
        let container_wanderbell = UIView()
        
        if tags_wanderbell.isEmpty {
            return container_wanderbell
        }
        
        var previousTag_wanderbell: UIView?
        var currentX_wanderbell: CGFloat = 0
        let maxWidth_wanderbell: CGFloat = 300 - 32 // 容器宽度 - 左右边距
        
        for tag_wanderbell in tags_wanderbell {
            let tagLabel_wanderbell = UILabel()
            tagLabel_wanderbell.text = "#\(tag_wanderbell)"
            tagLabel_wanderbell.font = FontConfig_Wanderbell.caption_Wanderbell()
            tagLabel_wanderbell.textColor = ColorConfig_Wanderbell.primaryGradientStart_Wanderbell
            tagLabel_wanderbell.backgroundColor = ColorConfig_Wanderbell.primaryGradientStart_Wanderbell.withAlphaComponent(0.1)
            tagLabel_wanderbell.layer.cornerRadius = 10
            tagLabel_wanderbell.clipsToBounds = true
            tagLabel_wanderbell.textAlignment = .center
            
            // 计算标签宽度
            let tagWidth_wanderbell = (tag_wanderbell as NSString).size(withAttributes: [.font: FontConfig_Wanderbell.caption_Wanderbell()]).width + 16
            
            // 检查是否需要换行
            if currentX_wanderbell + tagWidth_wanderbell > maxWidth_wanderbell && previousTag_wanderbell != nil {
                currentX_wanderbell = 0
                previousTag_wanderbell = nil
            }
            
            container_wanderbell.addSubview(tagLabel_wanderbell)
            
            tagLabel_wanderbell.snp.makeConstraints { make in
                if let previous_wanderbell = previousTag_wanderbell {
                    make.left.equalTo(previous_wanderbell.snp.right).offset(8)
                    make.top.equalTo(previous_wanderbell)
                } else {
                    make.left.equalToSuperview()
                    make.top.equalToSuperview()
                }
                make.height.equalTo(20)
                make.width.equalTo(tagWidth_wanderbell)
            }
            
            previousTag_wanderbell = tagLabel_wanderbell
            currentX_wanderbell += tagWidth_wanderbell + 8
        }
        
        return container_wanderbell
    }
    
    // MARK: - 显示/隐藏
    
    /// 显示详情弹窗
    func show_Wanderbell(in viewController_wanderbell: UIViewController) {
        // 保存ViewController引用
        parentViewController_Wanderbell = viewController_wanderbell
        
        guard let window_wanderbell = viewController_wanderbell.view.window else { return }
        
        frame = window_wanderbell.bounds
        window_wanderbell.addSubview(self)
        
        // 初始状态
        containerView_Wanderbell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        containerView_Wanderbell.alpha = 0
        
        // 动画显示
        UIView.animate(
            withDuration: AnimationConfig_Wanderbell.durationSpring_Wanderbell,
            delay: 0,
            usingSpringWithDamping: AnimationConfig_Wanderbell.springDampingNormal_Wanderbell,
            initialSpringVelocity: AnimationConfig_Wanderbell.springVelocity_Wanderbell,
            options: [.curveEaseOut],
            animations: {
                self.overlayView_Wanderbell.alpha = 1
                self.containerView_Wanderbell.transform = .identity
                self.containerView_Wanderbell.alpha = 1
            }
        )
        
        // 触觉反馈
        let generator_wanderbell = UIImpactFeedbackGenerator(style: .medium)
        generator_wanderbell.impactOccurred()
    }
    
    /// 隐藏详情弹窗
    @objc func dismiss_Wanderbell() {
        UIView.animate(
            withDuration: AnimationConfig_Wanderbell.durationNormal_Wanderbell,
            animations: {
                self.overlayView_Wanderbell.alpha = 0
                self.containerView_Wanderbell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                self.containerView_Wanderbell.alpha = 0
            },
            completion: { _ in
                self.removeFromSuperview()
            }
        )
        
        // 触觉反馈
        let generator_wanderbell = UIImpactFeedbackGenerator(style: .light)
        generator_wanderbell.impactOccurred()
    }
    
    /// 删除情绪记录
    /// 功能：删除选中的情绪记录
    /// 参数：
    /// - record_wanderbell: 要删除的情绪记录
    private func deleteRecord_Wanderbell(record_wanderbell: EmotionRecord_Wanderbell) {
        
        // 使用保存的ViewController引用
        guard let viewController_wanderbell = parentViewController_Wanderbell else {
            return
        }
        
        let alert_wanderbell = UIAlertController(
            title: "Delete Record",
            message: "Are you sure you want to delete this emotion record?",
            preferredStyle: .alert
        )
        
        alert_wanderbell.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in })
        
        alert_wanderbell.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            
            // 删除记录
            EmotionViewModel_Wanderbell.shared_Wanderbell.deleteEmotionRecord_Wanderbell(record_wanderbell: record_wanderbell)
            
            // 重新加载数据
            self?.loadData_Wanderbell()
            
            // 显示成功提示
            Utils_Wanderbell.showSuccess_Wanderbell(
                message_wanderbell: "Record deleted successfully",
                delay_wanderbell: 1.5
            )
            
            // 触觉反馈
            let generator_wanderbell = UINotificationFeedbackGenerator()
            generator_wanderbell.notificationOccurred(.success)
        })
        
        viewController_wanderbell.present(alert_wanderbell, animated: true) {}
    }
    
    /// 查找所属ViewController
    /// 功能：向上遍历响应链，找到所属的ViewController
    /// 返回值：找到的ViewController，如果没找到则返回nil
    private func findViewController_Wanderbell() -> UIViewController? {
        var responder_wanderbell: UIResponder? = self
        while let nextResponder_wanderbell = responder_wanderbell?.next {
            if let viewController_wanderbell = nextResponder_wanderbell as? UIViewController {
                return viewController_wanderbell
            }
            responder_wanderbell = nextResponder_wanderbell
        }
        return nil
    }
    
    /// 删除按钮点击（统一处理）
    /// 功能：处理删除按钮点击事件，通过tag获取记录ID
    /// 参数：
    /// - sender: 删除按钮
    @objc private func deleteButtonTapped_Wanderbell(_ sender: UIButton) {
        
        let recordId_wanderbell = sender.tag
        
        // 从records数组中找到对应的记录
        guard let record_wanderbell = records_Wanderbell.first(where: { $0.recordId_Wanderbell == recordId_wanderbell }) else {
            return
        }
        
        // 调用删除方法
        deleteRecord_Wanderbell(record_wanderbell: record_wanderbell)
    }
}
