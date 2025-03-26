import { useState, useEffect } from 'react'

export interface Message {
  id: string
  type: 'user' | 'ai'
  text: string
  timestamp: string
  audioUrl?: string | null
}

export interface Conversation {
  messages: Message[]
}

// Use localStorage to persist conversation history
const STORAGE_KEY = 'conversation_history'

export const useConversationHistory = () => {
  const [conversation, setConversation] = useState<Conversation>(() => {
    // Try to load from localStorage on initial render
    if (typeof window !== 'undefined') {
      const saved = localStorage.getItem(STORAGE_KEY)
      if (saved) {
        try {
          return JSON.parse(saved)
        } catch (e) {
          console.error('Failed to parse saved conversation:', e)
        }
      }
    }
    return { messages: [] }
  })

  // Save to localStorage whenever conversation changes
  // useEffect(() => {
  //   localStorage.setItem(STORAGE_KEY, JSON.stringify(conversation));
  // }, [conversation]);

  const addUserMessage = (text: string, audioUrl?: string | null) => {
    const newMessage: Message = {
      id: Date.now().toString(),
      type: 'user',
      text,
      timestamp: new Date().toISOString(),
      audioUrl: audioUrl,
    }

    setConversation((prev) => ({
      messages: [...prev.messages, newMessage],
    }))

    return newMessage.id
  }

  const addAIResponse = (text: string, audioUrl?: string | null) => {
    const newMessage: Message = {
      id: Date.now().toString(),
      type: 'ai',
      text,
      timestamp: new Date().toISOString(),
      audioUrl,
    }

    setConversation((prev) => ({
      messages: [...prev.messages, newMessage],
    }))

    return newMessage.id
  }

  const clearHistory = () => {
    setConversation({ messages: [] })
    localStorage.removeItem(STORAGE_KEY)
  }

  return {
    conversation,
    addUserMessage,
    addAIResponse,
    clearHistory,
  }
}
