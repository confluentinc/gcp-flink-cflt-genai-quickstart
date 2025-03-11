import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Button } from "@/components/ui/button";

import {
  Card,
  CardContent,
} from "@/components/ui/card";
import { Loader } from "lucide-react";
import { format } from 'date-fns';

interface RecordingResult {
  timestamp: string;
  question: string;
  response: string;
  results: string;
  audioUrl: string;
}

interface RecordingResultsProps {
  results: RecordingResult | null;
  isProcessing?: boolean;
}

const refreshPage = () => {
  window.location.reload();
};

export const RecordingResults = ({
  results,
  isProcessing = false
}: RecordingResultsProps) => {
  if (!results && !isProcessing) return null;
  return (
    <div className="w-full space-y-4 animate-fadeIn">
     
      {isProcessing ? (
        <div className="w-full p-8 flex flex-col items-center justify-center space-y-4 bg-white rounded-lg shadow">
          <Loader className="w-10 h-8 text-primary animate-spin" />
          <p className="text-sm text-muted-foreground">Processing your request...</p>
        </div>
      ) : (
      <div className="flex flex-col gap-4">
      {results.map((result, index) => (
        <div key={index}>
          {/* User Message */}
          <div className="flex justify-end">
            <Card className="max-w-[80%] bg-[#F1F0FB]">
              <CardContent className="p-4">
                <p className="text-sm mb-2">{result.question}</p>
               
                <p className="text-xs text-muted-foreground mt-2">
                  {new Date(result.timestamp).toLocaleTimeString()}
                </p>
              </CardContent>
            </Card>
          </div>
    
          {/* AI Response */}
          <div className="flex justify-start">
            <Card className="max-w-[80%] bg-[#0EA5E9]">
              <CardContent className="p-4">
                <p className="text-sm text-white mb-2">{result.response}</p>
                {result.audioUrl && (
                  <audio controls className="w-full max-w-[300px]">
                    <source src={result.audioUrl} type="audio/webm" />
                    Your browser does not support the audio element.
                  </audio>
                )}
                <p className="text-xs text-white/80 mt-2">
                  {new Date(result.timestamp).toLocaleTimeString()}
                </p>
              </CardContent>
            </Card>
          </div>
        </div>
      ))}
    </div>
      )}
    </div>
  );
};