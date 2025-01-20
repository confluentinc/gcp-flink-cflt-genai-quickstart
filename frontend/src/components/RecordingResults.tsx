import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
  } from "@/components/ui/table";

  interface RecordingResult {
    timestamp: string;
    transcript: string;
    response: string;
    result: string;
  }

  interface RecordingResultsProps {
    newResult: RecordingResult | null;
    audioUrl: string | null;
  }
  
  export const RecordingResults = ({ newResult, audioUrl }: RecordingResultsProps) => {
    if (!newResult) return null;
    return (
      <div className="w-full space-y-4 animate-fadeIn">
        {audioUrl && (
          <div className="w-full p-4 bg-white rounded-lg shadow">
            <audio controls className="w-full">
              <source src={audioUrl} type="audio/webm" />
              Your browser does not support the audio element.
            </audio>
          </div>
        )}
        
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Result</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow>
              <TableCell>{newResult.transcript}</TableCell>
              <TableCell>{newResult.response}</TableCell>
              <TableCell>{newResult.result}</TableCell>
            </TableRow>
          </TableBody>
        </Table>
      </div>
    );
  };