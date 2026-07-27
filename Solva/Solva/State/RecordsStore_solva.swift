//
//  RecordsStore_solva.swift
//  Solva
//
//  对局记录存储类。
//  设计思路：负责「对局记录」功能的全部数据管理——新增记录、按游戏筛选、
//  按时间倒序读取、持久化到 UserDefaults（JSON 编码）。
//  作为 ObservableObject 供 SwiftUI 页面直接订阅刷新，
//  同时在数据变更时通过 NotificationCenter 广播，满足项目「状态管理统一添加通知」的规范。
//  关键属性：records_solva（全部记录，按时间倒序）
//  关键方法：addRecord_solva（新增记录）、records_solva(for:)（按游戏筛选）
import Foundation
import Combine

final class RecordsStore_solva: ObservableObject {

    /// 全部对局记录，倒序（最新的在最前）
    @Published private(set) var records_solva: [GameRecord_solva] = []

    private let storageKey_solva = AppConfig_solva.storageKeyRecords_solva

    init() {
        loadFromDisk_solva()
    }

    /// 新增一条对局记录
    /// - Parameter record_solva: 待写入的对局记录
    func addRecord_solva(_ record_solva: GameRecord_solva) {
        records_solva.insert(record_solva, at: 0)
        persistToDisk_solva()
        NotificationCenter.default.post(name: .gameRecordDidAdd_solva, object: nil, userInfo: ["record": record_solva])
    }

    /// 按指定游戏类型筛选记录（倒序）
    func records_solva(for gameType: GameType_solva) -> [GameRecord_solva] {
        records_solva.filter { $0.gameType_solva == gameType }
    }

    /// 清空全部记录（用于设置页的「重置数据」场景，当前预留接口，保持数据闭环可维护）
    func clearAll_solva() {
        records_solva.removeAll()
        persistToDisk_solva()
    }

    // MARK: 私有：持久化

    private func persistToDisk_solva() {
        do {
            let data_solva = try JSONEncoder().encode(records_solva)
            UserDefaults.standard.set(data_solva, forKey: storageKey_solva)
        } catch {
            debugPrint("对局记录持久化失败：\(error)")
        }
    }

    private func loadFromDisk_solva() {
        guard let data_solva = UserDefaults.standard.data(forKey: storageKey_solva) else { return }
        do {
            records_solva = try JSONDecoder().decode([GameRecord_solva].self, from: data_solva)
        } catch {
            debugPrint("对局记录读取失败：\(error)")
        }
    }
}
