import { useState, useRef, useEffect } from "react";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Mic, Square, Play, Pause, X } from "lucide-react";
import { useToast } from "@/components/ui/use-toast";
import { RecordingResults } from "@/components/RecordingResults";
import { bytesToBase64DataUrl } from "@/components/utils";
import { useWebSocket } from "@/components/WebSocketProvider"; 

interface RecordingResult {
    timestamp: string;
    transcript: string;
    response: string;
    result: string;
}

export const AudioRecorderNew = () => {

    const [isRecording, setIsRecording] = useState(false);
    const [isPaused, setIsPaused] = useState(false);
    const [duration, setDuration] = useState(0);
    const [audioURL, setAudioURL] = useState<string | null>(null);
    const mediaRecorderRef = useRef<MediaRecorder | null>(null);
    const chunksRef = useRef<Blob[]>([]);
    const timerRef = useRef<NodeJS.Timeout | null>(null);
    const { toast } = useToast(); 
    const { sendData, isProcessing, results } = useWebSocket(); 


    useEffect(() => {
        // This cleanup will handle the part relevant to audio and recording state
        return () => {
            if (timerRef.current) clearInterval(timerRef.current);
        };
    }, []);

    const startTimer = () => {
        timerRef.current = setInterval(() => {
            setDuration((prevDuration) => prevDuration + 1);
        }, 1000);
    };

    const stopTimer = () => {
        if (timerRef.current) clearInterval(timerRef.current);
        timerRef.current = null;
    };

    const formatDuration = (seconds: number) => {
        const minutes = Math.floor(seconds / 60);
        const remainingSeconds = seconds % 60;
        return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`;
    };

    const startRecording = async () => {
        try {
            const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
            mediaRecorderRef.current = new MediaRecorder(stream);
            mediaRecorderRef.current.ondataavailable = (e) => {
                chunksRef.current.push(e.data);
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
            mediaRecorderRef.current.stop(); 
            setIsRecording(false);
            stopTimer();
            const blob = new Blob(chunksRef.current, { type: 'audio/webm' });
            const audioUrl = URL.createObjectURL(blob);
            setAudioURL(audioUrl);

            // Now prepare and send the data over WebSocket
            const buffer = await blob.arrayBuffer();
            const base64DataUrl = await bytesToBase64DataUrl(new Uint8Array(buffer), 'audio/webm');
            sendData(base64DataUrl as string);

            mediaRecorderRef.current.stream.getTracks().forEach(track => track.stop());
            setIsRecording(false);
            setIsPaused(false);
            stopTimer();
            toast({
                title: "Recording stopped",
                description: "Your message has been recorded",
            });
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

    return (
        <div className="space-y-8 w-full max-w-2xl mx-auto">
            <Card className="w-full p-6 space-y-6 animate-fadeIn">
                <div className="space-y-2 text-center">
                    <h2 className="text-2xl font-semibold tracking-tight">AI Health Assistant</h2>
                    <p className="text-sm text-muted-foreground">Record your health-related questions</p>
                    {isRecording && (
                        <p className="text-lg font-semibold text-primary">{formatDuration(duration)}</p>
                    )}
                    {isProcessing && (
                        <p className="text-sm text-muted-foreground animate-pulse">Processing your recording...</p>
                    )}
                </div>

                <div className="flex flex-col items-center gap-4">
                    <div className="relative w-32 h-32 flex items-center justify-center">
                        <div
                            className={`absolute inset-0 bg-primary/10 rounded-full ${isRecording ? 'animate-[pulse_2s_cubic-bezier(0.4,0,0.6,1)_infinite]' : ''
                                }`}
                        />
                        <Button
                            variant="ghost"
                            size="icon"
                            className={`w-20 h-20 rounded-full transform active:scale-95 transition-all duration-200
 
            ${isRecording
                                    ? 'bg-red-500 hover:bg-red-600 animate-pulse'
                                    : 'bg-primary hover:bg-primary/90'
                                }`} onClick={isRecording ? stopRecording : startRecording}
                        >
                            {isRecording ? (
                                <Square className="w-8 h-8 text-white" />
                            ) : (
                                <Mic className="w-8 h-8 text-white" />
                            )}
                        </Button>
                    </div>
                    {isRecording && (
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
                    )}
                    {/* {audioURL && (
            <audio controls className="w-full mt-4">
              <source src={audioURL} type="audio/webm" />
              Your browser does not support the audio element.
            </audio>
          )} */}
                </div>
            </Card>
            <RecordingResults newResult={results} audioUrl={audioURL} />
        </div>
    );
};