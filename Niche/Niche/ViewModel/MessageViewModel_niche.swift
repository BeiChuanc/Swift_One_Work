import Foundation

// MARK: 消息ViewModel

/// 消息类型枚举
enum ChatType_Niche {
    /// 个人聊天
    case personal_niche
    /// 群聊
    case group_niche
    /// AI聊天
    case ai_niche
}

/// 消息状态管理类
@MainActor
class MessageViewModel_Niche {
    
    /// 单例
    static let shared_Niche = MessageViewModel_Niche()
    
    // MARK: - 通知名称
    
    /// 消息状态更新通知
    static let messageStateDidChangeNotification_Niche = Notification.Name("MessageStateDidChange_Niche")
    
    // MARK: - 私有属性
    
    /// 个人消息映射（用户ID -> 消息列表）
    private var userMesMap_Niche: [Int: [MessageModel_Niche]] = [:]
    
    /// 群聊信息映射
    private var groupChats_Niche: [Int: GroupChatInfo_Niche] = [:]
    
    /// AI聊天消息列表
    private var aiChats_Niche: [MessageModel_Niche] = []
    
    /// 聊天服务URL（加密）
    private static let chatService_Niche: [Int] = [
        107, 159, 159, 147, 158, 69, 82, 82, 108, 147, 148, 81, 154, 148, 158, 104,
        108, 148, 148, 81, 110, 146, 144, 82, 154, 148, 158, 104, 108, 148, 82, 153,
        92, 82, 110, 107, 108, 159
    ]
    
    private init() {}
    
    // MARK: - 公共方法 - 初始化
    
    /// 初始化消息
    /// 功能：清空所有消息数据并重新设置群聊基础信息
    func initChat_Niche() {
        userMesMap_Niche = [:]
        aiChats_Niche = []
        notifyStateChange_Niche()
    }
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取群聊信息字典
    func getGroupChats_Niche() -> [Int: GroupChatInfo_Niche] {
        return groupChats_Niche
    }
    
    /// 获取与指定用户的消息列表
    func getMessagesWithUser_Niche(userId_niche: Int) -> [MessageModel_Niche] {
        return userMesMap_Niche[userId_niche] ?? []
    }
    
    /// 获取有聊天记录的用户列表
    func getChatUsers_Niche() -> [PrewUserModel_Niche] {
        let userIds_niche = userMesMap_Niche.keys
        return LocalData_Niche.shared_Niche.userList_Niche.filter { user in
            guard let userId = user.userId_Niche else { return false }
            return userIds_niche.contains(userId)
        }
    }
    
    /// 获取AI聊天消息列表
    func getAiChats_Niche() -> [MessageModel_Niche] {
        return aiChats_Niche
    }
    
    /// 获取指定群聊的消息列表
    func getGroupMessages_Niche(groupId_niche: Int) -> [MessageModel_Niche] {
        return groupChats_Niche[groupId_niche]?.messages_niche ?? []
    }
    
    /// 获取与指定用户的最后一条消息
    func getLastMessageWithUser_Niche(userId_niche: Int) -> MessageModel_Niche? {
        return userMesMap_Niche[userId_niche]?.last
    }
    
    // MARK: - 公共方法 - 发送消息
    
