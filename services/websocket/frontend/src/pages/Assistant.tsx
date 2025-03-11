import { Navbar } from "@/components/Navbar";
import { AudioRecorder } from "@/components/AudioRecorder";
import { Toaster } from "@/components/ui/toaster";

const Assistant = () => {
  return (
    <div className="min-h-screen bg-gradient-to-b from-white to-gray-50">
      <Navbar />
      <main className="container mx-auto px-4 pt-32 pb-16 flex justify-center">
        <AudioRecorder />
      </main>
      <Toaster />
    </div>
  );
};

export default Assistant;
