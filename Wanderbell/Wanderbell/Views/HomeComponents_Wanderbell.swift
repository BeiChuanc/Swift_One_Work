import Foundation
import UIKit
import SnapKit

// MARK: - 情绪统计卡片

/// 情绪统计卡片（简化版饼图）
/// 功能：展示本周情绪占比统计
class EmotionStatisticsCard_Wanderbell: UIView {
    
    private let titleLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.text = "This Week's Emotions"
        label_wanderbell.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        return label_wanderbell
    }()
    
    private let statsLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        label_wanderbell.numberOfLines = 0
        return label_wanderbell
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Wanderbell()
        loadData_Wanderbell()
        observeEmotionState_Wanderbell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI_Wanderbell() {
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.shadowColor = ColorConfig_Wanderbell.shadowColor_Wanderbell.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.1
        
        addSubview(titleLabel_Wanderbell)
        addSubview(statsLabel_Wanderbell)
        
        titleLabel_Wanderbell.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(20)
        }
        
        statsLabel_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Wanderbell.snp.bottom).offset(16)
            make.left.right.bottom.equalToSuperview().inset(20)
        }
    }
    
    private func loadData_Wanderbell() {
        let statistics_wanderbell = EmotionViewModel_Wanderbell.shared_Wanderbell.getEmotionStatistics_Wanderbell(days_wanderbell: 7)
        
        var text_wanderbell = ""
        for (emotion_wanderbell, count_wanderbell) in statistics_wanderbell.sorted(by: { $0.value > $1.value }) {
            let emoji_wanderbell = emotion_wanderbell.getIcon_Wanderbell()
            text_wanderbell += "\(emoji_wanderbell) \(emotion_wanderbell.rawValue): \(count_wanderbell) times\n"
        }
        
        statsLabel_Wanderbell.text = text_wanderbell.isEmpty ? "No emotions recorded this week" : text_wanderbell
    }
    
    private func observeEmotionState_Wanderbell() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateChange_Wanderbell),
            name: EmotionViewModel_Wanderbell.emotionStateDidChangeNotification_Wanderbell,
            object: nil
        )
    }
    
    @objc private func handleStateChange_Wanderbell() {
        loadData_Wanderbell()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 情绪趋势图表

/// 情绪趋势图表（简化版）
/// 功能：展示近7天情绪强度趋势
class EmotionTrendChart_Wanderbell: UIView {
    
    private let titleLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.text = "7-Day Trend"
        label_wanderbell.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        return label_wanderbell
    }()
    
    private let chartView_Wanderbell = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Wanderbell()
        loadData_Wanderbell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI_Wanderbell() {
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.shadowColor = ColorConfig_Wanderbell.shadowColor_Wanderbell.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.1
        
        addSubview(titleLabel_Wanderbell)
        addSubview(chartView_Wanderbell)
        
        titleLabel_Wanderbell.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(20)
        }
        
        chartView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Wanderbell.snp.bottom).offset(16)
            make.left.right.bottom.equalToSuperview().inset(20)
            make.height.equalTo(120)
        }
    }
    
    private func loadData_Wanderbell() {
        let trendData_wanderbell = EmotionViewModel_Wanderbell.shared_Wanderbell.getEmotionTrend_Wanderbell(days_wanderbell: 7)
        
        // 简化的趋势显示（使用标签）
        let trendLabel_wanderbell = UILabel()
        trendLabel_wanderbell.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        trendLabel_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        trendLabel_wanderbell.numberOfLines = 0
        
        var text_wanderbell = ""
        for (date_wanderbell, intensity_wanderbell) in trendData_wanderbell.suffix(7) {
            let formatter_wanderbell = DateFormatter()
            formatter_wanderbell.dateFormat = "MM/dd"
            let dateStr_wanderbell = formatter_wanderbell.string(from: date_wanderbell)
            let bars_wanderbell = String(repeating: "▪︎", count: Int(intensity_wanderbell))
            text_wanderbell += "\(dateStr_wanderbell): \(bars_wanderbell)\n"
        }
        
        trendLabel_wanderbell.text = text_wanderbell.isEmpty ? "No trend data available" : text_wanderbell
        chartView_Wanderbell.addSubview(trendLabel_wanderbell)
        trendLabel_wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - 情绪记录单元格

/// 情绪记录单元格
/// 功能：展示单条情绪记录，支持删除操作
class EmotionRecordCell_Wanderbell: UIView {
    
    /// 当前记录
    private var currentRecord_Wanderbell: EmotionRecord_Wanderbell?
    
    /// 删除回调
    var onDelete_Wanderbell: (() -> Void)?
    
    private let emotionIconView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.layer.cornerRadius = 20
        return view_wanderbell
    }()
    
    private let emotionIconLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = UIFont.systemFont(ofSize: 24)
        label_wanderbell.textAlignment = .center
        return label_wanderbell
    }()
    
    private let emotionNameLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = FontConfig_Wanderbell.title3_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        return label_wanderbell
    }()
    
    private let noteLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = FontConfig_Wanderbell.subheadline_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        label_wanderbell.numberOfLines = 2
        return label_wanderbell
    }()
    
    private let timeLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = FontConfig_Wanderbell.caption_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textPlaceholder_Wanderbell
        return label_wanderbell
    }()
    
    /// 装饰线条
    private let decorLineView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.layer.cornerRadius = 2
        return view_wanderbell
    }()
    
    /// 删除按钮
    private let deleteButton_Wanderbell: UIButton = {
        let button_wanderbell = UIButton(type: .custom)
        let config_wanderbell = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        button_wanderbell.setImage(UIImage(systemName: "trash.fill", withConfiguration: config_wanderbell), for: .normal)
        button_wanderbell.tintColor = UIColor(hexstring_Wanderbell: "#FF6B6B")
        button_wanderbell.backgroundColor = UIColor(hexstring_Wanderbell: "#FF6B6B").withAlphaComponent(0.1)
        button_wanderbell.layer.cornerRadius = 18
        return button_wanderbell
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Wanderbell()
        setupActions_Wanderbell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI_Wanderbell() {
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.shadowColor = ColorConfig_Wanderbell.shadowColor_Wanderbell.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.12
        
        emotionIconView_Wanderbell.addSubview(emotionIconLabel_Wanderbell)
        addSubview(decorLineView_Wanderbell)
        addSubview(emotionIconView_Wanderbell)
        addSubview(emotionNameLabel_Wanderbell)
        addSubview(noteLabel_Wanderbell)
        addSubview(timeLabel_Wanderbell)
        addSubview(deleteButton_Wanderbell)
        
        decorLineView_Wanderbell.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(8)
            make.width.equalTo(4)
        }
        
        emotionIconView_Wanderbell.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(16)
            make.width.height.equalTo(48)
        }
        
        emotionIconLabel_Wanderbell.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        deleteButton_Wanderbell.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.width.height.equalTo(36)
        }
        
        emotionNameLabel_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(emotionIconView_Wanderbell.snp.right).offset(12)
            make.top.equalTo(emotionIconView_Wanderbell)
            make.right.equalTo(deleteButton_Wanderbell.snp.left).offset(-12)
        }
        
        noteLabel_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(emotionNameLabel_Wanderbell)
            make.top.equalTo(emotionNameLabel_Wanderbell.snp.bottom).offset(4)
            make.right.equalTo(deleteButton_Wanderbell.snp.left).offset(-12)
        }
        
        timeLabel_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(emotionNameLabel_Wanderbell)
            make.top.equalTo(noteLabel_Wanderbell.snp.bottom).offset(8)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        // 设置最小高度，避免被父容器拉伸
        self.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(100)
        }
    }
    
    private func setupActions_Wanderbell() {
        deleteButton_Wanderbell.addTarget(self, action: #selector(deleteButtonTapped_Wanderbell), for: .touchUpInside)
    }
    
    @objc private func deleteButtonTapped_Wanderbell() {
        guard let record_wanderbell = currentRecord_Wanderbell else { return }
        
        // 确认删除
        guard let viewController_wanderbell = self.findViewController_Wanderbell() else { return }
        
        let alert_wanderbell = UIAlertController(
            title: "Delete Record",
            message: "Are you sure you want to delete this emotion record?",
            preferredStyle: .alert
        )
        
        alert_wanderbell.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert_wanderbell.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            // 删除记录
            EmotionViewModel_Wanderbell.shared_Wanderbell.deleteEmotionRecord_Wanderbell(record_wanderbell: record_wanderbell)
            
            // 触发回调
            self?.onDelete_Wanderbell?()
            
            // 显示成功提示
            Utils_Wanderbell.showSuccess_Wanderbell(
                message_wanderbell: "Record deleted successfully",
                delay_wanderbell: 1.5
            )
        })
        
        viewController_wanderbell.present(alert_wanderbell, animated: true)
    }
    
    func configure_Wanderbell(with record_wanderbell: EmotionRecord_Wanderbell) {
        // 保存当前记录
        currentRecord_Wanderbell = record_wanderbell
        
        let emotionType_wanderbell = record_wanderbell.emotionType_Wanderbell
        
        // 设置装饰线条颜色
        decorLineView_Wanderbell.backgroundColor = emotionType_wanderbell.getColor_Wanderbell()
        
        // 设置图标背景
        emotionIconView_Wanderbell.backgroundColor = emotionType_wanderbell.getColor_Wanderbell().withAlphaComponent(0.15)
        
        // 设置图标（使用系统图标）
        if let iconImage_wanderbell = UIImage(systemName: emotionType_wanderbell.getIcon_Wanderbell()) {
            let imageView_wanderbell = UIImageView(image: iconImage_wanderbell)
            imageView_wanderbell.tintColor = emotionType_wanderbell.getColor_Wanderbell()
            imageView_wanderbell.contentMode = .scaleAspectFit
            emotionIconLabel_Wanderbell.text = ""
            emotionIconView_Wanderbell.subviews.forEach { $0.removeFromSuperview() }
            emotionIconView_Wanderbell.addSubview(imageView_wanderbell)
            imageView_wanderbell.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.height.equalTo(28)
            }
        }
        
        emotionNameLabel_Wanderbell.text = record_wanderbell.getEmotionDisplayName_Wanderbell()
        emotionNameLabel_Wanderbell.textColor = emotionType_wanderbell.getColor_Wanderbell()
        noteLabel_Wanderbell.text = record_wanderbell.note_Wanderbell
        
        let formatter_wanderbell = DateFormatter()
        formatter_wanderbell.dateStyle = .medium
        formatter_wanderbell.timeStyle = .short
        timeLabel_Wanderbell.text = formatter_wanderbell.string(from: record_wanderbell.timestamp_Wanderbell)
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
}

