//
//  GameContainerScreen_solva.swift
//  Solva
//
//  游戏容器分发页面。
//  设计思路：NavigationManager_solva 只知道「要打开哪个 GameType_solva」，
//  具体到底渲染哪一套引擎 + 棋盘视图由本文件统一分发，使路由层与具体游戏实现解耦。
//
import SwiftUI

struct GameContainerScreen_solva: View {
    let gameType_solva: GameType_solva

    var body: some View {
        switch gameType_solva {
        case .accordion:
            AccordionGameScreen_solva()
        case .penguin:
            PenguinGameScreen_solva()
        case .osmosis:
            OsmosisGameScreen_solva()
        case .doublePyramid:
            DoublePyramidGameScreen_solva()
        case .fourSeasons:
            FourSeasonsGameScreen_solva()
        }
    }
}
