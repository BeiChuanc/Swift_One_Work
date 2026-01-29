import Foundation
import UIKit
import SnapKit

// MARK: - 增强版情绪统计卡片

/// 增强版情绪统计卡片
/// 功能：展示本周情绪占比统计，带圆形进度条可视化
class ImprovedEmotionStatisticsCard_Wanderbell: UIView {
    
    private let titleLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.text = "This Week's Emotions"
        label_wanderbell.font = FontConfig_Wanderbell.title3_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        return label_wanderbell
    }()
    
    private let iconImageView_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.image = UIImage(systemName: "chart.pie.fill")
        imageView_wanderbell.tintColor = ColorConfig_Wanderbell.primaryGradientStart_Wanderbell
        imageView_wanderbell.contentMode = .scaleAspectFit
        return imageView_wanderbell
    }()
    
    private let statsStackView_Wanderbell: UIStackView = {
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
        backgroundColor = .white
        layer.cornerRadius = 20
        layer.shadowColor = ColorConfig_Wanderbell.shadowColor_Wanderbell.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 12
        layer.shadowOpacity = 0.15
        
        addSubview(iconImageView_Wanderbell)
        addSubview(titleLabel_Wanderbell)
        addSubview(statsStackView_Wanderbell)
        
        iconImageView_Wanderbell.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(20)
            make.width.height.equalTo(28)
        }
        
        titleLabel_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(iconImageView_Wanderbell.snp.right).offset(12)
            make.centerY.equalTo(iconImageView_Wanderbell)
            make.right.equalToSuperview().offset(-20)
        }
        
        statsStackView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Wanderbell.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    private func loadData_Wanderbell() {
        statsStackView_Wanderbell.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 获取当前登录用户的情绪统计
        let currentUser_wanderbell = UserViewModel_Wanderbell.shared_Wanderbell.getCurrentUser_Wanderbell()
        let userId_wanderbell = currentUser_wanderbell.userId_Wanderbell
        let statistics_wanderbell = EmotionViewModel_Wanderbell.shared_Wanderbell.getEmotionStatistics_Wanderbell(days_wanderbell: 7, userId_wanderbell: userId_wanderbell)
        
        if statistics_wanderbell.isEmpty {
            let emptyLabel_wanderbell = UILabel()
            emptyLabel_wanderbell.text = "No emotions recorded this week"
            emptyLabel_wanderbell.font = FontConfig_Wanderbell.subheadline_Wanderbell()
            emptyLabel_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
            emptyLabel_wanderbell.textAlignment = .center
            statsStackView_Wanderbell.addArrangedSubview(emptyLabel_wanderbell)
            return
        }
        
        let total_wanderbell = statistics_wanderbell.values.reduce(0, +)
        
        for (emotion_wanderbell, count_wanderbell) in statistics_wanderbell.sorted(by: { $0.value > $1.value }) {
            let percentage_wanderbell = CGFloat(count_wanderbell) / CGFloat(total_wanderbell)
            let bar_wanderbell = createEmotionBar_Wanderbell(
                emotion_wanderbell: emotion_wanderbell,
                count_wanderbell: count_wanderbell,
                percentage_wanderbell: percentage_wanderbell
            )
            statsStackView_Wanderbell.addArrangedSubview(bar_wanderbell)
        }
    }
    
    private func createEmotionBar_Wanderbell(emotion_wanderbell: EmotionType_Wanderbell, count_wanderbell: Int, percentage_wanderbell: CGFloat) -> UIView {
        let container_wanderbell = UIView()
        
        // 情绪图标（使用UIImageView）
        let iconImageView_wanderbell = UIImageView()
        iconImageView_wanderbell.image = UIImage(systemName: emotion_wanderbell.getIcon_Wanderbell())
        iconImageView_wanderbell.tintColor = emotion_wanderbell.getColor_Wanderbell()
        iconImageView_wanderbell.contentMode = .scaleAspectFit
        
        // 情绪名称
        let nameLabel_wanderbell = UILabel()
        nameLabel_wanderbell.text = emotion_wanderbell.rawValue
        nameLabel_wanderbell.font = FontConfig_Wanderbell.subheadline_Wanderbell()
        nameLabel_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        
        // 次数
        let countLabel_wanderbell = UILabel()
        countLabel_wanderbell.text = "\(count_wanderbell)"
        countLabel_wanderbell.font = FontConfig_Wanderbell.number_Wanderbell(size_wanderbell: 18)
        countLabel_wanderbell.textColor = emotion_wanderbell.getColor_Wanderbell()
        
        // 进度条背景
        let progressBg_wanderbell = UIView()
        progressBg_wanderbell.backgroundColor = ColorConfig_Wanderbell.backgroundPrimary_Wanderbell
        progressBg_wanderbell.layer.cornerRadius = 4
        
        // 进度条前景
        let progressFg_wanderbell = UIView()
        progressFg_wanderbell.backgroundColor = emotion_wanderbell.getColor_Wanderbell()
        progressFg_wanderbell.layer.cornerRadius = 4
        
        container_wanderbell.addSubview(iconImageView_wanderbell)
        container_wanderbell.addSubview(nameLabel_wanderbell)
        container_wanderbell.addSubview(countLabel_wanderbell)
        container_wanderbell.addSubview(progressBg_wanderbell)
        progressBg_wanderbell.addSubview(progressFg_wanderbell)
        
        iconImageView_wanderbell.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        nameLabel_wanderbell.snp.makeConstraints { make in
            make.left.equalTo(iconImageView_wanderbell.snp.right).offset(10)
            make.centerY.equalTo(iconImageView_wanderbell)
        }
        
        countLabel_wanderbell.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalTo(iconImageView_wanderbell)
        }
        
        progressBg_wanderbell.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(iconImageView_wanderbell.snp.bottom).offset(8)
            make.height.equalTo(8)
            make.bottom.equalToSuperview()
        }
        
        progressFg_wanderbell.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(progressBg_wanderbell.snp.width).multipliedBy(percentage_wanderbell)
        }
        
        // 动画：从左边开始生长
        // 先强制布局，确保frame已经确定
        container_wanderbell.layoutIfNeeded()
        
        // 保存原始bounds用于动画
        let finalWidth_wanderbell = progressFg_wanderbell.bounds.width
        
        // 设置初始宽度为0（从左边开始）
        progressFg_wanderbell.bounds.size.width = 0
        
        // 执行动画
        UIView.animate(withDuration: 0.8, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            progressFg_wanderbell.bounds.size.width = finalWidth_wanderbell
        })
        
        return container_wanderbell
    }
    
    private func observeEmotionState_Wanderbell() {
        // 监听情绪状态变化
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateChange_Wanderbell),
            name: EmotionViewModel_Wanderbell.emotionStateDidChangeNotification_Wanderbell,
            object: nil
        )
        
        // 监听用户状态变化
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateChange_Wanderbell),
            name: UserViewModel_Wanderbell.userStateDidChangeNotification_Wanderbell,
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

