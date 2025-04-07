import { Navbar } from "@/components/Navbar";
import { HelpForm } from "@/components/HelpForm";

const Help = () => {
  return (
    <div className="min-h-screen bg-gradient-to-b from-white to-gray-50">
      <Navbar />
      <main className="container mx-auto px-4 pt-32 pb-16 flex justify-center">
        <HelpForm />
      </main>
    </div>
  );
};

export default Help;