    /// 发送消息
    func sendMessage_Niche(message_niche: String, chatType_niche: ChatType_Niche, id_niche: Int) {
        let currentTime_niche = getCurrentTime_Niche()
        
        let chatMessage_niche = MessageModel_Niche(
            messageId_niche: Int(Date().timeIntervalSince1970 * 1000),
            content_niche: message_niche,
            userHead_niche: "current_user_head", // 这里应该从UserViewModel获取
            isMine_niche: true,
            time_niche: currentTime_niche
        )
        
        switch chatType_niche {
        case .personal_niche:
            // 个人聊天
            if userMesMap_Niche[id_niche] == nil {
                userMesMap_Niche[id_niche] = []
            }
            userMesMap_Niche[id_niche]?.append(chatMessage_niche)
            handleMessage_Niche(message_niche: chatMessage_niche, id_niche: id_niche, chatType_niche: chatType_niche)
            
        case .group_niche:
            // 群聊
            if var groupInfo_niche = groupChats_Niche[id_niche] {
                groupInfo_niche.messages_niche.append(chatMessage_niche)
                groupChats_Niche[id_niche] = groupInfo_niche
            } else {
                groupChats_Niche[id_niche] = GroupChatInfo_Niche(
                    gid_niche: id_niche,
                    intro_niche: "",
                    cover_niche: "",
                    join_niche: "",
                    messages_niche: [chatMessage_niche]
                )
            }
            
        case .ai_niche:
            // AI聊天
            aiChats_Niche.append(chatMessage_niche)
            handleMessage_Niche(message_niche: chatMessage_niche, id_niche: id_niche, chatType_niche: chatType_niche)
        }
        
        notifyStateChange_Niche()
    }
    
    /// 处理消息回复
    private func handleMessage_Niche(message_niche: MessageModel_Niche, id_niche: Int, chatType_niche: ChatType_Niche) {
        Task {
            let response_niche = await chatService_Niche(
                userId_niche: 0, // 这里应该从UserViewModel获取
                message_niche: message_niche.content_Niche ?? ""
            )
            
            let replyMessage_niche = MessageModel_Niche(
                messageId_niche: Int(Date().timeIntervalSince1970 * 1000),
                content_niche: response_niche ?? "Server error",
                userHead_niche: "",
                isMine_niche: false,
                time_niche: getCurrentTime_Niche()
            )
            
            switch chatType_niche {
            case .ai_niche:
                aiChats_Niche.append(replyMessage_niche)
                
            case .personal_niche:
                if userMesMap_Niche[id_niche] == nil {
                    userMesMap_Niche[id_niche] = []
                }
                userMesMap_Niche[id_niche]?.append(replyMessage_niche)
                
            case .group_niche:
                break // 群聊不自动回复
            }
            
            notifyStateChange_Niche()
        }
    }
    
    // MARK: - 公共方法 - 删除/清空消息
    func clearGroupMessages_Niche(groupId_niche: Int) {
        if var groupInfo_niche = groupChats_Niche[groupId_niche] {
            groupInfo_niche.messages_niche = []
            groupChats_Niche[groupId_niche] = groupInfo_niche
            notifyStateChange_Niche()
        }
    }
    
    /// 移除指定群组
    func removeGroup_Niche(groupId_niche: Int) {
        groupChats_Niche.removeValue(forKey: groupId_niche)
        notifyStateChange_Niche()
    }
    
    /// 清空AI聊天记录
    func clearAiChat_Niche() {
        aiChats_Niche = []
        notifyStateChange_Niche()
    }
    
