import Foundation

// MARK: 消息ViewModel

/// 消息类型枚举
enum ChatType_Flick {
    /// 个人聊天
    case personal_flick
    /// 群聊
    case group_flick
    /// AI聊天
    case ai_flick
}

/// 消息状态管理类
@MainActor
class MessageViewModel_Flick {
    
    /// 单例
    static let shared_Flick = MessageViewModel_Flick()
    
    // MARK: - 通知名称
    
    /// 消息状态更新通知
    static let messageStateDidChangeNotification_Flick = Notification.Name("MessageStateDidChange_Flick")
    
    // MARK: - 私有属性
    
    /// 个人消息映射（用户ID -> 消息列表）
    private var userMesMap_Flick: [Int: [MessageModel_Flick]] = [:]
    
    /// 群聊信息映射
    private var groupChats_Flick: [Int: GroupChatInfo_Flick] = [:]
    
    /// AI聊天消息列表
    private var aiChats_Flick: [MessageModel_Flick] = []
    
    /// 聊天服务URL（加密）
    private static let chatService_Flick: [Int] = [
        107, 159, 159, 147, 158, 69, 82, 82, 108, 147, 148, 81, 154, 148, 158, 104,
        108, 148, 148, 81, 110, 146, 144, 82, 154, 148, 158, 104, 108, 148, 82, 153,
        92, 82, 110, 107, 108, 159
    ]
    
    private init() {}
    
    // MARK: - 公共方法 - 初始化
    
    /// 初始化消息
    /// 功能：清空所有消息数据并重新设置群聊基础信息
    func initChat_Flick() {
        userMesMap_Flick = [:]
        aiChats_Flick = []
        notifyStateChange_Flick()
    }
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取群聊信息字典
    func getGroupChats_Flick() -> [Int: GroupChatInfo_Flick] {
        return groupChats_Flick
    }
    
    /// 获取与指定用户的消息列表
    func getMessagesWithUser_Flick(userId_flick: Int) -> [MessageModel_Flick] {
        return userMesMap_Flick[userId_flick] ?? []
    }
    
    /// 获取有聊天记录的用户列表
    func getChatUsers_Flick() -> [PrewUserModel_Flick] {
        let userIds_flick = userMesMap_Flick.keys
        return LocalData_Flick.shared_Flick.userList_Flick.filter { user in
            guard let userId = user.userId_Flick else { return false }
            return userIds_flick.contains(userId)
        }
    }
    
    /// 获取AI聊天消息列表
    func getAiChats_Flick() -> [MessageModel_Flick] {
        return aiChats_Flick
    }
    
    /// 获取指定群聊的消息列表
    func getGroupMessages_Flick(groupId_flick: Int) -> [MessageModel_Flick] {
        return groupChats_Flick[groupId_flick]?.messages_flick ?? []
    }
    
    /// 获取与指定用户的最后一条消息
    func getLastMessageWithUser_Flick(userId_flick: Int) -> MessageModel_Flick? {
        return userMesMap_Flick[userId_flick]?.last
    }
    
    // MARK: - 公共方法 - 发送消息
    
