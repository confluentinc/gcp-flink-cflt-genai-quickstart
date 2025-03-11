import { Toggle } from "@/components/ui/toggle";
import { Mic, MessageSquare } from "lucide-react";

interface InputModeSelectorProps {
  mode: "audio" | "text";
  onChange: (mode: "audio" | "text") => void;
}

export const InputModeSelector = ({ mode, onChange }: InputModeSelectorProps) => {
  return (
    <div className="flex justify-center gap-2 mb-4">
      <Toggle
        pressed={mode === "audio"}
        onPressedChange={() => onChange("audio")}
        className="data-[state=on]:bg-primary data-[state=on]:text-primary-foreground"
        aria-label="Switch to audio mode"
      >
        <Mic className="mr-1" /> Audio
      </Toggle>
      <Toggle
        pressed={mode === "text"}
        onPressedChange={() => onChange("text")}
        className="data-[state=on]:bg-primary data-[state=on]:text-primary-foreground"
        aria-label="Switch to text mode"
      >
        <MessageSquare className="mr-1" /> Text
      </Toggle>
    </div>
  );
};