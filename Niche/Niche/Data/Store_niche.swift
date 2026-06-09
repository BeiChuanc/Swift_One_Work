import Foundation
import RMStore

// MARK: 商店数据

/// 商店数据
class Store_Niche: NSObject {
    
    /// 单例
    static let shared_Niche = Store_Niche()
    
    // 礼物商品列表
    var goodsList_Niche: [StoreModel_Niche] = [
        StoreModel_Niche(
            id_Niche: 0,
            goodsId_Niche: "niche.gift.x2.1_9",
            goodsName_Niche: "x2",
            goodsPrice_Niche: "1.99$",
            goodIsTop_Niche: false,
            goodIsLimit_Niche: true
        ),
        StoreModel_Niche(
            id_Niche: 1,
            goodsId_Niche: "niche.gift.x3.3_9",
            goodsName_Niche: "x3",
            goodsPrice_Niche: "3.99$",
            goodIsTop_Niche: false,
            goodIsLimit_Niche: true
        ),
        StoreModel_Niche(
            id_Niche: 2,
            goodsId_Niche: "niche.gift.x5.4_9",
            goodsName_Niche: "x5",
            goodsPrice_Niche: "4.99$",
            goodIsTop_Niche: false,
            goodIsLimit_Niche: true
        ),
        StoreModel_Niche(
            id_Niche: 3,
            goodsId_Niche: "niche.gift.x1.1_9",
            goodsName_Niche: "x1",
            goodsPrice_Niche: "1.99$",
            goodIsTop_Niche: false,
            goodIsLimit_Niche: false
        ),
        StoreModel_Niche(
            id_Niche: 4,
            goodsId_Niche: "niche.gift.x2.2_9",
            goodsName_Niche: "x2",
            goodsPrice_Niche: "2.99$",
            goodIsTop_Niche: false,
            goodIsLimit_Niche: false
        ),
        StoreModel_Niche(
            id_Niche: 5,
            goodsId_Niche: "niche.gift.x3.3_9_s",
            goodsName_Niche: "x3",
            goodsPrice_Niche: "3.99$",
            goodIsTop_Niche: false,
            goodIsLimit_Niche: false
        ),
        StoreModel_Niche(
            id_Niche: 6,
            goodsId_Niche: "niche.gift.x4.4_9",
            goodsName_Niche: "x4",
            goodsPrice_Niche: "4.99$",
            goodIsTop_Niche: false,
            goodIsLimit_Niche: false
        ),
        StoreModel_Niche(
            id_Niche: 7,
            goodsId_Niche: "niche.gift.x5.6_9",
            goodsName_Niche: "x5",
            goodsPrice_Niche: "6.99$",
            goodIsTop_Niche: false,
            goodIsLimit_Niche: false
        ),
        StoreModel_Niche(
            id_Niche: 8,
            goodsId_Niche: "niche.gift.x10.9_9",
            goodsName_Niche: "x10",
            goodsPrice_Niche: "9.99$",
            goodIsTop_Niche: false,
            goodIsLimit_Niche: false
        ),
        StoreModel_Niche(
            id_Niche: 9,
            goodsId_Niche: "niche.gift.x20.19_9",
            goodsName_Niche: "x20",
            goodsPrice_Niche: "19.99$",
            goodIsTop_Niche: false,
            goodIsLimit_Niche: false
        ),
        StoreModel_Niche(
            id_Niche: 10,
            goodsId_Niche: "niche.gift.x30.29_9",
            goodsName_Niche: "x30",
            goodsPrice_Niche: "29.99$",
            goodIsTop_Niche: false,
            goodIsLimit_Niche: false
        ),
        StoreModel_Niche(
            id_Niche: 11,
            goodsId_Niche: "niche.gift.x50.49_9",
            goodsName_Niche: "x50",
            goodsPrice_Niche: "49.99$",
            goodIsTop_Niche: false,
            goodIsLimit_Niche: false
        ),
        StoreModel_Niche(
            id_Niche: 12,
            goodsId_Niche: "niche.gift.x70.69_9",
            goodsName_Niche: "x70",
            goodsPrice_Niche: "69.99$",
            goodIsTop_Niche: false,
            goodIsLimit_Niche: false
        ),
        StoreModel_Niche(
            id_Niche: 13,
            goodsId_Niche: "niche.gift.x100.99_9",
            goodsName_Niche: "x100",
            goodsPrice_Niche: "99.99$",
            goodIsTop_Niche: false,
            goodIsLimit_Niche: false
        )
    ]
    
    private override init() {
        super.init()
    }
}


extension Store_Niche {
    
    // 内购商品
    func PurchaseStoreGift_Niche(gid_Niche: String, completion_Niche: @escaping() -> Void) {
        Utils_Niche.showLoading_Niche()
        
        let products: Set = [gid_Niche]
        RMStore.default().requestProducts(products) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(gid_Niche) { SKPaymentTransaction in
                Utils_Niche.dismissLoading_Niche()
                if SKPaymentTransaction?.transactionState == .purchased {
                    print("支付成功")
                    Utils_Niche.showSuccess_Niche(message_Niche: "Payment successful")
                    
                    NotificationCenter.default.post(name: NSNotification.Name("DazzlRefreshGifts"), object: nil)
                    completion_Niche()
                }else{
                    print("取消支付")
                    Utils_Niche.showError_Niche(message_Niche: "User cancels payment")
                }
                
            } failure: { transaction, error in
                print("商品信息无效")
                Utils_Niche.showError_Niche(message_Niche: "Invalid product information")
            }
        } failure: { error in
            print("商品信息无效")
            Utils_Niche.showError_Niche(message_Niche: "Invalid product information")
        }
    }
    
}
