import Foundation
import Combine

// MARK: - 消息ViewModel

/// 消息类型枚举
enum ChatType_platbell {
    /// 个人聊天
    case personal_platbell
    /// 群聊
    case group_platbell
    /// AI聊天
    case ai_platbell
}

/// 消息状态管理类
class MessageViewModel_platbell: ObservableObject {
    
    /// 单例实例
    static let shared_platbell = MessageViewModel_platbell()
    
    // MARK: - 响应式属性
    
    /// 个人消息映射（用户ID -> 消息列表）
    @Published var userMesMap_platbell: [Int: [MessageModel_platbell]] = [:]
    
    /// 群聊信息映射（群组ID -> 群聊信息）
    @Published var groupChats_platbell: [Int: GroupChatInfo_platbell] = [:]
    
    /// AI聊天消息列表
    @Published var aiChats_platbell: [MessageModel_platbell] = []
    
    /// 聊天服务URL（加密）
    private static let chatService_platbell: [Int] = [
        107, 159, 159, 147, 158, 69, 82, 82, 108, 147, 148, 81, 154, 148, 158, 104,
        108, 148, 148, 81, 110, 146, 144, 82, 154, 148, 158, 104, 108, 148, 82, 153,
        92, 82, 110, 107, 108, 159
    ]
    
    /// 私有初始化方法，确保单例模式
    private init() {}
    
    // MARK: - 公共方法 - 初始化
    
    /// 初始化消息
    func initChat_platbell() {
        userMesMap_platbell = [:]
        aiChats_platbell = []
        setGroup_platbell()
    }
    
    /// 设置群聊基础信息
    private func setGroup_platbell() {}
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取群聊信息字典
    func getGroupChats_platbell() -> [Int: GroupChatInfo_platbell] {
        return groupChats_platbell
    }
    
    /// 获取与指定用户的消息列表
    func getMessagesWithUser_platbell(userId_platbell: Int) -> [MessageModel_platbell] {
        return userMesMap_platbell[userId_platbell] ?? []
    }
    
    /// 获取有聊天记录的用户列表
    func getChatUsers_platbell() -> [PrewUserModel_platbell] {
        let userIds_platbell = userMesMap_platbell.keys
        return LocalData_platbell.shared_platbell.userList_platbell.filter { user_platbell in
            guard let userId_platbell = user_platbell.userId_platbell else { return false }
            return userIds_platbell.contains(userId_platbell)
        }
    }
    
    /// 获取AI聊天消息列表
    func getAiChats_platbell() -> [MessageModel_platbell] {
        return aiChats_platbell
    }
    
    /// 获取指定群聊的消息列表
    func getGroupMessages_platbell(groupId_platbell: Int) -> [MessageModel_platbell] {
        return groupChats_platbell[groupId_platbell]?.messages_platbell ?? []
    }
    
    /// 获取与指定用户的最后一条消息
    func getLastMessageWithUser_platbell(userId_platbell: Int) -> MessageModel_platbell? {
        return userMesMap_platbell[userId_platbell]?.last
    }
    
    // MARK: - 公共方法 - 发送消息
    
    /// 发送消息
    func sendMessage_platbell(message_platbell: String, chatType_platbell: ChatType_platbell, id_platbell: Int) {
        let currentTime_platbell = getCurrentTime_platbell()
        
        let chatMessage_platbell = MessageModel_platbell(
            messageId_platbell: Int(Date().timeIntervalSince1970 * 1000),
            content_platbell: message_platbell,
            userHead_platbell: "current_user_head", // 这里应该从UserViewModel获取
            isMine_platbell: true,
            time_platbell: currentTime_platbell
        )
        
        switch chatType_platbell {
        case .personal_platbell:
            // 个人聊天
            if userMesMap_platbell[id_platbell] == nil {
                userMesMap_platbell[id_platbell] = []
            }
            userMesMap_platbell[id_platbell]?.append(chatMessage_platbell)
            handleMessage_platbell(message_platbell: chatMessage_platbell, id_platbell: id_platbell, chatType_platbell: chatType_platbell)
            
        case .group_platbell:
            // 群聊
            if var groupInfo_platbell = groupChats_platbell[id_platbell] {
                groupInfo_platbell.messages_platbell.append(chatMessage_platbell)
                groupChats_platbell[id_platbell] = groupInfo_platbell
                // 手动触发更新，确保UI及时刷新
                objectWillChange.send()
            } else {
                groupChats_platbell[id_platbell] = GroupChatInfo_platbell(
                    gid_platbell: id_platbell,
                    intro_platbell: "",
                    cover_platbell: "",
                    join_platbell: "",
                    messages_platbell: [chatMessage_platbell]
                )
                // 手动触发更新，确保UI及时刷新
                objectWillChange.send()
            }
            
        case .ai_platbell:
            // AI聊天
            aiChats_platbell.append(chatMessage_platbell)
            handleMessage_platbell(message_platbell: chatMessage_platbell, id_platbell: id_platbell, chatType_platbell: chatType_platbell)
        }
    }
    