// MARK: - 增强版情绪趋势图表

/// 增强版情绪趋势图表
/// 功能：展示近7天情绪强度趋势，带柱状图可视化
class ImprovedEmotionTrendChart_Wanderbell: UIView {
    
    private let titleLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.text = "7-Day Trend"
        label_wanderbell.font = FontConfig_Wanderbell.title3_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        return label_wanderbell
    }()
    
    private let iconImageView_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.image = UIImage(systemName: "chart.line.uptrend.xyaxis")
        imageView_wanderbell.tintColor = ColorConfig_Wanderbell.secondaryGradientStart_Wanderbell
        imageView_wanderbell.contentMode = .scaleAspectFit
        return imageView_wanderbell
    }()
    
    private let chartContainerView_Wanderbell = UIView()
    
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
        layer.cornerRadius = 20
        layer.shadowColor = ColorConfig_Wanderbell.shadowColor_Wanderbell.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 12
        layer.shadowOpacity = 0.15
        
        addSubview(iconImageView_Wanderbell)
        addSubview(titleLabel_Wanderbell)
        addSubview(chartContainerView_Wanderbell)
        
        iconImageView_Wanderbell.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(20)
            make.width.height.equalTo(28)
        }
        
        titleLabel_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(iconImageView_Wanderbell.snp.right).offset(12)
            make.centerY.equalTo(iconImageView_Wanderbell)
            make.right.equalToSuperview().offset(-20)
        }
        
        chartContainerView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Wanderbell.snp.bottom).offset(20)
            make.left.right.bottom.equalToSuperview().inset(20)
            make.height.equalTo(140)
        }
    }
    
    private func loadData_Wanderbell() {
        chartContainerView_Wanderbell.subviews.forEach { $0.removeFromSuperview() }
        
        // 获取当前登录用户的情绪趋势
        let currentUser_wanderbell = UserViewModel_Wanderbell.shared_Wanderbell.getCurrentUser_Wanderbell()
        let userId_wanderbell = currentUser_wanderbell.userId_Wanderbell
        let trendData_wanderbell = EmotionViewModel_Wanderbell.shared_Wanderbell.getEmotionTrend_Wanderbell(days_wanderbell: 7, userId_wanderbell: userId_wanderbell)
        
        if trendData_wanderbell.isEmpty {
            let emptyLabel_wanderbell = UILabel()
            emptyLabel_wanderbell.text = "No trend data available"
            emptyLabel_wanderbell.font = FontConfig_Wanderbell.subheadline_Wanderbell()
            emptyLabel_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
            emptyLabel_wanderbell.textAlignment = .center
            chartContainerView_Wanderbell.addSubview(emptyLabel_wanderbell)
            emptyLabel_wanderbell.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
            return
        }
        
        let recentData_wanderbell = Array(trendData_wanderbell.suffix(7))
        let maxIntensity_wanderbell = max(recentData_wanderbell.map { $0.1 }.max() ?? 5.0, 1.0) // 确保至少是1.0，避免除以0
        
        let barStackView_wanderbell = UIStackView()
        barStackView_wanderbell.axis = .horizontal
        barStackView_wanderbell.distribution = .fillEqually
        barStackView_wanderbell.spacing = 8
        barStackView_wanderbell.alignment = .bottom
        
        chartContainerView_Wanderbell.addSubview(barStackView_wanderbell)
        barStackView_wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let formatter_wanderbell = DateFormatter()
        formatter_wanderbell.dateFormat = "E"
        
        for (date_wanderbell, intensity_wanderbell) in recentData_wanderbell {
            let barContainer_wanderbell = UIView()
            
            let bar_wanderbell = UIView()
            // 计算归一化高度，确保值在0-1之间
            var normalizedHeight_wanderbell = CGFloat(intensity_wanderbell / maxIntensity_wanderbell)
            // 防止NaN和无穷大
            if normalizedHeight_wanderbell.isNaN || normalizedHeight_wanderbell.isInfinite {
                normalizedHeight_wanderbell = 0.1 // 设置最小值
            }
            normalizedHeight_wanderbell = max(0.1, min(1.0, normalizedHeight_wanderbell)) // 限制在0.1-1.0之间
            
            bar_wanderbell.backgroundColor = ColorConfig_Wanderbell.primaryGradientStart_Wanderbell
            bar_wanderbell.layer.cornerRadius = 6
            
            let dateLabel_wanderbell = UILabel()
            dateLabel_wanderbell.text = formatter_wanderbell.string(from: date_wanderbell)
            dateLabel_wanderbell.font = FontConfig_Wanderbell.caption_Wanderbell()
            dateLabel_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
            dateLabel_wanderbell.textAlignment = .center
            
            barContainer_wanderbell.addSubview(bar_wanderbell)
            barContainer_wanderbell.addSubview(dateLabel_wanderbell)
            
            // 初始高度约束为0
            bar_wanderbell.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.bottom.equalTo(dateLabel_wanderbell.snp.top).offset(-4)
                make.height.equalTo(0)
            }
            
            dateLabel_wanderbell.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
            }
            
            barStackView_wanderbell.addArrangedSubview(barContainer_wanderbell)
            
            // 延迟执行动画，让每个柱子依次从底部向上生长
            let delayIndex_wanderbell = recentData_wanderbell.firstIndex(where: { $0.0 == date_wanderbell }) ?? 0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 + Double(delayIndex_wanderbell) * 0.08) {
                // 更新高度约束
                bar_wanderbell.snp.updateConstraints { make in
                    make.height.equalTo(100 * normalizedHeight_wanderbell)
                }
                
                // 执行动画
                UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                    barStackView_wanderbell.layoutIfNeeded()
                }
            }
        }
    }
    
    private func observeEmotionState_Wanderbell() {
        // 监听情绪状态变化
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateChange_Wanderbell),
            name: EmotionViewModel_Wanderbell.emotionStateDidChangeNotification_Wanderbell,
            object: nil
        )
        
        // 监听用户状态变化
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateChange_Wanderbell),
            name: UserViewModel_Wanderbell.userStateDidChangeNotification_Wanderbell,
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
