import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { Send } from "lucide-react";

interface TextInputFormProps {
  onSubmit: (text: string) => void;
  isProcessing: boolean;
}

export const TextInputForm = ({ onSubmit, isProcessing }: TextInputFormProps) => {
  const [textInput, setTextInput] = useState("");

  const handleSubmit = () => {
    onSubmit(textInput);
    setTextInput("");
  };

  return (
    <div className="flex flex-col gap-4">
      <Textarea
        placeholder="Type your health question here..."
        value={textInput}
        onChange={(e) => setTextInput(e.target.value)}
        className="min-h-[120px] resize-none"
        disabled={isProcessing}
      />
      <Button 
        onClick={handleSubmit}
        disabled={!textInput.trim() || isProcessing}
        className="self-end"
      >
        <Send className="mr-2" />
        Send Question
      </Button>
    </div>
  );
};