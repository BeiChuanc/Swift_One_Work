import Foundation
import UIKit
import SnapKit

// MARK: - 梦境记录 TableViewCell

/// 梦境记录卡片单元格
/// 核心功能：展示单条梦境内容，叠加「梦痕时间戳」半透明水印（入睡时间 + 月亮相位 + 情绪关键词），
///          支持「续梦」按钮、噩梦徽章、梦系列徽章和「不想再梦」标记显示
/// 设计理念：白色卡片 + 柔和阴影 + 对角水印，让每条梦境都带有专属印记
class DreamRecordCell_Somnia: UITableViewCell {

    // MARK: - 复用标识

    /// 复用 ID
    static let reuseId_Somnia = "DreamRecordCell_Somnia"

    // MARK: - 私有 UI 属性

    /// 卡片容器（白色圆角卡片，带阴影）
    private let cardView_Somnia = UIView()

    /// 左侧情绪色条
    private let colorBar_Somnia = UIView()

    /// 梦境内容文字
    private let contentLabel_Somnia = UILabel()

    /// 日期 + 时间标签
    private let dateLabel_Somnia = UILabel()

    /// 梦痕时间戳水印层（不可交互）
    private let watermarkView_Somnia = DreamWatermarkView_Somnia()

    /// 噩梦标签
    private let nightmareBadge_Somnia = UIView()
    private let nightmareLabel_Somnia = UILabel()

    /// 梦系列标签
    private let seriesBadge_Somnia = UIView()
    private let seriesLabel_Somnia = UILabel()

    /// 不想再梦标记
    private let dontDreamBadge_Somnia = UIView()
    private let dontDreamLabel_Somnia = UILabel()

    /// 续梦按钮
    private let continueBt_Somnia = UIButton(type: .custom)

    /// 标签容器横向 StackView
    private let badgeStack_Somnia = UIStackView()

    // MARK: - 回调

    /// 点击「续梦」按钮回调，携带源记录模型
    var onContinueDream_Somnia: ((DreamRecordModel_Somnia) -> Void)?

    // MARK: - 数据

    private var recordModel_Somnia: DreamRecordModel_Somnia?

