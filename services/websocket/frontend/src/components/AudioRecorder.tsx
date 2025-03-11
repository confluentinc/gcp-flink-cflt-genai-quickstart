import { useState } from "react";
import { Card } from "@/components/ui/card";
import { RecordingResults } from "./RecordingResults";
import { InputModeSelector } from "./InputModeSelector";
import { AudioRecorderControls } from "./AudioRecorderControls";
import { TextInputForm } from "./TextInputForm";
import { useAudioRecorder } from "@/hooks/useAudioRecorder";
import { useMessageProcessor } from "@/hooks/useMessageProcessor";

export const AudioRecorder = () => {
  const [inputMode, setInputMode] = useState<"audio" | "text">("audio");
  
  const {
    isRecording,
    isPaused,
    audioURL,
    duration,
    formatDuration,
    startRecording,
    stopRecording,
    pauseRecording,
    cancelRecording
  } = useAudioRecorder();
  
  const {
    results,
    isProcessing,
    responseAudioUrl,
    processAudioRecording,
    processTextMessage
  } = useMessageProcessor();

  const handleStopRecording = async () => {
    const audioBlob = await stopRecording();
    if (audioBlob) {
      processAudioRecording(audioBlob);
    }
  };

  return (
    <div className="space-y-8 w-full max-w-3xl mx-auto">
      <Card className="w-full p-6 space-y-6 animate-fadeIn">
        <div className="space-y-2 text-center">
          <h2 className="text-2xl font-semibold tracking-tight">AI Health Assistant</h2>
          <p className="text-sm text-muted-foreground">Record or type your health-related questions</p>
          {isProcessing && (
            <p className="text-sm text-muted-foreground animate-pulse">Processing your request...</p>
          )}
        </div>
        
        <InputModeSelector 
          mode={inputMode} 
          onChange={setInputMode} 
        />
        
        {inputMode === "audio" ? (
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
          </>
        ) : (
          <TextInputForm 
            onSubmit={processTextMessage} 
            isProcessing={isProcessing} 
          />
        )}
      </Card>
      
      <RecordingResults 
        results={results} 
        audioUrl={audioURL}
        responseAudioUrl={responseAudioUrl}
        isProcessing={isProcessing} 
      />
    </div>
  );
};

c8e18984-5b2e-3297-85cf-8f6535526897 