// MARK: - 最近记录区域

/// 最近记录区域
/// 功能：展示最近的情绪记录列表
class RecentRecordsSection_Wanderbell: UIView {
    
    private let titleLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.text = "Recent Records"
        label_wanderbell.font = FontConfig_Wanderbell.title2_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        return label_wanderbell
    }()
    
    private let iconImageView_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.image = UIImage(systemName: "clock.arrow.circlepath")
        imageView_wanderbell.tintColor = ColorConfig_Wanderbell.primaryGradientEnd_Wanderbell
        imageView_wanderbell.contentMode = .scaleAspectFit
        return imageView_wanderbell
    }()
    
    private let stackView_Wanderbell: UIStackView = {
        let stack_wanderbell = UIStackView()
        stack_wanderbell.axis = .vertical
        stack_wanderbell.spacing = 12
        return stack_wanderbell
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Wanderbell()
        loadData_Wanderbell()
        observeEmotionState_Wanderbell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI_Wanderbell() {
        addSubview(iconImageView_Wanderbell)
        addSubview(titleLabel_Wanderbell)
        addSubview(stackView_Wanderbell)
        
        iconImageView_Wanderbell.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(20)
            make.width.height.equalTo(28)
        }
        
        titleLabel_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(iconImageView_Wanderbell.snp.right).offset(12)
            make.centerY.equalTo(iconImageView_Wanderbell)
            make.right.equalToSuperview().offset(-20)
        }
        
        stackView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Wanderbell.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    private func loadData_Wanderbell() {
        stackView_Wanderbell.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let records_wanderbell = EmotionViewModel_Wanderbell.shared_Wanderbell.getRecentRecords_Wanderbell(count_wanderbell: 5)
        
        if records_wanderbell.isEmpty {
            let emptyLabel_wanderbell = UILabel()
            emptyLabel_wanderbell.text = "No records yet. Start recording your emotions!"
            emptyLabel_wanderbell.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            emptyLabel_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
            emptyLabel_wanderbell.textAlignment = .center
            emptyLabel_wanderbell.numberOfLines = 0
            stackView_Wanderbell.addArrangedSubview(emptyLabel_wanderbell)
            emptyLabel_wanderbell.snp.makeConstraints { make in
                make.height.equalTo(100)
            }
        } else {
            for record_wanderbell in records_wanderbell {
                let cell_wanderbell = EmotionRecordCell_Wanderbell()
                cell_wanderbell.configure_Wanderbell(with: record_wanderbell)
                stackView_Wanderbell.addArrangedSubview(cell_wanderbell)
            }
        }
    }
    
    private func observeEmotionState_Wanderbell() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateChange_Wanderbell),
            name: EmotionViewModel_Wanderbell.emotionStateDidChangeNotification_Wanderbell,
            object: nil
        )
    }
    
    @objc private func handleStateChange_Wanderbell() {
        loadData_Wanderbell()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