    // MARK: - 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI_Somnia()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI_Somnia()
    }

    // MARK: - UI 构建

    /// 初始化所有子视图
    private func setupUI_Somnia() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.backgroundColor = .clear

        // 卡片容器
        cardView_Somnia.backgroundColor = ColorConfig_Somnia.cardBackground_Somnia
        cardView_Somnia.layer.cornerRadius = 18
        cardView_Somnia.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        cardView_Somnia.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView_Somnia.layer.shadowRadius = 10
        cardView_Somnia.layer.shadowOpacity = 1
        cardView_Somnia.clipsToBounds = false
        contentView.addSubview(cardView_Somnia)

        // 情绪色条（左侧竖线，颜色根据情绪关键词变化）
        colorBar_Somnia.layer.cornerRadius = 2
        colorBar_Somnia.clipsToBounds = true
        cardView_Somnia.addSubview(colorBar_Somnia)

        // 梦境内容
        contentLabel_Somnia.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        contentLabel_Somnia.textColor = ColorConfig_Somnia.textPrimary_Somnia
        contentLabel_Somnia.numberOfLines = 3
        contentLabel_Somnia.lineBreakMode = .byTruncatingTail
        cardView_Somnia.addSubview(contentLabel_Somnia)

        // 水印（叠加在卡片内，isUserInteractionEnabled = false）
        watermarkView_Somnia.isUserInteractionEnabled = false
        watermarkView_Somnia.backgroundColor = .clear
        cardView_Somnia.addSubview(watermarkView_Somnia)

        // 徽章横向容器
        badgeStack_Somnia.axis = .horizontal
        badgeStack_Somnia.spacing = 6
        badgeStack_Somnia.alignment = .center
        cardView_Somnia.addSubview(badgeStack_Somnia)

        buildBadge_Somnia(
            container: nightmareBadge_Somnia,
            label: nightmareLabel_Somnia,
            text: "😱 Nightmare",
            color: UIColor(hexstring_Somnia: "#FC8181")
        )
        badgeStack_Somnia.addArrangedSubview(nightmareBadge_Somnia)

        buildBadge_Somnia(
            container: seriesBadge_Somnia,
            label: seriesLabel_Somnia,
            text: "🔗 Series",
            color: UIColor(hexstring_Somnia: "#B794F6")
        )
        badgeStack_Somnia.addArrangedSubview(seriesBadge_Somnia)

        buildBadge_Somnia(
            container: dontDreamBadge_Somnia,
            label: dontDreamLabel_Somnia,
            text: "🚫 Never Again",
            color: UIColor(hexstring_Somnia: "#A0AEC0")
        )
        badgeStack_Somnia.addArrangedSubview(dontDreamBadge_Somnia)

        // 日期
        dateLabel_Somnia.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        dateLabel_Somnia.textColor = ColorConfig_Somnia.textPlaceholder_Somnia
        cardView_Somnia.addSubview(dateLabel_Somnia)

        // 续梦按钮
        continueBt_Somnia.setTitle("Continue Dream ›", for: .normal)
        continueBt_Somnia.setTitleColor(ColorConfig_Somnia.primaryGradientStart_Somnia, for: .normal)
        continueBt_Somnia.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        continueBt_Somnia.backgroundColor = ColorConfig_Somnia.primaryGradientStart_Somnia.withAlphaComponent(0.08)
        continueBt_Somnia.layer.cornerRadius = 12
        continueBt_Somnia.contentEdgeInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)
        continueBt_Somnia.addTarget(self, action: #selector(continueTapped_Somnia), for: .touchUpInside)
        cardView_Somnia.addSubview(continueBt_Somnia)

        setupConstraints_Somnia()
    }

    /// 构建通用徽章视图
    /// - Parameters:
    ///   - container: 容器 UIView
    ///   - label: 文字标签
    ///   - text: 显示文字
    ///   - color: 徽章底色
    private func buildBadge_Somnia(container: UIView, label: UILabel, text: String, color: UIColor) {
        container.backgroundColor = color.withAlphaComponent(0.12)
        container.layer.cornerRadius = 8
        label.text = text
        label.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        label.textColor = color
        container.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8))
        }
    }

    /// 设置约束
    private func setupConstraints_Somnia() {
        cardView_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.bottom.equalToSuperview().offset(-6)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        colorBar_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
            make.leading.equalToSuperview().offset(14)
            make.width.equalTo(4)
        }

        contentLabel_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalTo(colorBar_Somnia.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-80)
        }

        watermarkView_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
            make.width.equalTo(100)
        }

        badgeStack_Somnia.snp.makeConstraints { make in
            make.top.equalTo(contentLabel_Somnia.snp.bottom).offset(10)
            make.leading.equalTo(contentLabel_Somnia.snp.leading)
        }

        dateLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(badgeStack_Somnia.snp.bottom).offset(8)
            make.leading.equalTo(contentLabel_Somnia.snp.leading)
            make.bottom.equalToSuperview().offset(-14)
        }

        continueBt_Somnia.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview().offset(-14)
        }
    }

    // MARK: - 数据配置

    /// 用梦境记录数据配置单元格显示
    /// - Parameter record_somnia: 梦境记录模型
    func configure_Somnia(record_somnia: DreamRecordModel_Somnia) {
        recordModel_Somnia = record_somnia
        contentLabel_Somnia.text = record_somnia.content_Somnia

        // 情绪色条颜色映射
        colorBar_Somnia.backgroundColor = emotionColor_Somnia(keyword_somnia: record_somnia.emotionKeyword_Somnia)

        // 梦痕时间戳水印
        watermarkView_Somnia.configure_Somnia(
            sleepTime_somnia: record_somnia.sleepTime_Somnia,
            moonPhase_somnia: record_somnia.moonPhase_Somnia,
            emotion_somnia: record_somnia.emotionKeyword_Somnia
        )

        // 日期格式化
        let date = Date(timeIntervalSince1970: record_somnia.recordTimestamp_Somnia)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        dateLabel_Somnia.text = formatter.string(from: date)

        // 徽章显隐控制
        nightmareBadge_Somnia.isHidden = !record_somnia.isNightmare_Somnia
        seriesBadge_Somnia.isHidden = record_somnia.seriesId_Somnia == nil
        dontDreamBadge_Somnia.isHidden = !record_somnia.isDontDream_Somnia
    }

    /// 根据情绪关键词返回对应的色条颜色
    /// - Parameter keyword_somnia: 情绪关键词字符串
    /// - Returns: 对应颜色
    private func emotionColor_Somnia(keyword_somnia: String) -> UIColor {
        switch keyword_somnia {
        case "自由", "喜悦", "兴奋":
            return UIColor(hexstring_Somnia: "#68D391")
        case "温暖", "安心", "幸福":
            return UIColor(hexstring_Somnia: "#FBB6CE")
        case "恐惧", "焦虑", "紧张":
            return UIColor(hexstring_Somnia: "#FC8181")
        case "悲伤", "孤独", "迷茫":
            return UIColor(hexstring_Somnia: "#90CDF4")
        case "好奇", "惊喜":
            return UIColor(hexstring_Somnia: "#F6E05E")
        default:
            return ColorConfig_Somnia.primaryGradientStart_Somnia
        }
    }

    // MARK: - 事件响应

    /// 续梦按钮点击
    @objc private func continueTapped_Somnia() {
        guard let model = recordModel_Somnia else { return }
        continueBt_Somnia.animatePulse_Somnia()
        onContinueDream_Somnia?(model)
    }
}

