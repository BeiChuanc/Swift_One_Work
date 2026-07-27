//
//  DeckFactory_solva.swift
//  Solva
//
//  牌堆构建工具。
//  设计思路：5 款游戏都需要「生成一副/两副洗好的牌」，抽出公共工具方法避免重复实现，
//  同时保证每次新开局都是真随机洗牌（Fisher-Yates 由 Swift 标准库 shuffled() 提供）。
//
import Foundation

enum DeckFactory_solva {

    /// 生成一副标准 52 张牌（未洗牌），deckTag 用于区分双副牌场景
    static func standardDeck_solva(deckTag: Int = 0) -> [Card_solva] {
        var deck_solva: [Card_solva] = []
        for suit_solva in Suit_solva.allCases {
            for rank_solva in Rank_solva.allCases {
                deck_solva.append(Card_solva(suit: suit_solva, rank: rank_solva, deckTag: deckTag))
            }
        }
        return deck_solva
    }

    /// 生成并洗好一副 52 张牌
    static func shuffledDeck_solva(deckTag: Int = 0) -> [Card_solva] {
        standardDeck_solva(deckTag: deckTag).shuffled()
    }

    /// 生成两副合并后的 104 张牌并整体洗牌（用于双金字塔纸牌）
    static func shuffledDoubleDeck_solva() -> [Card_solva] {
        (standardDeck_solva(deckTag: 0) + standardDeck_solva(deckTag: 1)).shuffled()
    }
}
