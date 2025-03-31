import { Navbar } from '@/components/Navbar'
import { AudioRecorder } from '@/components/AudioRecorder'
import { Toaster } from '@/components/ui/toaster'

const Assistant = () => {
  return (
    <div className="min-h-screen">
      <Navbar />
      <main className="mx-auto px-4 pt-32 pb-16 flex">
        <AudioRecorder />
      </main>
      <Toaster />
    </div>
  )
}

export default Assistant