// MARK: - 梦痕时间戳水印视图

/// 梦痕时间戳水印视图
/// 核心功能：以对角旋转的方式在卡片右侧绘制半透明「梦痕时间戳」，包含入睡时间、月亮相位、情绪关键词
/// 设计理念：水印不可交互，纯 UI 装饰，体现梦境的专属性与不可修改性
class DreamWatermarkView_Somnia: UIView {

    // MARK: - 私有属性

    private var sleepTime_Somnia  = ""
    private var moonPhase_Somnia  = ""
    private var emotion_Somnia    = ""

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        clipsToBounds = true
    }

    // MARK: - 数据配置

    /// 设置水印内容并触发重绘
    /// - Parameters:
    ///   - sleepTime_somnia: 入睡时间
    ///   - moonPhase_somnia: 月亮相位
    ///   - emotion_somnia: 情绪关键词
    func configure_Somnia(sleepTime_somnia: String, moonPhase_somnia: String, emotion_somnia: String) {
        sleepTime_Somnia = sleepTime_somnia
        moonPhase_Somnia = moonPhase_somnia
        emotion_Somnia   = emotion_somnia
        setNeedsDisplay()
    }

    // MARK: - 自定义绘制

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.saveGState()

        // 旋转 -30° 绘制水印文字
        ctx.translateBy(x: rect.maxX - 10, y: rect.maxY * 0.5)
        ctx.rotate(by: -CGFloat.pi / 6)

        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9, weight: .medium),
            .foregroundColor: ColorConfig_Somnia.primaryGradientStart_Somnia.withAlphaComponent(0.35)
        ]

        let lines = [sleepTime_Somnia, moonPhase_Somnia, emotion_Somnia]
        let lineHeight: CGFloat = 14
        let totalH = lineHeight * CGFloat(lines.count)

        for (i, line) in lines.enumerated() {
            let y = -totalH / 2 + CGFloat(i) * lineHeight
            line.draw(at: CGPoint(x: -50, y: y), withAttributes: attrs)
        }

        ctx.restoreGState()
    }
}
