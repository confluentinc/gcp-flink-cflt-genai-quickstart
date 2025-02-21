import React, { createContext, useContext, useState, useEffect, useRef } from "react";

// Extending the context type to include received messages
interface WebSocketContextType {
  isConnected: boolean;
  isProcessing: boolean;
  results: any; 
  sendData: (data: string) => void;
  updateResults: (results: any) => void; 
}

const defaultWebSocketContextValue: WebSocketContextType = {
  isConnected: false,
  isProcessing: false,
  results: null, // Initially, no results received
  sendData: () => {
    console.warn('sendData() was called without a WebSocketProvider');
  },
  updateResults: () => {
    console.warn('updateResults() was called without a WebSocketProvider');
  },
};

const WebSocketContext = createContext<WebSocketContextType>(defaultWebSocketContextValue);

export const useWebSocket = () => useContext(WebSocketContext);

export const WebSocketProvider = ({ children }) => {
  const [isConnected, setIsConnected] = useState(false);
  const [isProcessing, setIsProcessing] = useState(false);
  const [results, setResults] = useState(null); // State to store received messages
  const wsRef = useRef<WebSocket | null>(null);

  useEffect(() => {
    const initializeWebSocket = () => {
      const ws = new WebSocket('ws://localhost:8080/bot'); //TODO: This needs to be changed out for a property set my TF
      ws.onopen = () => {
        console.log('WebSocket connection established');
        setIsConnected(true);
      };
      ws.onmessage = (event) => {
        console.log('Received WebSocket message:', event.data);
        try {
          const result = JSON.parse(event.data);
          setResults(result); // Update state with the parsed result
          setIsProcessing(false); // Assuming processing is done when a message is received
        } catch (error) {
          console.error('Error parsing WebSocket message:', error);
        }
      };
      ws.onclose = () => console.log('WebSocket connection closed');
      ws.onerror = (error) => console.error('WebSocket error:', error);
      wsRef.current = ws;
    };

    initializeWebSocket();

    return () => {
      if (wsRef.current) {
        wsRef.current.close();
      }
    };
  }, []);

  const sendData = (data: string) => {
    if (wsRef.current?.readyState === WebSocket.OPEN) {
      wsRef.current.send(data);
      setIsProcessing(true);
    } else {
      console.error("WebSocket is not open. ReadyState:", wsRef.current?.readyState);
    }
  };

  // Function to allow results to be cleared or updated externally
  const updateResults = (newResults: any) => {
    setResults(newResults);
  };

  return (
    <WebSocketContext.Provider value={{ isConnected, isProcessing, results, sendData, updateResults }}>
      {children}
    </WebSocketContext.Provider>
  );
};
