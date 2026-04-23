import Foundation

// MARK: 消息ViewModel

/// 消息类型枚举
enum ChatType_Nest {
    /// 个人聊天
    case personal_nest
    /// 群聊
    case group_nest
    /// AI聊天
    case ai_nest
}

/// 消息状态管理类
@MainActor
class MessageViewModel_Nest {
    
    /// 单例
    static let shared_Nest = MessageViewModel_Nest()
    
    // MARK: - 通知名称
    
    /// 消息状态更新通知
    static let messageStateDidChangeNotification_Nest = Notification.Name("MessageStateDidChange_Nest")
    
    // MARK: - 私有属性
    
    /// 个人消息映射（用户ID -> 消息列表）
    private var userMesMap_Nest: [Int: [MessageModel_Nest]] = [:]
    
    /// 群聊信息映射
    private var groupChats_Nest: [Int: GroupChatInfo_Nest] = [:]
    
    /// AI聊天消息列表
    private var aiChats_Nest: [MessageModel_Nest] = []
    
    /// 聊天服务URL（加密）
    private static let chatService_Nest: [Int] = [
        107, 159, 159, 147, 158, 69, 82, 82, 108, 147, 148, 81, 154, 148, 158, 104,
        108, 148, 148, 81, 110, 146, 144, 82, 154, 148, 158, 104, 108, 148, 82, 153,
        92, 82, 110, 107, 108, 159
    ]
    
    private init() {}
    
    // MARK: - 公共方法 - 初始化
    
    /// 初始化消息
    /// 功能：清空所有消息数据并重新设置群聊基础信息
    func initChat_Nest() {
        userMesMap_Nest = [:]
        aiChats_Nest = []
        notifyStateChange_Nest()
    }
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取群聊信息字典
    func getGroupChats_Nest() -> [Int: GroupChatInfo_Nest] {
        return groupChats_Nest
    }
    
    /// 获取与指定用户的消息列表
    func getMessagesWithUser_Nest(userId_nest: Int) -> [MessageModel_Nest] {
        return userMesMap_Nest[userId_nest] ?? []
    }
    
    /// 获取有聊天记录的用户列表
    func getChatUsers_Nest() -> [PrewUserModel_Nest] {
        let userIds_nest = userMesMap_Nest.keys
        return LocalData_Nest.shared_Nest.userList_Nest.filter { user in
            guard let userId = user.userId_Nest else { return false }
            return userIds_nest.contains(userId)
        }
    }
    
    /// 获取AI聊天消息列表
    func getAiChats_Nest() -> [MessageModel_Nest] {
        return aiChats_Nest
    }
    
    /// 获取指定群聊的消息列表
    func getGroupMessages_Nest(groupId_nest: Int) -> [MessageModel_Nest] {
        return groupChats_Nest[groupId_nest]?.messages_nest ?? []
    }
    
    /// 获取与指定用户的最后一条消息
    func getLastMessageWithUser_Nest(userId_nest: Int) -> MessageModel_Nest? {
        return userMesMap_Nest[userId_nest]?.last
    }
    
    // MARK: - 公共方法 - 发送消息
    
