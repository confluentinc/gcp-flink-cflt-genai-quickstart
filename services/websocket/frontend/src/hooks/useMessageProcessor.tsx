import { useState, useRef, useEffect } from "react";
import { useToast } from "@/components/ui/use-toast";
import { RecordingResult } from "./useAudioRecorder";
import { v4 as uuidv4 } from 'uuid';

export const useMessageProcessor = () => {
  const [results, setResults] = useState<RecordingResult[] | null>(null);
  const [isProcessing, setIsProcessing] = useState(false);
  const [responseAudioUrl, setResponseAudioUrl] = useState<string | null>(null);
  const wsRef = useRef<WebSocket | null>(null);
  const { toast } = useToast();

  const initializeWebSocket = () => {
    return new Promise((resolve, reject) => {
      if (wsRef.current?.readyState === WebSocket.OPEN) {
        resolve(wsRef.current); // Connection already open
        return;
      }

      const wsURL = import.meta.env.VITE_WS_URL ? import.meta.env.VITE_WS_URL + "/ws"
        : (window.location.protocol === 'https:' ? 'wss://' : 'ws://') + window.location.host + '/ws'
      const ws = new WebSocket(wsURL);

      ws.onopen = () => {
        console.log('WebSocket connection established');
        console.log(`Connected to: ${ws.url}`);
        console.log(`Ready state is: ${ws.readyState}`);
        resolve(ws);
      };

      ws.onmessage = (event) => {
        console.log('Received WebSocket message:', event.data);
        try {
          const data = JSON.parse(event.data);

          console.log("data: ", data)
          // Handle the new response format
          if (data.data && data.data.startsWith('data:audio/wav;base64,')) {
            // Store the audio data URL
            setResponseAudioUrl(data.data);
          }

          const newResult: RecordingResult = {
            messageId: data.messageId,
            timestamp: new Date().toISOString(),
            question: data.question || "",
            response: data.result || "",
            audioUrl: data.data && data.data.startsWith('data:audio/wav;base64,') ? data.data : undefined
          };

          // Set the result with the text response
          // Update the results state
          setResults(currentResults => {
            // If currentResults is null, initialize as an empty array and add the new result
            if (currentResults === null) {
              return [newResult];
            }

            // Otherwise, append the new result to the existing array
            return [...currentResults, newResult];
          });

          setIsProcessing(false);
          toast({
            title: "Processing Complete",
            description: "Your recording has been processed",
          });

        } catch (error) {
          console.error('Error parsing WebSocket message:', error);
          setIsProcessing(false);
          toast({
            title: "Processing Error",
            description: "Failed to process the recording",
            variant: "destructive",
          });
        }
      };

      ws.onerror = (error) => {
        console.error('WebSocket error:', error);
        setIsProcessing(false);
        setResults([]);
        reject(new Error("Failed to connect to the server"));
        toast({
          title: "Connection Error",
          description: "Failed to connect to the server",
          variant: "destructive",
        });
      };

      ws.onclose = () => {
        console.log('WebSocket connection closed');
        if (isProcessing) {
          setIsProcessing(false);
          toast({
            title: "Connection Lost",
            description: "Lost connection to the server",
            variant: "destructive",
          });
          setResults([]);
        }
      };

      wsRef.current = ws;
    });
  };

  const processAudioRecording = async (audioBlob: Blob) => {
    try {
      // Wait for the WebSocket connection to be established
      await initializeWebSocket();

      if (wsRef.current?.readyState === WebSocket.OPEN) {
        setIsProcessing(true);

        const messageId = uuidv4(); // Generate a unique identifier for the message

        const message = JSON.stringify({
          type: "audio",
          content: audioBlob,
          timestamp: new Date().toISOString(),
          messageId: messageId, // Include the unique messageId in the message
        });

        wsRef.current.send(message);
        console.log('Sent audio blob through WebSocket');
        toast({
          title: "Processing",
          description: "Your recording is being processed",
        });
      }
    } catch (error) {
      console.error("Connection error: ", error);
      toast({
        title: "Connection Error",
        description: "Could not connect to the server",
        variant: "destructive",
      });
    }
  };

  const processTextMessage = async (textInput) => {
    if (!textInput.trim()) {
      toast({
        title: "Empty message",
        description: "Please enter a question",
        variant: "destructive",
      });
      return;
    }

    try {
      // Await the initialization of the WebSocket connection
      await initializeWebSocket();

      // At this point, the WebSocket is open
      setIsProcessing(true);

      const messageId = uuidv4(); // Generate a unique identifier for the message

      const message = JSON.stringify({
        type: "text",
        content: textInput,
        timestamp: new Date().toISOString(),
        messageId: messageId, // Include the unique messageId in the message
      });

      wsRef.current?.send(message);
      console.log('Sent text message through WebSocket');

      toast({
        title: "Processing",
        description: "Your question is being processed",
      });
    } catch (error) {

      // Handle the case where WebSocket connection couldn't be established
      console.error("WebSocket connection error:", error);
      toast({
        title: "Connection Error",
        description: "Could not connect to the server",
        variant: "destructive",
      });
    }
  };

  useEffect(() => {
    // This cleanup function ensures we close the WebSocket connection
    // when the component using this hook is unmounted.
    return () => {
      if (wsRef.current) {
        wsRef.current.close();
      }
    };
  }, []);

  return {
    results,
    isProcessing,
    responseAudioUrl,
    processAudioRecording,
    processTextMessage
  };
};