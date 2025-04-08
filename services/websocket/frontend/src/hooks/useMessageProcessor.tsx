import { useState, useRef, useEffect } from "react";
import { useToast } from "@/components/ui/use-toast";
import { RecordingResult } from "./useAudioRecorder";

const RESPONSE_TIMEOUT = 30000; // 30 seconds timeout for waiting for response
const WEBSOCKET_TIMEOUT = 15000; // 15 seconds timeout for websocket to open


export const useMessageProcessor = () => {
  const [result, setResult] = useState<RecordingResult | null>(null);
  const [isProcessing, setIsProcessing] = useState(false);
  const [responseAudioUrl, setResponseAudioUrl] = useState<string | null>(null);
  const wsRef = useRef<WebSocket | null>(null);
  const timeoutRef = useRef<NodeJS.Timeout | null>(null);
  const { toast } = useToast();

  // Create a conversation ID reference for tracking request-response pairs
  const conversationIdRef = useRef<string | null>(null);

  const clearResponseTimeout = () => {
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
      timeoutRef.current = null;
    }
  };

  const setResponseTimeout = () => {
    clearResponseTimeout();
    timeoutRef.current = setTimeout(() => {
      setIsProcessing(false);
      toast({
        title: "Response Timeout",
        description: "The server took too long to respond. Please try again.",
        variant: "destructive",
      });
      if (wsRef.current) {
        wsRef.current.close();
        wsRef.current = null;
      }
        // Clear conversation ID on timeout
        conversationIdRef.current = null;
    }, RESPONSE_TIMEOUT);
  };

  const initializeWebSocket = () => {
    return new Promise((resolve, reject) => {
      if (wsRef.current?.readyState === WebSocket.OPEN) {
        resolve(wsRef.current); // Connection already open
        return wsRef.current; // Connection already open
      }

      const wsURL = import.meta.env.VITE_WS_URL ? import.meta.env.VITE_WS_URL + "/ws"
        : (window.location.protocol === 'https:' ? 'wss://' : 'ws://') + window.location.host + '/ws';

      wsRef.current = new WebSocket(wsURL);

     // Create a timeout to close the connection if it's not established within the specified duration
     const wsTimeout = setTimeout(() => {
       // Check if the WebSocket is still not open (WebSocket readyState 0 is CONNECTING)
       if (wsRef.current.readyState !== WebSocket.OPEN) {
         console.log('Closing WebSocket due to timeout.');
         wsRef.current.close(); // Attempt to close the WebSocket
       }
     }, WEBSOCKET_TIMEOUT);


      wsRef.current.onopen = () => {
        console.log('WebSocket connection established');
        console.log(`Connected to: ${wsRef.current.url}`);
        resolve(wsRef);
        clearTimeout(wsTimeout); // Cancel the timeout
      };

      wsRef.current.onmessage = (event) => {
        console.log('Received WebSocket message:', event.data);
        clearTimeout(wsTimeout); // Cancel the timeout
        clearResponseTimeout();

        try {
          const data = JSON.parse(event.data);

           // Only process messages if we're expecting a response
          if (!conversationIdRef.current) {
            console.log('No active conversation ID to associate response with');
            return;
          }

          // Handle the new response format
          if (data.data && data.data.startsWith('data:audio/wav;base64,')) {
            // Store the audio data URL
            setResponseAudioUrl(data.data);
          }

          // Set the result with the conversation ID and response text
          setResult({
            timestamp: conversationIdRef.current,
            transcript: result?.transcript || "",
            response: data.result || ""
          });

          setIsProcessing(false);
          toast({
            title: "Processing Complete",
            description: "Your recording has been processed",
          });
        // Do NOT reset the conversation ID here - it will be done in the AudioRecorder component
        // after successfully processing the response
        } catch (error) {
          console.error('Error parsing WebSocket message:', error);
          setIsProcessing(false);
          toast({
            title: "Processing Error",
            description: "Failed to process the recording",
            variant: "destructive",
          });

          // Reset the conversation ID on error
          conversationIdRef.current = null;
        }
      };

      wsRef.current.onerror = (error) => {
        console.error('WebSocket error:', error);
        clearResponseTimeout();
        setIsProcessing(false);
        reject(new Error("Failed to connect to the server"));
        toast({
          title: "Connection Error",
          description: "Failed to connect to the server",
          variant: "destructive",
        });
        conversationIdRef.current = null;
      };

      wsRef.current.onclose = () => {
        console.log('WebSocket connection closed');
        clearResponseTimeout();
        if (isProcessing) {
          setIsProcessing(false);
          toast({
            title: "Connection Lost",
            description: "Lost connection to the server",
            variant: "destructive",
          });
          conversationIdRef.current = null;
        }
      };
    });
  };

  const processAudioRecording = async (audioBlob: Blob, conversationId: String) => {
    // Set the conversation ID for this request-response pair
    conversationIdRef.current = conversationId;

    try {
      // Wait for the WebSocket connection to be established
      await initializeWebSocket();

      setIsProcessing(true);
      const message = JSON.stringify({
        type: "audio",
        content: audioBlob,
        timestamp: new Date().toISOString()
      });

      wsRef.current.send(message);
      console.log('Sent audio blob through WebSocket with conversation ID:', conversationId);

      toast({
        title: "Processing",
        description: "Your recording is being processed",
      });
      setResponseTimeout();
    } catch (error) {
      console.error("Connection error: ", error);
      toast({
        title: "Connection Error",
        description: "Could not connect to the server, please try again",
        variant: "destructive",
      });
      conversationIdRef.current = null;
    }
  };

  const processTextMessage = async (textInput: string, conversationId: string) => {
    if (!textInput.trim()) {
      toast({
        title: "Empty message",
        description: "Please enter a question",
        variant: "destructive",
      });
      return;
    }
    // Set the conversation ID for this request-response pair
    conversationIdRef.current = conversationId;
    
    try {
      // Await the initialization of the WebSocket connection
      await initializeWebSocket();

      setIsProcessing(true);

      const message = JSON.stringify({
        type: "text",
        content: textInput,
        timestamp: new Date().toISOString()
      });

      wsRef.current.send(message);
      console.log('Sent text message through WebSocket');

      setResponseTimeout();


      setResult({
        timestamp: new Date().toISOString(),
        transcript: textInput,
        response: ""
      });

      toast({
        title: "Processing",
        description: "Your question is being processed",
      });

    } catch (error) {
      // Handle the case where WebSocket connection couldn't be established
      console.error("WebSocket connection error:", error);
      toast({
        title: "Connection Error",
        description: "Could not connect to the server, please try again",
        variant: "destructive",
      });
    }
  };

  // Method to clear the conversation ID from outside
  const clearConversationId = () => {
    conversationIdRef.current = null;
  };

  useEffect(() => {
    return () => {
      clearResponseTimeout();
      if (wsRef.current) {
        wsRef.current.close();
        wsRef.current = null;
      }
    };
  }, []);

  return {
    result,
    isProcessing,
    responseAudioUrl,
    processAudioRecording,
    processTextMessage,
    clearConversationId
  };
};
