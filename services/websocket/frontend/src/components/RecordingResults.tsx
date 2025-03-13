import { Card, CardContent } from "@/components/ui/card";
import { Message } from "@/hooks/useConversationHistory";
import { ScrollArea } from "@/components/ui/scroll-area";

interface RecordingResultsProps {
  messages: Message[];
  isProcessing?: boolean;
}

export const RecordingResults = ({ 
  messages, 
  isProcessing = false,
}: RecordingResultsProps) => {
  // Sample data for preview mode


  // Use either the actual messages or preview data
  const displayMessages = messages;
  
  if (displayMessages.length === 0 && !isProcessing) return null;

  return (
    <ScrollArea className="h-[400px] w-full rounded-md border">
      <div className="p-4 space-y-4">
        {isProcessing ? (
          <div className="w-full p-8 flex flex-col items-center justify-center space-y-4 bg-white rounded-lg shadow">
            <div className="w-8 h-8 border-4 border-primary border-t-transparent rounded-full animate-spin" />
            <p className="text-sm text-muted-foreground">Processing your request...</p>
          </div>
        ) : (
          <div className="flex flex-col gap-4">
            {displayMessages.map((message) => (
              <div 
                key={message.id} 
                className={`flex ${message.type === "user" ? "justify-end" : "justify-start"}`}
              >
                <Card 
                  className={`max-w-[80%] ${
                    message.type === "user" ? "bg-[#F1F0FB]" : "bg-[#0EA5E9]"
                  }`}
                >
                  <CardContent className="p-4">
                    <p className={`text-sm ${message.type === "ai" ? "text-white" : ""} mb-2`}>
                      {message.text}
                    </p>
                    {message.audioUrl && (
                      <audio controls className="w-full max-w-[300px]">
                        <source src={message.audioUrl} type={message.type === "user" ? "audio/webm" : "audio/wav"} />
                        Your browser does not support the audio element.
                      </audio>
                    )}
                    <p className={`text-xs ${message.type === "ai" ? "text-white/80" : "text-muted-foreground"} mt-2`}>
                      {new Date(message.timestamp).toLocaleTimeString()}
                    </p>
                  </CardContent>
                </Card>
              </div>
            ))}
          </div>
        )}
      </div>
    </ScrollArea>
  );
};