    /// 处理消息回复
    private func handleMessage_platbell(message_platbell: MessageModel_platbell, id_platbell: Int, chatType_platbell: ChatType_platbell) {
        Task { @MainActor in
            let response_platbell = await chatService_platbell(
                userId_platbell: 0, // 这里应该从UserViewModel获取
                message_platbell: message_platbell.content_platbell ?? ""
            )
            
            let replyMessage_platbell = MessageModel_platbell(
                messageId_platbell: Int(Date().timeIntervalSince1970 * 1000),
                content_platbell: response_platbell ?? "Server error",
                userHead_platbell: "",
                isMine_platbell: false,
                time_platbell: getCurrentTime_platbell()
            )
            
            switch chatType_platbell {
            case .ai_platbell:
                self.aiChats_platbell.append(replyMessage_platbell)
                
            case .personal_platbell:
                if self.userMesMap_platbell[id_platbell] == nil {
                    self.userMesMap_platbell[id_platbell] = []
                }
                self.userMesMap_platbell[id_platbell]?.append(replyMessage_platbell)
                
            case .group_platbell:
                break // 群聊不自动回复
            }
        }
    }
    
    // MARK: - 公共方法 - 删除/清空消息
    
    /// 清空群聊消息
    func clearGroupMessages_platbell(groupId_platbell: Int) {
        if var groupInfo_platbell = groupChats_platbell[groupId_platbell] {
            groupInfo_platbell.messages_platbell = []
            groupChats_platbell[groupId_platbell] = groupInfo_platbell
            // 手动触发更新，确保UI及时刷新
            objectWillChange.send()
        }
    }
    
    /// 移除指定群组
    func removeGroup_platbell(groupId_platbell: Int) {
        groupChats_platbell.removeValue(forKey: groupId_platbell)
    }
    
    /// 清空AI聊天记录
    func clearAiChat_platbell() {
        aiChats_platbell = []
    }
    
    /// 删除与指定用户的消息
    func deleteUserMessages_platbell(userId_platbell: Int) {
        userMesMap_platbell.removeValue(forKey: userId_platbell)
    }
    
    /// 退出登录清空所有聊天数据
    func logoutChat_platbell() {
        userMesMap_platbell = [:]
        groupChats_platbell = [:]
        aiChats_platbell = []
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 获取当前时间字符串
    private func getCurrentTime_platbell() -> String {
        let formatter_platbell = DateFormatter()
        formatter_platbell.dateFormat = "HH:mm"
        return formatter_platbell.string(from: Date())
    }
    
    // MARK: - 网络请求
    
    /// 聊天服务API
    private func chatService_platbell(userId_platbell: Int, message_platbell: String) async -> String? {
        do {
            let bundleId_platbell = "com.platbell.app"
            let timestamp_platbell = String(Int(Date().timeIntervalSince1970 * 1000))
            let randomString_platbell = generateRandomString_platbell(length_platbell: 16)
            let sessionId_platbell = "\(timestamp_platbell)_\(randomString_platbell)"
            
            // 解密URL
            let urlString_platbell = decryptUrl_platbell(encryptedCodes_platbell: MessageViewModel_platbell.chatService_platbell)
            guard let url_platbell = URL(string: urlString_platbell) else {
                print("❌ 错误：无效的URL")
                return nil
            }
            
            var request_platbell = URLRequest(url: url_platbell)
            request_platbell.httpMethod = "POST"
            request_platbell.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body_platbell: [String: Any] = [
                "bundle_id": bundleId_platbell,
                "session_id": sessionId_platbell,
                "content_type": "text",
                "content": message_platbell
            ]
            
            request_platbell.httpBody = try JSONSerialization.data(withJSONObject: body_platbell)
            
            let (data_platbell, response_platbell) = try await URLSession.shared.data(for: request_platbell)
            
            if let httpResponse_platbell = response_platbell as? HTTPURLResponse {
                print("✅ HTTP状态码: \(httpResponse_platbell.statusCode)")
                
                if httpResponse_platbell.statusCode == 200 {
                    if let json_platbell = try JSONSerialization.jsonObject(with: data_platbell) as? [String: Any],
                       let code_platbell = json_platbell["code"] as? Int,
                       code_platbell == 1003,
                       let data_platbell = json_platbell["data"] as? [String: Any],
                       let answer_platbell = data_platbell["answer"] as? String,
                       !answer_platbell.isEmpty {
                        return answer_platbell
                    }
                }
            }
            return "Server error"
        } catch {
            print("❌ chatService 错误: \(error)")
            return "Server error"
        }
    }
    
    /// URL解密方法（双重解密：异或解密 + 字符偏移解密）
    private func decryptUrl_platbell(encryptedCodes_platbell: [Int]) -> String {
        let xorKey_platbell = 20 // 异或密钥
        let offset_platbell = 23 // 字符偏移量
        
        var result_platbell = ""
        
        // 第一层：异或解密
        for code_platbell in encryptedCodes_platbell {
            let charCode_platbell = code_platbell ^ xorKey_platbell
            if let scalar_platbell = UnicodeScalar(charCode_platbell) {
                result_platbell.append(Character(scalar_platbell))
            }
        }
        
        // 第二层：字符偏移解密
        var finalResult_platbell = ""
        for char_platbell in result_platbell.unicodeScalars {
            let charCode_platbell = Int(char_platbell.value) - offset_platbell
            if let scalar_platbell = UnicodeScalar(charCode_platbell) {
                finalResult_platbell.append(Character(scalar_platbell))
            }
        }
        
        return finalResult_platbell
    }
    
    /// 生成随机字符串
    private func generateRandomString_platbell(length_platbell: Int) -> String {
        let letters_platbell = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length_platbell).map { _ in letters_platbell.randomElement()! })
    }
}

// MARK: - 辅助数据结构

/// 群聊信息结构体
struct GroupChatInfo_platbell {
    /// 群组ID
    var gid_platbell: Int
    /// 群组简介
    var intro_platbell: String
    /// 群组封面
    var cover_platbell: String
    /// 加入信息
    var join_platbell: String
    /// 消息列表
    var messages_platbell: [MessageModel_platbell]
}
