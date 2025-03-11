import { useState, useRef, useEffect } from "react";
import { useToast } from "@/components/ui/use-toast";
import { bytesToBase64DataUrl } from "@/lib/utils";

export interface RecordingResult {
  messageId: string;
  timestamp: string;
  question: string;
  response: string;
  audioUrl?: string; // Optional property for audio data URL
}

export const useAudioRecorder = () => {
  const [isRecording, setIsRecording] = useState(false);
  const [isPaused, setIsPaused] = useState(false);
  const [audioURL, setAudioURL] = useState<string | null>(null);
  const [duration, setDuration] = useState(0);
  const mediaRecorderRef = useRef<MediaRecorder | null>(null);
  const chunksRef = useRef<Blob[]>([]);
  const timerRef = useRef<NodeJS.Timeout | null>(null);
  const { toast } = useToast();

  const startTimer = () => {
    timerRef.current = setInterval(() => {
      setDuration((prev) => prev + 1);
    }, 1000);
  };

  const stopTimer = () => {
    if (timerRef.current) {
      clearInterval(timerRef.current);
      timerRef.current = null;
    }
  };

  const formatDuration = (seconds: number) => {
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;
    return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`;
  };

  const startRecording = async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      const options = { mimeType: 'audio/webm; codecs=opus' };
      mediaRecorderRef.current = new MediaRecorder(stream, options);

      mediaRecorderRef.current.ondataavailable = (e) => {
        if (e.data.size > 0) {
          chunksRef.current.push(e.data);
        }
      };

      mediaRecorderRef.current.onstop = async () => {
        const blob = new Blob(chunksRef.current, { type: "audio/webm" });
        const url = URL.createObjectURL(blob);
        setAudioURL(url);
        setDuration(0);
      };

      mediaRecorderRef.current.start();
      setIsRecording(true);
      setIsPaused(false);
      startTimer();
      toast({
        title: "Recording started",
        description: "Speak clearly into your microphone",
      });
    } catch (err) {
      console.error("Error accessing microphone:", err);
      toast({
        title: "Error",
        description: "Could not access microphone",
        variant: "destructive",
      });
    }
  };

  const stopRecording = async () => {
    if (mediaRecorderRef.current) {
      await new Promise((resolve) => {
        mediaRecorderRef.current.onstop = resolve;
        mediaRecorderRef.current.stop();
        mediaRecorderRef.current.stream.getTracks().forEach(track => track.stop());
      });

      setIsRecording(false);
      setIsPaused(false);
      stopTimer();
      setDuration(0); // Resetting the duration

      const blob = new Blob(chunksRef.current, { type: 'audio/webm' });
      const audioUrl = URL.createObjectURL(blob);
      setAudioURL(audioUrl);

      // Acknowledge the end of recording
      toast({
        title: "Recording stopped",
        description: "Your message has been recorded",
      });

      // Resetting chunks for the next recording
      chunksRef.current = [];

      // Prepare and send the data over WebSocket
      const buffer = await blob.arrayBuffer();
      const base64DataUrl = await bytesToBase64DataUrl(new Uint8Array(buffer), 'audio/webm');

      return base64DataUrl as String
    }
  };

  const pauseRecording = () => {
    if (mediaRecorderRef.current && isRecording && !isPaused) {
      mediaRecorderRef.current.pause();
      setIsPaused(true);
      stopTimer();
      toast({
        title: "Recording paused",
        description: "Click resume to continue recording",
      });
    } else if (mediaRecorderRef.current && isRecording && isPaused) {
      mediaRecorderRef.current.resume();
      setIsPaused(false);
      startTimer();
      toast({
        title: "Recording resumed",
        description: "Continue speaking into your microphone",
      });
    }
  };

  const cancelRecording = () => {
    if (mediaRecorderRef.current && isRecording) {
      mediaRecorderRef.current.stream.getTracks().forEach(track => track.stop());
      setIsRecording(false);
      setIsPaused(false);
      setDuration(0);
      stopTimer();
      chunksRef.current = [];
      toast({
        title: "Recording cancelled",
        description: "The recording has been discarded",
      });
    }
  };

  useEffect(() => {
    return () => {
      if (timerRef.current) {
        clearInterval(timerRef.current);
      }
    };
  }, []);

  return {
    isRecording,
    isPaused,
    audioURL,
    duration,
    formatDuration,
    startRecording,
    stopRecording,
    pauseRecording,
    cancelRecording
  };
};