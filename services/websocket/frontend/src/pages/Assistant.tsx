import { Navbar } from "@/components/Navbar";
import { AudioRecorder } from "@/components/AudioRecorder";
import { WebSocketProvider } from "@/components/WebSocketProvider";


const Assistant = () => {
  return (
    <div className="min-h-screen bg-gradient-to-b from-white to-gray-50">
      <Navbar />
      <main className="container mx-auto px-4 pt-32 pb-16 flex justify-center">
        <WebSocketProvider> 
        <AudioRecorder />
        </WebSocketProvider>
      </main>
    </div>
  );
};

export default Assistant;