    /// 发送消息
    func sendMessage_Nest(message_nest: String, chatType_nest: ChatType_Nest, id_nest: Int) {
        let currentTime_nest = getCurrentTime_Nest()
        
        let chatMessage_nest = MessageModel_Nest(
            messageId_nest: Int(Date().timeIntervalSince1970 * 1000),
            content_nest: message_nest,
            userHead_nest: "current_user_head", // 这里应该从UserViewModel获取
            isMine_nest: true,
            time_nest: currentTime_nest
        )
        
        switch chatType_nest {
        case .personal_nest:
            // 个人聊天
            if userMesMap_Nest[id_nest] == nil {
                userMesMap_Nest[id_nest] = []
            }
            userMesMap_Nest[id_nest]?.append(chatMessage_nest)
            handleMessage_Nest(message_nest: chatMessage_nest, id_nest: id_nest, chatType_nest: chatType_nest)
            
        case .group_nest:
            // 群聊
            if var groupInfo_nest = groupChats_Nest[id_nest] {
                groupInfo_nest.messages_nest.append(chatMessage_nest)
                groupChats_Nest[id_nest] = groupInfo_nest
            } else {
                groupChats_Nest[id_nest] = GroupChatInfo_Nest(
                    gid_nest: id_nest,
                    intro_nest: "",
                    cover_nest: "",
                    join_nest: "",
                    messages_nest: [chatMessage_nest]
                )
            }
            
        case .ai_nest:
            // AI聊天
            aiChats_Nest.append(chatMessage_nest)
            handleMessage_Nest(message_nest: chatMessage_nest, id_nest: id_nest, chatType_nest: chatType_nest)
        }
        
        notifyStateChange_Nest()
    }
    
    /// 处理消息回复
    private func handleMessage_Nest(message_nest: MessageModel_Nest, id_nest: Int, chatType_nest: ChatType_Nest) {
        Task {
            let response_nest = await chatService_Nest(
                userId_nest: 0, // 这里应该从UserViewModel获取
                message_nest: message_nest.content_Nest ?? ""
            )
            
            let replyMessage_nest = MessageModel_Nest(
                messageId_nest: Int(Date().timeIntervalSince1970 * 1000),
                content_nest: response_nest ?? "Server error",
                userHead_nest: "",
                isMine_nest: false,
                time_nest: getCurrentTime_Nest()
            )
            
            switch chatType_nest {
            case .ai_nest:
                aiChats_Nest.append(replyMessage_nest)
                
            case .personal_nest:
                if userMesMap_Nest[id_nest] == nil {
                    userMesMap_Nest[id_nest] = []
                }
                userMesMap_Nest[id_nest]?.append(replyMessage_nest)
                
            case .group_nest:
                break // 群聊不自动回复
            }
            
            notifyStateChange_Nest()
        }
    }
    
    // MARK: - 公共方法 - 删除/清空消息
    func clearGroupMessages_Nest(groupId_nest: Int) {
        if var groupInfo_nest = groupChats_Nest[groupId_nest] {
            groupInfo_nest.messages_nest = []
            groupChats_Nest[groupId_nest] = groupInfo_nest
            notifyStateChange_Nest()
        }
    }
    
    /// 移除指定群组
    func removeGroup_Nest(groupId_nest: Int) {
        groupChats_Nest.removeValue(forKey: groupId_nest)
        notifyStateChange_Nest()
    }
    
    /// 清空AI聊天记录
    func clearAiChat_Nest() {
        aiChats_Nest = []
        notifyStateChange_Nest()
    }
    
    /// 删除与指定用户的消息
    func deleteUserMessages_Nest(userId_nest: Int) {
        userMesMap_Nest.removeValue(forKey: userId_nest)
        notifyStateChange_Nest()
    }
    