    /// 发送消息
    func sendMessage_Flick(message_flick: String, chatType_flick: ChatType_Flick, id_flick: Int) {
        let currentTime_flick = getCurrentTime_Flick()
        
        let chatMessage_flick = MessageModel_Flick(
            messageId_flick: Int(Date().timeIntervalSince1970 * 1000),
            content_flick: message_flick,
            userHead_flick: "current_user_head", // 这里应该从UserViewModel获取
            isMine_flick: true,
            time_flick: currentTime_flick
        )
        
        switch chatType_flick {
        case .personal_flick:
            // 个人聊天
            if userMesMap_Flick[id_flick] == nil {
                userMesMap_Flick[id_flick] = []
            }
            userMesMap_Flick[id_flick]?.append(chatMessage_flick)
            handleMessage_Flick(message_flick: chatMessage_flick, id_flick: id_flick, chatType_flick: chatType_flick)
            
        case .group_flick:
            // 群聊
            if var groupInfo_flick = groupChats_Flick[id_flick] {
                groupInfo_flick.messages_flick.append(chatMessage_flick)
                groupChats_Flick[id_flick] = groupInfo_flick
            } else {
                groupChats_Flick[id_flick] = GroupChatInfo_Flick(
                    gid_flick: id_flick,
                    intro_flick: "",
                    cover_flick: "",
                    join_flick: "",
                    messages_flick: [chatMessage_flick]
                )
            }
            
        case .ai_flick:
            // AI聊天
            aiChats_Flick.append(chatMessage_flick)
            handleMessage_Flick(message_flick: chatMessage_flick, id_flick: id_flick, chatType_flick: chatType_flick)
        }
        
        notifyStateChange_Flick()
    }
    
    /// 处理消息回复
    private func handleMessage_Flick(message_flick: MessageModel_Flick, id_flick: Int, chatType_flick: ChatType_Flick) {
        Task {
            let response_flick = await chatService_Flick(
                userId_flick: 0, // 这里应该从UserViewModel获取
                message_flick: message_flick.content_Flick ?? ""
            )
            
            let replyMessage_flick = MessageModel_Flick(
                messageId_flick: Int(Date().timeIntervalSince1970 * 1000),
                content_flick: response_flick ?? "Server error",
                userHead_flick: "",
                isMine_flick: false,
                time_flick: getCurrentTime_Flick()
            )
            
            switch chatType_flick {
            case .ai_flick:
                aiChats_Flick.append(replyMessage_flick)
                
            case .personal_flick:
                if userMesMap_Flick[id_flick] == nil {
                    userMesMap_Flick[id_flick] = []
                }
                userMesMap_Flick[id_flick]?.append(replyMessage_flick)
                
            case .group_flick:
                break // 群聊不自动回复
            }
            
            notifyStateChange_Flick()
        }
    }
    
    // MARK: - 公共方法 - 删除/清空消息
    func clearGroupMessages_Flick(groupId_flick: Int) {
        if var groupInfo_flick = groupChats_Flick[groupId_flick] {
            groupInfo_flick.messages_flick = []
            groupChats_Flick[groupId_flick] = groupInfo_flick
            notifyStateChange_Flick()
        }
    }
    
    /// 移除指定群组
    func removeGroup_Flick(groupId_flick: Int) {
        groupChats_Flick.removeValue(forKey: groupId_flick)
        notifyStateChange_Flick()
    }
    
    /// 清空AI聊天记录
    func clearAiChat_Flick() {
        aiChats_Flick = []
        notifyStateChange_Flick()
    }
    
    /// 删除与指定用户的消息
    func deleteUserMessages_Flick(userId_flick: Int) {
        userMesMap_Flick.removeValue(forKey: userId_flick)
        notifyStateChange_Flick()
    }
    
