import { Navbar } from "@/components/Navbar";
import { Button } from "@/components/ui/button";
import { Link } from "react-router-dom";
import { Heart, Shield, MessageCircle } from "lucide-react";

const Index = () => {
  return (
    <div className="min-h-screen bg-gradient-to-b from-white to-gray-50">
      <Navbar />
      <main className="container mx-auto px-4 pt-32 pb-16">
        <section className="text-center space-y-6 animate-fadeIn">
          <div className="inline-flex items-center bg-primary/10 text-primary rounded-full px-4 py-1.5 text-sm font-medium mb-8">
            <span className="relative flex h-2 w-2 mr-2">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-primary opacity-75"></span>
              <span className="relative inline-flex rounded-full h-2 w-2 bg-primary"></span>
            </span>
            New AI Assistant Now Available
          </div>
          <h1 className="text-4xl md:text-6xl font-bold text-secondary tracking-tight">
            Your Health, Our Priority
          </h1>
          <p className="text-xl text-gray-600 max-w-2xl mx-auto">
            Experience healthcare reimagined with our AI-powered platform. Get instant answers to your health questions.
          </p>
          <div className="flex flex-wrap justify-center gap-4">
            <Link to="/assistant">
              <Button size="lg" className="bg-primary hover:bg-primary/90 text-white transition-colors">
                Try AI Assistant
              </Button>
            </Link>
          </div>
        </section>

        <section className="mt-24 grid md:grid-cols-3 gap-8">
          {[
            {
              icon: <Heart className="w-6 h-6 text-primary" />,
              title: "Personalized Care",
              description: "Get healthcare tailored to your unique needs with our AI-powered platform."
            },
            {
              icon: <Shield className="w-6 h-6 text-primary" />,
              title: "Secure & Private",
              description: "Your health data is protected with enterprise-grade security measures."
            },
            {
              icon: <MessageCircle className="w-6 h-6 text-primary" />,
              title: "24/7 Support",
              description: "Access our AI health assistant anytime, anywhere for instant support."
            }
          ].map((feature, index) => (
            <div key={index} className="p-6 bg-white rounded-lg shadow-sm hover:shadow-md transition-shadow animate-fadeIn">
              <div className="w-12 h-12 bg-primary/10 rounded-lg flex items-center justify-center mb-4">
                {feature.icon}
              </div>
              <h3 className="text-xl font-semibold mb-2">{feature.title}</h3>
              <p className="text-gray-600">{feature.description}</p>
            </div>
          ))}
        </section>
      </main>
    </div>
  );
};

export default Index;