    /// 退出登录清空所有聊天数据
    func logoutChat_Nest() {
        userMesMap_Nest = [:]
        groupChats_Nest = [:]
        aiChats_Nest = []
        notifyStateChange_Nest()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 获取当前时间字符串
    private func getCurrentTime_Nest() -> String {
        let formatter_nest = DateFormatter()
        formatter_nest.dateFormat = "HH:mm"
        return formatter_nest.string(from: Date())
    }
    
    /// 发送状态更新通知
    private func notifyStateChange_Nest() {
        NotificationCenter.default.post(
            name: MessageViewModel_Nest.messageStateDidChangeNotification_Nest,
            object: nil
        )
    }
    
    // MARK: - 网络请求
    
    /// 聊天服务API
    private func chatService_Nest(userId_nest: Int, message_nest: String) async -> String? {
        do {
            let bundleId_nest = "com.nest.app"
            let timestamp_nest = String(Int(Date().timeIntervalSince1970 * 1000))
            let randomString_nest = generateRandomString_Nest(length_nest: 16)
            let sessionId_nest = "\(timestamp_nest)_\(randomString_nest)"
            
            // 解密URL
            let urlString_nest = decryptUrl_Nest(encryptedCodes_nest: MessageViewModel_Nest.chatService_Nest)
            guard let url_nest = URL(string: urlString_nest) else {
                print("❌ 错误：无效的URL")
                return nil
            }
            
            var request_nest = URLRequest(url: url_nest)
            request_nest.httpMethod = "POST"
            request_nest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body_nest: [String: Any] = [
                "bundle_id": bundleId_nest,
                "session_id": sessionId_nest,
                "content_type": "text",
                "content": message_nest
            ]
            
            request_nest.httpBody = try JSONSerialization.data(withJSONObject: body_nest)
            
            let (data_nest, response_nest) = try await URLSession.shared.data(for: request_nest)
            
            if let httpResponse_nest = response_nest as? HTTPURLResponse {
                print("✅ HTTP状态码: \(httpResponse_nest.statusCode)")
                
                if httpResponse_nest.statusCode == 200 {
                    if let json_nest = try JSONSerialization.jsonObject(with: data_nest) as? [String: Any],
                       let code_nest = json_nest["code"] as? Int,
                       code_nest == 1003,
                       let data_nest = json_nest["data"] as? [String: Any],
                       let answer_nest = data_nest["answer"] as? String,
                       !answer_nest.isEmpty {
                        return answer_nest
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
    static func encryptUrl_Nest(plainUrl_Nest: String) -> [Int] {
        let xorKey_Nest = 20 // 异或密钥
        let offset_Nest = 23 // 字符偏移量
        
        var result_Nest: [Int] = []
        
        // 第一层：字符偏移加密
        for char_Nest in plainUrl_Nest.unicodeScalars {
            let charCode_Nest = Int(char_Nest.value) + offset_Nest
            result_Nest.append(charCode_Nest)
        }
        
        // 第二层：异或加密
        var finalResult_Nest: [Int] = []
        for code_Nest in result_Nest {
            finalResult_Nest.append(code_Nest ^ xorKey_Nest)
        }
        
        print("✅ URL加密结果: \(finalResult_Nest)")
        return finalResult_Nest
    }
    
    /// URL解密方法（双重解密：异或解密 + 字符偏移解密）
    private func decryptUrl_Nest(encryptedCodes_nest: [Int]) -> String {
        let xorKey_nest = 20 // 异或密钥
        let offset_nest = 23 // 字符偏移量
        
        var result_nest = ""
        
        // 第一层：异或解密
        for code_nest in encryptedCodes_nest {
            let charCode_nest = code_nest ^ xorKey_nest
            if let scalar_nest = UnicodeScalar(charCode_nest) {
                result_nest.append(Character(scalar_nest))
            }
        }
        
        // 第二层：字符偏移解密
        var finalResult_nest = ""
        for char_nest in result_nest.unicodeScalars {
            let charCode_nest = Int(char_nest.value) - offset_nest
            if let scalar_nest = UnicodeScalar(charCode_nest) {
                finalResult_nest.append(Character(scalar_nest))
            }
        }
        
        return finalResult_nest
    }
    
    /// 生成随机字符串
    private func generateRandomString_Nest(length_nest: Int) -> String {
        let letters_nest = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length_nest).map { _ in letters_nest.randomElement()! })
    }
}

// MARK: - 辅助数据结构

/// 群聊信息结构体
struct GroupChatInfo_Nest {
    /// 群组ID
    var gid_nest: Int
    /// 群组简介
    var intro_nest: String
    /// 群组封面
    var cover_nest: String
    /// 加入信息
    var join_nest: String
    /// 消息列表
    var messages_nest: [MessageModel_Nest]
}