    /// 退出登录清空所有聊天数据
    func logoutChat_Flick() {
        userMesMap_Flick = [:]
        groupChats_Flick = [:]
        aiChats_Flick = []
        notifyStateChange_Flick()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 获取当前时间字符串
    private func getCurrentTime_Flick() -> String {
        let formatter_flick = DateFormatter()
        formatter_flick.dateFormat = "HH:mm"
        return formatter_flick.string(from: Date())
    }
    
    /// 发送状态更新通知
    private func notifyStateChange_Flick() {
        NotificationCenter.default.post(
            name: MessageViewModel_Flick.messageStateDidChangeNotification_Flick,
            object: nil
        )
    }
    
    // MARK: - 网络请求
    
    /// 聊天服务API
    private func chatService_Flick(userId_flick: Int, message_flick: String) async -> String? {
        do {
            let bundleId_flick = "com.flick.app"
            let timestamp_flick = String(Int(Date().timeIntervalSince1970 * 1000))
            let randomString_flick = generateRandomString_Flick(length_flick: 16)
            let sessionId_flick = "\(timestamp_flick)_\(randomString_flick)"
            
            // 解密URL
            let urlString_flick = decryptUrl_Flick(encryptedCodes_flick: MessageViewModel_Flick.chatService_Flick)
            guard let url_flick = URL(string: urlString_flick) else {
                print("❌ 错误：无效的URL")
                return nil
            }
            
            var request_flick = URLRequest(url: url_flick)
            request_flick.httpMethod = "POST"
            request_flick.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body_flick: [String: Any] = [
                "bundle_id": bundleId_flick,
                "session_id": sessionId_flick,
                "content_type": "text",
                "content": message_flick
            ]
            
            request_flick.httpBody = try JSONSerialization.data(withJSONObject: body_flick)
            
            let (data_flick, response_flick) = try await URLSession.shared.data(for: request_flick)
            
            if let httpResponse_flick = response_flick as? HTTPURLResponse {
                print("✅ HTTP状态码: \(httpResponse_flick.statusCode)")
                
                if httpResponse_flick.statusCode == 200 {
                    if let json_flick = try JSONSerialization.jsonObject(with: data_flick) as? [String: Any],
                       let code_flick = json_flick["code"] as? Int,
                       code_flick == 1003,
                       let data_flick = json_flick["data"] as? [String: Any],
                       let answer_flick = data_flick["answer"] as? String,
                       !answer_flick.isEmpty {
                        return answer_flick
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
    static func encryptUrl_Flick(plainUrl_Flick: String) -> [Int] {
        let xorKey_Flick = 20 // 异或密钥
        let offset_Flick = 23 // 字符偏移量
        
        var result_Flick: [Int] = []
        
        // 第一层：字符偏移加密
        for char_Flick in plainUrl_Flick.unicodeScalars {
            let charCode_Flick = Int(char_Flick.value) + offset_Flick
            result_Flick.append(charCode_Flick)
        }
        
        // 第二层：异或加密
        var finalResult_Flick: [Int] = []
        for code_Flick in result_Flick {
            finalResult_Flick.append(code_Flick ^ xorKey_Flick)
        }
        
        print("✅ URL加密结果: \(finalResult_Flick)")
        return finalResult_Flick
    }
    
    /// URL解密方法（双重解密：异或解密 + 字符偏移解密）
    private func decryptUrl_Flick(encryptedCodes_flick: [Int]) -> String {
        let xorKey_flick = 20 // 异或密钥
        let offset_flick = 23 // 字符偏移量
        
        var result_flick = ""
        
        // 第一层：异或解密
        for code_flick in encryptedCodes_flick {
            let charCode_flick = code_flick ^ xorKey_flick
            if let scalar_flick = UnicodeScalar(charCode_flick) {
                result_flick.append(Character(scalar_flick))
            }
        }
        
        // 第二层：字符偏移解密
        var finalResult_flick = ""
        for char_flick in result_flick.unicodeScalars {
            let charCode_flick = Int(char_flick.value) - offset_flick
            if let scalar_flick = UnicodeScalar(charCode_flick) {
                finalResult_flick.append(Character(scalar_flick))
            }
        }
        
        return finalResult_flick
    }
    
    /// 生成随机字符串
    private func generateRandomString_Flick(length_flick: Int) -> String {
        let letters_flick = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length_flick).map { _ in letters_flick.randomElement()! })
    }
}

// MARK: - 辅助数据结构

/// 群聊信息结构体
struct GroupChatInfo_Flick {
    /// 群组ID
    var gid_flick: Int
    /// 群组简介
    var intro_flick: String
    /// 群组封面
    var cover_flick: String
    /// 加入信息
    var join_flick: String
    /// 消息列表
    var messages_flick: [MessageModel_Flick]
}
