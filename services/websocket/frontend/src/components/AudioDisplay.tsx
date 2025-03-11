interface AudioDisplayProps {
    audioURL: string | null;
  }
  
  export const AudioDisplay = ({ audioURL }: AudioDisplayProps) => {
    if (!audioURL) return null;
    
    return (
      <audio controls className="w-full mt-4">
        <source src={audioURL} type="audio/webm" />
        Your browser does not support the audio element.
      </audio>
    );
  };