import { useState, useEffect, useRef } from 'react'
import { Card } from '@/components/ui/card'
import { RecordingResults } from './RecordingResults'
import { InputModeSelector } from './InputModeSelector'
import { AudioRecorderControls } from './AudioRecorderControls'
import { TextInputForm } from './TextInputForm'
import { AudioDisplay } from './AudioDisplay'
import { useAudioRecorder } from '@/hooks/useAudioRecorder'
import { useMessageProcessor } from '@/hooks/useMessageProcessor'
import { useConversationHistory } from '@/hooks/useConversationHistory'
import { Button } from './ui/button'
import { Trash2 } from 'lucide-react'
import { useToast } from '@/hooks/use-toast'

export const AudioRecorder = () => {
  const [inputMode, setInputMode] = useState<'audio' | 'text'>('audio')
  const { toast } = useToast()
  // For tracking processed responses to avoid duplicates
  // Track the current conversation exchange with a unique ID
  const currentConversationIdRef = useRef<string | null>(null)

  // Keep track of processed responses to avoid duplicates
  const processedResponsesRef = useRef<Set<string>>(new Set())

  // Flag to indicate if we're expecting a response
  const isAwaitingResponseRef = useRef<boolean>(false)

  const {
    isRecording,
    isPaused,
    audioURL,
    duration,
    formatDuration,
    startRecording,
    stopRecording,
    pauseRecording,
    cancelRecording,
    maxDuration,
  } = useAudioRecorder()

  const {
    result,
    isProcessing,
    responseAudioUrl,
    processAudioRecording,
    processTextMessage,
    clearConversationId,
  } = useMessageProcessor()

  const { conversation, addUserMessage, addAIResponse, clearHistory } = useConversationHistory()

  // Update conversation history when result changes
  useEffect(() => {
    if (result && !isProcessing && isAwaitingResponseRef.current) {
      console.log('Processing result with conversation ID:', result.timestamp)

      // Only proceed if the result has a valid conversation ID
      if (result.timestamp && result.timestamp === currentConversationIdRef.current) {
        console.log('Result matches current conversation ID')

        // Only add the AI response if there's actual content and we haven't processed it yet
        if (result.response && !processedResponsesRef.current.has(result.timestamp)) {
          console.log('Adding new AI response for conversation:', result.timestamp)

          // Mark this conversation as processed
          processedResponsesRef.current.add(result.timestamp)

          // Add the AI response
          addAIResponse(result.response, responseAudioUrl)

          // Reset flags after successfully processing
          isAwaitingResponseRef.current = false

          // Tell the message processor we're done with this conversation
          clearConversationId()
        } else {
          console.log('Skipping empty or already processed response')
        }
      } else {
        console.log('Result conversation ID does not match current conversation ID')
      }
    }
  }, [result, isProcessing, responseAudioUrl, addAIResponse, clearConversationId])

  const handleStopRecording = async () => {
    const audioBlob = await stopRecording()
    if (audioBlob) {
      // Generate a unique conversation ID
      const conversationId = `audio-${Date.now()}-${Math.random().toString(36).substring(2, 9)}`
      currentConversationIdRef.current = conversationId

      // Reset last response reference for new conversation turn
      isAwaitingResponseRef.current = true

      // Set flag that we're now awaiting a response
      isAwaitingResponseRef.current = true

      // Add user message with transcript (empty for now) and audio URL
      addUserMessage(result?.transcript || 'Audio message from user', audioBlob)

      // Process the recording with the conversation ID
      processAudioRecording(audioBlob, conversationId)
    }
  }

  const handleTextSubmit = (text: string) => {
    // Add user text message
    addUserMessage(text)

    // Generate a unique conversation ID
    const conversationId = `text-${Date.now()}-${Math.random().toString(36).substring(2, 9)}`
    currentConversationIdRef.current = conversationId

    // Reset last response reference for new conversation turn
    isAwaitingResponseRef.current = true

    // Set flag that we're now awaiting a response
    isAwaitingResponseRef.current = true

    // Process the text message with the conversation ID
    processTextMessage(text, conversationId)
  }

  const handleClearHistory = () => {
    clearHistory()
    // Reset the last response tracker when clearing history
    currentConversationIdRef.current = null
    isAwaitingResponseRef.current = false
    processedResponsesRef.current.clear()
    clearConversationId()
    toast({
      title: 'History cleared',
      description: 'Your conversation history has been deleted',
    })
  }

  return (
    <div className="space-y-0 w-full max-w-2xl mx-auto bg-[#DCF7FB] p-10 rounded-lg">
      <Card className="w-full p-6 space-y-6 animate-fadeIn">
        <div className="space-y-2 text-center">
          <h2 className="text-3xl font-semibold tracking-tight">AI Patient Health Assistant</h2>
          <p className="text-base text-muted-foreground">
            Record or type your patient-related questions
          </p>
        </div>

        <InputModeSelector
          mode={inputMode}
          onChange={setInputMode}
        />

        {inputMode === 'audio' ? (
          <>
            <AudioRecorderControls
              isRecording={isRecording}
              isPaused={isPaused}
              duration={duration}
              formatDuration={formatDuration}
              startRecording={startRecording}
              stopRecording={handleStopRecording}
              pauseRecording={pauseRecording}
              cancelRecording={cancelRecording}
            />
            {!isRecording && (
              <div className="text-center text-xs text-muted-foreground">
                Maximum recording time: {maxDuration} seconds
              </div>
            )}
          </>
        ) : (
          <TextInputForm
            onSubmit={handleTextSubmit}
            isProcessing={isProcessing}
          />
        )}
      </Card>

      {conversation.messages.length > 0 && (
        <div
          style={{
            display: 'flex',
            justifyContent: 'right',
            marginTop: '30px',
            marginBottom: '10px',
          }}
        >
          <Button
            variant="outline"
            size="sm"
            onClick={handleClearHistory}
            className="flex items-center gap-2 mr-2 "
          >
            <Trash2 className="h-4 w-4" />
            Clear History
          </Button>
        </div>
      )}

      <RecordingResults
        messages={[...conversation.messages].reverse()}
        isProcessing={isProcessing}
      />
    </div>
  )
}
