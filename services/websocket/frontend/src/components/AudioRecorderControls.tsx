import { Button } from "@/components/ui/button";
import { Mic, Square, Play, Pause, X } from "lucide-react";

interface AudioRecorderControlsProps {
  isRecording: boolean;
  isPaused: boolean;
  duration: number;
  formatDuration: (seconds: number) => string;
  startRecording: () => void;
  stopRecording: () => void;
  pauseRecording: () => void;
  cancelRecording: () => void;
}

export const AudioRecorderControls = ({
  isRecording,
  isPaused,
  duration,
  formatDuration,
  startRecording,
  stopRecording,
  pauseRecording,
  cancelRecording
}: AudioRecorderControlsProps) => {
  return (
    <div className="flex flex-col items-center gap-4">
      <div className="relative w-32 h-32 flex items-center justify-center">
        <div 
          className={`absolute inset-0 bg-primary/10 rounded-full ${
            isRecording && !isPaused ? 'animate-[pulse_2s_cubic-bezier(0.4,0,0.6,1)_infinite]' : ''
          }`} 
        />
        {isRecording && !isPaused && (
          <div className="absolute inset-0 flex items-center justify-center">
            <div className="flex gap-1">
            </div>
          </div>
        )}
        <Button
          variant="ghost"
          size="icon"
          className={`w-20 h-20 rounded-full transform active:scale-95 transition-all duration-200 ${
            isRecording 
              ? isPaused 
              ? 'bg-amber-500 hover:bg-amber-600' 
              : 'bg-red-500 hover:bg-red-600 animate-pulse' 
              : 'bg-primary hover:bg-primary/90'
          }`}
          onClick={isRecording ? stopRecording : startRecording}
        >
          {isRecording ? (
            <Square className="w-8 h-8 text-white" />
          ) : (
            <Mic className="w-8 h-8 text-white" />
          )}
        </Button>
      </div>
      {isRecording && (
        <>
          <p className="text-lg font-semibold text-primary">{formatDuration(duration)}</p>
          <div className="flex gap-2">
            <Button
              variant="outline"
              size="icon"
              onClick={pauseRecording}
              className="rounded-full"
            >
              {isPaused ? <Play className="w-4 h-4" /> : <Pause className="w-4 h-4" />}
            </Button>
            <Button
              variant="outline"
              size="icon"
              onClick={cancelRecording}
              className="rounded-full"
            >
              <X className="w-4 h-4" />
            </Button>
          </div>
        </>
      )}
    </div>
  );
};