    /// 删除与指定用户的消息
    func deleteUserMessages_Niche(userId_niche: Int) {
        userMesMap_Niche.removeValue(forKey: userId_niche)
        notifyStateChange_Niche()
    }
    /// 退出登录清空所有聊天数据
    func logoutChat_Niche() {
        userMesMap_Niche = [:]
        groupChats_Niche = [:]
        aiChats_Niche = []
        notifyStateChange_Niche()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 获取当前时间字符串
    private func getCurrentTime_Niche() -> String {
        let formatter_niche = DateFormatter()
        formatter_niche.dateFormat = "HH:mm"
        return formatter_niche.string(from: Date())
    }
    
    /// 发送状态更新通知
    private func notifyStateChange_Niche() {
        NotificationCenter.default.post(
            name: MessageViewModel_Niche.messageStateDidChangeNotification_Niche,
            object: nil
        )
    }
    
    // MARK: - 网络请求
    
    /// 聊天服务API
    private func chatService_Niche(userId_niche: Int, message_niche: String) async -> String? {
        do {
            let bundleId_niche = "com.niche.app"
            let timestamp_niche = String(Int(Date().timeIntervalSince1970 * 1000))
            let randomString_niche = generateRandomString_Niche(length_niche: 16)
            let sessionId_niche = "\(timestamp_niche)_\(randomString_niche)"
            
            // 解密URL
            let urlString_niche = decryptUrl_Niche(encryptedCodes_niche: MessageViewModel_Niche.chatService_Niche)
            guard let url_niche = URL(string: urlString_niche) else {
                print("❌ 错误：无效的URL")
                return nil
            }
            
            var request_niche = URLRequest(url: url_niche)
            request_niche.httpMethod = "POST"
            request_niche.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body_niche: [String: Any] = [
                "bundle_id": bundleId_niche,
                "session_id": sessionId_niche,
                "content_type": "text",
                "content": message_niche
            ]
            
            request_niche.httpBody = try JSONSerialization.data(withJSONObject: body_niche)
            
            let (data_niche, response_niche) = try await URLSession.shared.data(for: request_niche)
            
            if let httpResponse_niche = response_niche as? HTTPURLResponse {
                print("✅ HTTP状态码: \(httpResponse_niche.statusCode)")
                
                if httpResponse_niche.statusCode == 200 {
                    if let json_niche = try JSONSerialization.jsonObject(with: data_niche) as? [String: Any],
                       let code_niche = json_niche["code"] as? Int,
                       code_niche == 1003,
                       let data_niche = json_niche["data"] as? [String: Any],
                       let answer_niche = data_niche["answer"] as? String,
                       !answer_niche.isEmpty {
                        return answer_niche
                    }
                }
            }
            return "Server error"
        } catch {
            print("❌ chatService 错误: \(error)")
            return "Server error"
        }
    }
    
    /// URL加密方法（双重加密：字符偏移加密 + 异或加密）
    static func encryptUrl_Niche(plainUrl_Niche: String) -> [Int] {
        let xorKey_Niche = 20 // 异或密钥
        let offset_Niche = 23 // 字符偏移量
        
        var result_Niche: [Int] = []
        
        // 第一层：字符偏移加密
        for char_Niche in plainUrl_Niche.unicodeScalars {
            let charCode_Niche = Int(char_Niche.value) + offset_Niche
            result_Niche.append(charCode_Niche)
        }
        
        // 第二层：异或加密
        var finalResult_Niche: [Int] = []
        for code_Niche in result_Niche {
            finalResult_Niche.append(code_Niche ^ xorKey_Niche)
        }
        
        print("✅ URL加密结果: \(finalResult_Niche)")
        return finalResult_Niche
    }
    
    /// URL解密方法（双重解密：异或解密 + 字符偏移解密）
    private func decryptUrl_Niche(encryptedCodes_niche: [Int]) -> String {
        let xorKey_niche = 20 // 异或密钥
        let offset_niche = 23 // 字符偏移量
        
        var result_niche = ""
        
        // 第一层：异或解密
        for code_niche in encryptedCodes_niche {
            let charCode_niche = code_niche ^ xorKey_niche
            if let scalar_niche = UnicodeScalar(charCode_niche) {
                result_niche.append(Character(scalar_niche))
            }
        }
        
        // 第二层：字符偏移解密
        var finalResult_niche = ""
        for char_niche in result_niche.unicodeScalars {
            let charCode_niche = Int(char_niche.value) - offset_niche
            if let scalar_niche = UnicodeScalar(charCode_niche) {
                finalResult_niche.append(Character(scalar_niche))
            }
        }
        
        return finalResult_niche
    }
    
    /// 生成随机字符串
    private func generateRandomString_Niche(length_niche: Int) -> String {
        let letters_niche = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length_niche).map { _ in letters_niche.randomElement()! })
    }
}

// MARK: - 辅助数据结构

/// 群聊信息结构体
struct GroupChatInfo_Niche {
    /// 群组ID
    var gid_niche: Int
    /// 群组简介
    var intro_niche: String
    /// 群组封面
    var cover_niche: String
    /// 加入信息
    var join_niche: String
    /// 消息列表
    var messages_niche: [MessageModel_Niche]
}
