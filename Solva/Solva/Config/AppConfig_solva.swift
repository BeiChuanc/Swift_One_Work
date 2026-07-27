//
//  AppConfig_solva.swift
//  Solva
//
//  全局配置常量文件。
//  设计思路：集中管理与业务数据无关的「工程性配置」——布局尺寸、动画时长、
//  持久化键名等，避免魔法数字/字符串散落在各个视图与引擎文件中。
//

import CoreGraphics
import Foundation

/// 全局配置项
enum AppConfig_solva {

    // MARK: 卡牌布局

    /// 标准扑克牌宽高比（宽:高 = 5:7）
    static let cardAspectRatio_solva: CGFloat = 5.0 / 7.0
    /// 横屏下单张卡牌的基础宽度
    static let cardBaseWidth_solva: CGFloat = 72
    /// 牌墩纵向堆叠时，相邻两张暗牌之间的可视露出高度
    static let stackFaceDownOffset_solva: CGFloat = 8
    /// 牌墩纵向堆叠时，相邻两张明牌之间的可视露出高度
    static let stackFaceUpOffset_solva: CGFloat = 20

    // MARK: 动效

    /// 卡牌移动动效时长
    static let moveAnimationDuration_solva: Double = 0.28
    /// 卡牌选中高亮的弹簧动效
    static let selectAnimation_solva: Double = 0.18
    /// 成就提示条展示时长
    static let achievementToastDuration_solva: Double = 2.6

    // MARK: 持久化 Key

    static let storageKeyRecords_solva = "solva.storage.records"
    static let storageKeyStats_solva = "solva.storage.stats"
    static let storageKeyAchievements_solva = "solva.storage.achievements"

    // MARK: 游戏规则参数

    /// 双金字塔中，K 之外的凑数目标
    static let pyramidTargetSum_solva = 13
    /// 四季纸牌中，完整走完一轮四季所需的行动步数
    static let seasonsCycleLength_solva = 4
}
